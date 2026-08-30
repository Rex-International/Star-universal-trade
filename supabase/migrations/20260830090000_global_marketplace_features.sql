/* Star Universal Trade - Global marketplace feature upgrade
   Adds store locations, store follows, buying-request currencies,
   notifications for followed stores/new buying requests, and media policies.
*/

-- STORE LOCATION
ALTER TABLE stores ADD COLUMN IF NOT EXISTS location_text text;
ALTER TABLE stores ADD COLUMN IF NOT EXISTS city text;
ALTER TABLE stores ADD COLUMN IF NOT EXISTS latitude double precision;
ALTER TABLE stores ADD COLUMN IF NOT EXISTS longitude double precision;

-- BUYING REQUEST CURRENCY
ALTER TABLE public_orders ADD COLUMN IF NOT EXISTS currency text NOT NULL DEFAULT 'USD';
ALTER TABLE public_order_responses ADD COLUMN IF NOT EXISTS currency text NOT NULL DEFAULT 'USD';

-- STORE FOLLOWERS
CREATE TABLE IF NOT EXISTS store_followers (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  store_id uuid NOT NULL REFERENCES stores(id) ON DELETE CASCADE,
  user_uid text NOT NULL,
  created_at timestamptz NOT NULL DEFAULT now(),
  UNIQUE (store_id, user_uid)
);
ALTER TABLE store_followers ENABLE ROW LEVEL SECURITY;

DROP POLICY IF EXISTS "store_followers_select_own" ON store_followers;
CREATE POLICY "store_followers_select_own" ON store_followers FOR SELECT
  TO authenticated USING (auth.uid()::text = user_uid);
DROP POLICY IF EXISTS "store_followers_insert_own" ON store_followers;
CREATE POLICY "store_followers_insert_own" ON store_followers FOR INSERT
  TO authenticated WITH CHECK (auth.uid()::text = user_uid);
DROP POLICY IF EXISTS "store_followers_delete_own" ON store_followers;
CREATE POLICY "store_followers_delete_own" ON store_followers FOR DELETE
  TO authenticated USING (auth.uid()::text = user_uid);

CREATE INDEX IF NOT EXISTS idx_store_followers_store_id ON store_followers(store_id);
CREATE INDEX IF NOT EXISTS idx_store_followers_user_uid ON store_followers(user_uid);

-- MEDIA BUCKET + POLICIES
-- The project already uses a bucket named "media". This keeps it public for
-- product/store/chat media URLs while restricting uploads to authenticated users.
INSERT INTO storage.buckets (id, name, public)
VALUES ('media', 'media', true)
ON CONFLICT (id) DO UPDATE SET public = EXCLUDED.public;

DROP POLICY IF EXISTS "media_public_read" ON storage.objects;
CREATE POLICY "media_public_read" ON storage.objects FOR SELECT
  TO anon, authenticated USING (bucket_id = 'media');

DROP POLICY IF EXISTS "media_authenticated_upload" ON storage.objects;
CREATE POLICY "media_authenticated_upload" ON storage.objects FOR INSERT
  TO authenticated WITH CHECK (
    bucket_id = 'media'
    AND (storage.foldername(name))[1] = auth.uid()::text
  );

DROP POLICY IF EXISTS "media_owner_update" ON storage.objects;
CREATE POLICY "media_owner_update" ON storage.objects FOR UPDATE
  TO authenticated USING (
    bucket_id = 'media'
    AND (storage.foldername(name))[1] = auth.uid()::text
  ) WITH CHECK (
    bucket_id = 'media'
    AND (storage.foldername(name))[1] = auth.uid()::text
  );

DROP POLICY IF EXISTS "media_owner_delete" ON storage.objects;
CREATE POLICY "media_owner_delete" ON storage.objects FOR DELETE
  TO authenticated USING (
    bucket_id = 'media'
    AND (storage.foldername(name))[1] = auth.uid()::text
  );

-- SECURITY-DEFINER notification helpers. These functions create notifications
-- on behalf of the platform; users cannot manufacture notifications for others.
CREATE OR REPLACE FUNCTION notify_store_followers_on_product()
RETURNS trigger
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $$
DECLARE
  store_name text;
BEGIN
  SELECT name INTO store_name FROM stores WHERE id = NEW.store_id;

  INSERT INTO notifications (user_uid, title, body)
  SELECT sf.user_uid,
         'New product from a store you follow',
         COALESCE(store_name, 'A store you follow') || ' has published a new product: ' || NEW.name
  FROM store_followers sf
  WHERE sf.store_id = NEW.store_id
    AND sf.user_uid <> NEW.seller_uid;

  RETURN NEW;
END;
$$;

DROP TRIGGER IF EXISTS trg_notify_store_followers_on_product ON products;
CREATE TRIGGER trg_notify_store_followers_on_product
AFTER INSERT ON products
FOR EACH ROW
WHEN (NEW.status = 'active' AND NEW.is_restricted = false)
EXECUTE FUNCTION notify_store_followers_on_product();

CREATE OR REPLACE FUNCTION notify_sellers_on_public_order()
RETURNS trigger
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $$
BEGIN
  INSERT INTO notifications (user_uid, title, body)
  SELECT p.id,
         'New buying request',
         'A buyer has posted a new request: ' || NEW.title
  FROM profiles p
  WHERE p.is_seller = true
    AND p.id <> NEW.buyer_uid;

  RETURN NEW;
END;
$$;

DROP TRIGGER IF EXISTS trg_notify_sellers_on_public_order ON public_orders;
CREATE TRIGGER trg_notify_sellers_on_public_order
AFTER INSERT ON public_orders
FOR EACH ROW
WHEN (NEW.status = 'open')
EXECUTE FUNCTION notify_sellers_on_public_order();

-- Make public-order responses private to the buyer/request owner and responding seller.
DROP POLICY IF EXISTS "public_order_responses_select_all" ON public_order_responses;
CREATE POLICY "public_order_responses_select_related" ON public_order_responses FOR SELECT
  TO authenticated USING (
    auth.uid()::text = seller_uid
    OR EXISTS (
      SELECT 1 FROM public_orders po
      WHERE po.id = public_order_responses.public_order_id
        AND po.buyer_uid = auth.uid()::text
    )
  );

-- Prevent a user from following the same store twice (also protects old databases).
CREATE UNIQUE INDEX IF NOT EXISTS store_followers_unique_idx
ON store_followers(store_id, user_uid);
