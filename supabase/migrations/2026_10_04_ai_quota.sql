-- ============================================================
-- 2026-10-04 — Per-user daily quota for the ai-proxy Edge Function
--
-- ai_consume_quota(limit) atomically counts one AI call for the
-- calling user (auth.uid()) for today (UTC) and returns false once the
-- limit is reached. Users cannot read or write ai_usage directly.
-- ============================================================

create table if not exists public.ai_usage (
  user_id uuid not null references auth.users(id) on delete cascade,
  day     date not null default (now() at time zone 'utc')::date,
  calls   integer not null default 0,
  primary key (user_id, day)
);

alter table public.ai_usage enable row level security;
revoke all on public.ai_usage from anon, authenticated;

create or replace function public.ai_consume_quota(p_limit integer)
returns boolean
language plpgsql
security definer
set search_path = public
as $$
declare
  v_uid   uuid := auth.uid();
  v_calls integer;
begin
  if v_uid is null then
    return false;
  end if;
  insert into public.ai_usage as u (user_id, day, calls)
  values (v_uid, (now() at time zone 'utc')::date, 1)
  on conflict (user_id, day) do update
    set calls = u.calls + 1
    where u.calls < p_limit
  returning calls into v_calls;
  return v_calls is not null;
end;
$$;

revoke all on function public.ai_consume_quota(integer) from public, anon;
grant execute on function public.ai_consume_quota(integer) to authenticated;
