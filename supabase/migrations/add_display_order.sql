-- ============================================================================
-- Migration: add display_order column to places table
-- Purpose: allow the admin to manually order places (lower display_order = shown
-- first). Default value 999 keeps existing rows at the bottom of any
-- explicitly-ordered list, so new "pinned" places automatically float to the top.
--
-- Run this once in Supabase SQL editor:
--   https://supabase.com/dashboard/project/tbivoxyxclwjjspwsgvc/sql/new
-- ============================================================================

ALTER TABLE places
  ADD COLUMN IF NOT EXISTS display_order integer NOT NULL DEFAULT 999;

-- Existing rows are auto-filled with the default (999) so no data loss.

-- Backfill: any current featured place gets display_order = 0 so it floats
-- to the top out-of-the-box. Anything else stays at 999.
UPDATE places
   SET display_order = 0
 WHERE featured = true
   AND display_order = 999;

-- Index for fast ORDER BY display_order, id queries from the mobile app.
CREATE INDEX IF NOT EXISTS idx_places_display_order
    ON places (display_order ASC, id ASC);

-- Verify
SELECT column_name, data_type, column_default, is_nullable
  FROM information_schema.columns
 WHERE table_schema = 'public'
   AND table_name = 'places'
   AND column_name = 'display_order';

SELECT id, name, display_order
  FROM places
 ORDER BY display_order ASC, id ASC
 LIMIT 20;