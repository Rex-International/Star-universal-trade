-- Add slug column
ALTER TABLE stores
ADD COLUMN IF NOT EXISTS slug text;

-- Create slugs for existing stores
UPDATE stores
SET slug = lower(
  regexp_replace(
    regexp_replace(trim(name), '[^a-zA-Z0-9]+', '-', 'g'),
    '(^-|-$)', '', 'g'
  )
)
WHERE slug IS NULL OR slug = '';

-- Add random suffix for duplicate slugs
WITH duplicates AS (
  SELECT id, slug,
  ROW_NUMBER() OVER (PARTITION BY slug ORDER BY id) AS rn
  FROM stores
  WHERE slug IS NOT NULL
)
UPDATE stores
SET slug = stores.slug || '-' || duplicates.rn
FROM duplicates
WHERE stores.id = duplicates.id
AND duplicates.rn > 1;

-- Index for faster search
CREATE INDEX IF NOT EXISTS stores_slug_idx
ON stores(slug);

-- Unique protection
CREATE UNIQUE INDEX IF NOT EXISTS stores_slug_unique_idx
ON stores(slug)
WHERE slug IS NOT NULL AND slug <> '';
