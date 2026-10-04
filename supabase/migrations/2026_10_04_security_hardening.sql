-- ============================================================
-- 2026-10-04 — Security hardening (RLS)
--
-- Closes the write holes found in docs/REVIEW-AND-ROADMAP.md:
--   C1  any signed-in user could insert/update/delete places, tours,
--       tour_places
--   C2  any signed-in user could upload/overwrite/delete any file in
--       the place-images bucket
--   H1  admin was decided client-side by an email substring
--   H3  leaderboard points were written freely by the client
--   M5  tours_with_places ran with owner rights; streak columns missing
--   +   place_checkins had no DELETE policy (un-visit silently no-op'd)
--       and no uniqueness, place_chat had no length limit
--
-- BEFORE RUNNING ON PRODUCTION:
--   1. Compare with the live policies:  select * from pg_policies;
--   2. Run this whole file in the SQL Editor (it is idempotent).
--   3. Add yourself as admin (replace the email):
--        insert into public.admins (user_id)
--        select id from auth.users where email = 'YOUR_ADMIN_EMAIL'
--        on conflict do nothing;
--      Until step 3 is done NOBODY can edit places from the app/admin.
-- ============================================================

-- ---------- 1. Admins ----------------------------------------------------

create table if not exists public.admins (
  user_id    uuid primary key references auth.users(id) on delete cascade,
  created_at timestamptz default now()
);

alter table public.admins enable row level security;
-- No policies on purpose: the table is only readable through is_admin()
-- and only writable from the SQL Editor / service_role.
revoke all on public.admins from anon, authenticated;

create or replace function public.is_admin()
returns boolean
language sql
stable
security definer
set search_path = public
as $$
  select exists (select 1 from public.admins a where a.user_id = auth.uid());
$$;

revoke all on function public.is_admin() from public;
grant execute on function public.is_admin() to anon, authenticated;

-- ---------- 2. Content tables: public read, admin write -------------------

drop policy if exists "auth write places"      on public.places;
drop policy if exists "auth write tours"       on public.tours;
drop policy if exists "auth write tour_places" on public.tour_places;
drop policy if exists "admin write places"      on public.places;
drop policy if exists "admin write tours"       on public.tours;
drop policy if exists "admin write tour_places" on public.tour_places;

create policy "admin write places" on public.places
  for all to authenticated
  using (public.is_admin()) with check (public.is_admin());
create policy "admin write tours" on public.tours
  for all to authenticated
  using (public.is_admin()) with check (public.is_admin());
create policy "admin write tour_places" on public.tour_places
  for all to authenticated
  using (public.is_admin()) with check (public.is_admin());

-- The view must apply the caller's RLS, not its owner's (PG15+).
alter view public.tours_with_places set (security_invoker = true);

-- ---------- 3. Storage: place-images is admin-write only ------------------

update storage.buckets
   set file_size_limit = 5 * 1024 * 1024,
       allowed_mime_types = array['image/jpeg','image/png','image/webp']
 where id = 'place-images';

drop policy if exists "auth upload place-images" on storage.objects;
drop policy if exists "auth update place-images" on storage.objects;
drop policy if exists "auth delete place-images" on storage.objects;
drop policy if exists "admin upload place-images" on storage.objects;
drop policy if exists "admin update place-images" on storage.objects;
drop policy if exists "admin delete place-images" on storage.objects;

create policy "admin upload place-images" on storage.objects
  for insert to authenticated
  with check (bucket_id = 'place-images' and public.is_admin());
create policy "admin update place-images" on storage.objects
  for update to authenticated
  using (bucket_id = 'place-images' and public.is_admin());
create policy "admin delete place-images" on storage.objects
  for delete to authenticated
  using (bucket_id = 'place-images' and public.is_admin());

-- ---------- 4. Check-ins: one per (user, place), deletable by owner -------

-- Keep the earliest row of any duplicate pair before adding the constraint.
delete from public.place_checkins c
 using public.place_checkins d
 where c.user_id = d.user_id
   and c.place_id = d.place_id
   and c.id > d.id;

do $$
begin
  if not exists (
    select 1 from pg_constraint where conname = 'place_checkins_user_place_key'
  ) then
    alter table public.place_checkins
      add constraint place_checkins_user_place_key unique (user_id, place_id);
  end if;
end $$;

drop policy if exists "auth delete own checkins" on public.place_checkins;
create policy "auth delete own checkins" on public.place_checkins
  for delete to authenticated
  using (auth.uid() = user_id);

-- ---------- 5. Leaderboard: server clamps what the client claims ----------

alter table public.leaderboard add column if not exists current_streak   integer default 0;
alter table public.leaderboard add column if not exists longest_streak   integer default 0;
alter table public.leaderboard add column if not exists total_visit_days integer default 0;
alter table public.leaderboard add column if not exists last_visit_date  timestamptz;

-- The client still upserts its own row (so the app keeps working), but
-- every count is capped by what the server can actually verify:
--   places_visited  = distinct check-ins on record
--   reviews_posted  <= places_visited   (one review per visited place)
--   photos_uploaded <= places_visited * 3
--   total_points    <= the maximum those verified counts can earn
--                      + 2 pts per chat message
--                      + a badge budget of 300 per check-in, capped at
--                        3500 (sum of AchievementCatalog points = 3170,
--                        plus level badges, rounded up)
-- Point values mirror GamificationStats.pointsFor(). Update both if the
-- app's scoring changes.
create or replace function public.leaderboard_clamp()
returns trigger
language plpgsql
security definer
set search_path = public
as $$
declare
  v_checkins int;
  v_chats    int;
  v_ceiling  int;
begin
  select count(distinct place_id) into v_checkins
    from public.place_checkins where user_id = new.user_id;
  select count(*) into v_chats
    from public.place_chat where user_id = new.user_id;

  new.places_visited  := v_checkins;
  new.reviews_posted  := least(greatest(coalesce(new.reviews_posted, 0), 0), v_checkins);
  new.photos_uploaded := least(greatest(coalesce(new.photos_uploaded, 0), 0), v_checkins * 3);

  v_ceiling := v_checkins * 50
             + new.reviews_posted * 20
             + new.photos_uploaded * 30
             + v_chats * 2
             + least(3500, v_checkins * 300);
  new.total_points := least(greatest(coalesce(new.total_points, 0), 0), v_ceiling);
  new.updated_at   := now();
  return new;
end;
$$;

drop trigger if exists trg_leaderboard_clamp on public.leaderboard;
create trigger trg_leaderboard_clamp
  before insert or update on public.leaderboard
  for each row execute function public.leaderboard_clamp();

-- Users may not delete or re-key rows; only their own row is writable
-- (insert/update policies already exist in supabase_setup.sql).

-- ---------- 6. Chat: bounded message length -------------------------------

do $$
begin
  if not exists (
    select 1 from pg_constraint where conname = 'place_chat_message_len'
  ) then
    alter table public.place_chat
      add constraint place_chat_message_len
      check (char_length(message) between 1 and 500) not valid;
  end if;
end $$;
