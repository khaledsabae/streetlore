-- ============================================================================
-- Migration: add enable_chat + enable_gallery to places table
-- Purpose: per-place opt-out for Community Chat and Photo Gallery sections
-- on the Place Details screen. Defaults to TRUE so all existing places keep
-- showing both, matching the previous behavior.
--
-- Run this once in Supabase SQL editor:
--   https://supabase.com/dashboard/project/tbivoxyxclwjjspwsgvc/sql/new
-- ============================================================================

ALTER TABLE places
  ADD COLUMN IF NOT EXISTS enable_chat    boolean NOT NULL DEFAULT true,
  ADD COLUMN IF NOT EXISTS enable_gallery boolean NOT NULL DEFAULT true;

-- Existing rows automatically get TRUE on both — no data loss.

-- Quick sample (top 10 by display_order) to confirm the new columns landed.
SELECT id, name, enable_chat, enable_gallery
  FROM places
 ORDER BY display_order ASC, id ASC
 LIMIT 10;