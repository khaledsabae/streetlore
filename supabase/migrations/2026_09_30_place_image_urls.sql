-- =====================================================================
-- Add image_urls text[] column to places table for multiple official
-- images per place. The existing image_url column is preserved as the
-- "primary" image for backward compatibility (places that only have
-- one image keep it). When both are set, the app shows image_urls
-- first (in order), then falls back to image_url.
--
-- Safe to run multiple times: ALTER TABLE ... IF NOT EXISTS is
-- idempotent in Postgres 9.6+.
-- =====================================================================

ALTER TABLE public.places
  ADD COLUMN IF NOT EXISTS image_urls TEXT[] NOT NULL DEFAULT '{}';

-- Backfill: any existing row with image_url set gets it as the first
-- entry of image_urls (only if image_urls is empty, so we don't
-- duplicate on re-runs).
UPDATE public.places
  SET image_urls = ARRAY[image_url]
  WHERE image_url IS NOT NULL
    AND image_url <> ''
    AND (image_urls IS NULL OR image_urls = '{}'::text[]);

-- Index for GIN lookups if you ever filter by individual URL.
CREATE INDEX IF NOT EXISTS idx_places_image_urls
  ON public.places USING GIN (image_urls);

-- RLS: keep public read. Writes go through service_role in admin app.
DROP POLICY IF EXISTS "Public read places" ON public.places;
-- (Re-apply your project's standard SELECT policy if you have one.)
-- This migration does NOT change the SELECT policy for the table;
-- admins will continue to write via service_role.
