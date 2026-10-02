-- ============================================================================
-- Migration: fix display_order backfill so pins actually work
-- Purpose: the original migration (add_display_order.sql) backfilled every
-- featured place to display_order = 0, so they all tied at the top and
-- "pinning" one place at display_order = 1 left it at position ~20.
-- This migration bumps every featured place to display_order = 50 (a "high
-- but not pinned" rank) so the admin can manually pin specific places to
-- 1, 2, 3, ... and they will float above everything else.
--
-- Run this once in Supabase SQL editor:
--   https://supabase.com/dashboard/project/tbivoxyxclwjjspwsgvc/sql/new
-- ============================================================================

-- Step 1: push every featured place that's currently at 0 up to 50,
-- preserving ties by id (so the relative order inside the featured group
-- stays the same as it was before).
WITH ranked AS (
  SELECT id, ROW_NUMBER() OVER (ORDER BY id ASC) AS rn
    FROM places
   WHERE display_order = 0
)
UPDATE places p
   SET display_order = 49 + ranked.rn
  FROM ranked
 WHERE p.id = ranked.id;

-- Step 2: ensure the rest of the table stays at the 999 default
-- (no-op for any rows that already have display_order > 50).

-- Step 3: verify
SELECT
  display_order,
  COUNT(*) AS count,
  STRING_AGG(name, ' | ' ORDER BY display_order, id) AS sample_names
FROM places
GROUP BY display_order
ORDER BY display_order ASC
LIMIT 30;