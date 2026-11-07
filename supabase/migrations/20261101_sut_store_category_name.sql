-- SUT additive migration: persist each store's selected category.
-- Non-destructive: adds one nullable text column; existing store records remain intact.
ALTER TABLE public.stores
  ADD COLUMN IF NOT EXISTS category_name text;

UPDATE public.stores
SET category_name = 'General'
WHERE category_name IS NULL OR btrim(category_name) = '';

COMMENT ON COLUMN public.stores.category_name IS
  'SUT storefront category label used for category filters and category-based store cover artwork.';
