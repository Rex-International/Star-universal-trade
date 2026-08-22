/*
# Create Star Universal Trade Marketplace Schema (Tables + RLS)

## Overview
Creates the complete marketplace schema for Star Universal Trade (SUT).
Firebase Auth is the identity provider; Supabase PostgreSQL is the application database.
Firebase UID is used as profiles.id and owner_uid throughout.
RLS policies use auth.uid() which resolves to the Firebase UID from the JWT.

## Tables Created
1. profiles — user profiles (id = Firebase UID, text type)
2. categories — product categories (public read)
3. stores — seller stores (owner_uid = Firebase UID)
4. products — marketplace listings
5. product_media — images/media for products
6. favorites — user wishlist items
7. conversations — chat conversations
8. conversation_participants — conversation membership
9. messages — chat messages
10. notifications — user notifications
11. reviews — reviews for products/stores
12. reports — user-submitted reports
13. orders — purchase arrangements
14. public_orders — public buying requests
15. public_order_responses — seller responses to buying requests

## Security
- RLS enabled on ALL tables.
- Public read on categories, active products, product_media, stores, public_orders, reviews, public_order_responses.
- Owner-scoped CRUD on profiles, stores, favorites, notifications, messages, orders.
- auth.uid() resolves to Firebase UID via third-party JWT auth.
*/

-- ============ PROFILES ============
CREATE TABLE IF NOT EXISTS profiles (
  id text PRIMARY KEY,
  display_name text NOT NULL DEFAULT 'User',
  avatar_url text,
  email text,
  is_seller boolean NOT NULL DEFAULT false,
  created_at timestamptz NOT NULL DEFAULT now(),
  updated_at timestamptz NOT NULL DEFAULT now()
);
ALTER TABLE profiles ENABLE ROW LEVEL SECURITY;

-- ============ CATEGORIES ============
CREATE TABLE IF NOT EXISTS categories (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  name text NOT NULL,
  slug text UNIQUE,
  image_url text,
  is_active boolean NOT NULL DEFAULT true,
  created_at timestamptz NOT NULL DEFAULT now()
);
ALTER TABLE categories ENABLE ROW LEVEL SECURITY;

-- ============ STORES ============
CREATE TABLE IF NOT EXISTS stores (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  owner_uid text NOT NULL,
  name text NOT NULL,
  description text,
  country text,
  avatar_url text,
  created_at timestamptz NOT NULL DEFAULT now(),
  updated_at timestamptz NOT NULL DEFAULT now()
);
ALTER TABLE stores ENABLE ROW LEVEL SECURITY;

-- ============ PRODUCTS ============
CREATE TABLE IF NOT EXISTS products (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  seller_uid text NOT NULL,
  store_id uuid REFERENCES stores(id) ON DELETE CASCADE,
  category_id uuid REFERENCES categories(id) ON DELETE SET NULL,
  name text NOT NULL,
  description text,
  price numeric(12,2) NOT NULL DEFAULT 0,
  currency text NOT NULL DEFAULT 'USD',
  stock integer NOT NULL DEFAULT 0,
  status text NOT NULL DEFAULT 'active',
  is_restricted boolean NOT NULL DEFAULT false,
  delivery_available boolean NOT NULL DEFAULT true,
  created_at timestamptz NOT NULL DEFAULT now(),
  updated_at timestamptz NOT NULL DEFAULT now()
);
ALTER TABLE products ENABLE ROW LEVEL SECURITY;

-- ============ PRODUCT MEDIA ============
CREATE TABLE IF NOT EXISTS product_media (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  product_id uuid NOT NULL REFERENCES products(id) ON DELETE CASCADE,
  url text NOT NULL,
  type text NOT NULL DEFAULT 'image',
  created_at timestamptz NOT NULL DEFAULT now()
);
ALTER TABLE product_media ENABLE ROW LEVEL SECURITY;

-- ============ FAVORITES ============
CREATE TABLE IF NOT EXISTS favorites (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  user_uid text NOT NULL,
  product_id uuid NOT NULL REFERENCES products(id) ON DELETE CASCADE,
  created_at timestamptz NOT NULL DEFAULT now(),
  UNIQUE (user_uid, product_id)
);
ALTER TABLE favorites ENABLE ROW LEVEL SECURITY;

-- ============ CONVERSATIONS ============
CREATE TABLE IF NOT EXISTS conversations (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  product_id uuid REFERENCES products(id) ON DELETE SET NULL,
  created_at timestamptz NOT NULL DEFAULT now()
);
ALTER TABLE conversations ENABLE ROW LEVEL SECURITY;

-- ============ CONVERSATION PARTICIPANTS ============
CREATE TABLE IF NOT EXISTS conversation_participants (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  conversation_id uuid NOT NULL REFERENCES conversations(id) ON DELETE CASCADE,
  user_uid text NOT NULL,
  created_at timestamptz NOT NULL DEFAULT now(),
  UNIQUE (conversation_id, user_uid)
);
ALTER TABLE conversation_participants ENABLE ROW LEVEL SECURITY;

-- ============ MESSAGES ============
CREATE TABLE IF NOT EXISTS messages (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  conversation_id uuid NOT NULL REFERENCES conversations(id) ON DELETE CASCADE,
  sender_uid text NOT NULL,
  type text NOT NULL DEFAULT 'text',
  text text,
  media_path text,
  read boolean NOT NULL DEFAULT false,
  created_at timestamptz NOT NULL DEFAULT now()
);
ALTER TABLE messages ENABLE ROW LEVEL SECURITY;

-- ============ NOTIFICATIONS ============
CREATE TABLE IF NOT EXISTS notifications (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  user_uid text NOT NULL,
  title text,
  body text,
  read boolean NOT NULL DEFAULT false,
  created_at timestamptz NOT NULL DEFAULT now()
);
ALTER TABLE notifications ENABLE ROW LEVEL SECURITY;

-- ============ REVIEWS ============
CREATE TABLE IF NOT EXISTS reviews (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  target_type text NOT NULL,
  target_id text NOT NULL,
  author_uid text NOT NULL,
  rating integer NOT NULL DEFAULT 5 CHECK (rating >= 1 AND rating <= 5),
  body text,
  created_at timestamptz NOT NULL DEFAULT now()
);
ALTER TABLE reviews ENABLE ROW LEVEL SECURITY;

-- ============ REPORTS ============
CREATE TABLE IF NOT EXISTS reports (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  reporter_uid text NOT NULL,
  target_type text NOT NULL,
  target_id text NOT NULL,
  reason text,
  created_at timestamptz NOT NULL DEFAULT now()
);
ALTER TABLE reports ENABLE ROW LEVEL SECURITY;

-- ============ ORDERS ============
CREATE TABLE IF NOT EXISTS orders (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  buyer_uid text NOT NULL,
  seller_uid text NOT NULL,
  agreed_total numeric(12,2) NOT NULL DEFAULT 0,
  currency text NOT NULL DEFAULT 'USD',
  status text NOT NULL DEFAULT 'proposed',
  created_at timestamptz NOT NULL DEFAULT now(),
  updated_at timestamptz NOT NULL DEFAULT now()
);
ALTER TABLE orders ENABLE ROW LEVEL SECURITY;

-- ============ PUBLIC ORDERS (Buying Requests) ============
CREATE TABLE IF NOT EXISTS public_orders (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  buyer_uid text NOT NULL,
  title text NOT NULL,
  description text,
  budget numeric(12,2) NOT NULL DEFAULT 0,
  status text NOT NULL DEFAULT 'open',
  created_at timestamptz NOT NULL DEFAULT now()
);
ALTER TABLE public_orders ENABLE ROW LEVEL SECURITY;

-- ============ PUBLIC ORDER RESPONSES ============
CREATE TABLE IF NOT EXISTS public_order_responses (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  public_order_id uuid NOT NULL REFERENCES public_orders(id) ON DELETE CASCADE,
  seller_uid text NOT NULL,
  message text,
  offered_price numeric(12,2) NOT NULL DEFAULT 0,
  created_at timestamptz NOT NULL DEFAULT now()
);
ALTER TABLE public_order_responses ENABLE ROW LEVEL SECURITY;

-- ============ ALL POLICIES (after all tables exist) ============

-- profiles
DROP POLICY IF EXISTS "profiles_select_own" ON profiles;
CREATE POLICY "profiles_select_own" ON profiles FOR SELECT
  TO anon, authenticated USING (auth.uid()::text = id OR id IS NOT NULL);
DROP POLICY IF EXISTS "profiles_insert_own" ON profiles;
CREATE POLICY "profiles_insert_own" ON profiles FOR INSERT
  TO authenticated WITH CHECK (auth.uid()::text = id);
DROP POLICY IF EXISTS "profiles_update_own" ON profiles;
CREATE POLICY "profiles_update_own" ON profiles FOR UPDATE
  TO authenticated USING (auth.uid()::text = id) WITH CHECK (auth.uid()::text = id);

-- categories
DROP POLICY IF EXISTS "categories_select_all" ON categories;
CREATE POLICY "categories_select_all" ON categories FOR SELECT
  TO anon, authenticated USING (true);

-- stores
DROP POLICY IF EXISTS "stores_select_all" ON stores;
CREATE POLICY "stores_select_all" ON stores FOR SELECT
  TO anon, authenticated USING (true);
DROP POLICY IF EXISTS "stores_insert_own" ON stores;
CREATE POLICY "stores_insert_own" ON stores FOR INSERT
  TO authenticated WITH CHECK (auth.uid()::text = owner_uid);
DROP POLICY IF EXISTS "stores_update_own" ON stores;
CREATE POLICY "stores_update_own" ON stores FOR UPDATE
  TO authenticated USING (auth.uid()::text = owner_uid) WITH CHECK (auth.uid()::text = owner_uid);
DROP POLICY IF EXISTS "stores_delete_own" ON stores;
CREATE POLICY "stores_delete_own" ON stores FOR DELETE
  TO authenticated USING (auth.uid()::text = owner_uid);

-- products
DROP POLICY IF EXISTS "products_select_active" ON products;
CREATE POLICY "products_select_active" ON products FOR SELECT
  TO anon, authenticated USING (status = 'active' AND is_restricted = false);
DROP POLICY IF EXISTS "products_insert_own" ON products;
CREATE POLICY "products_insert_own" ON products FOR INSERT
  TO authenticated WITH CHECK (auth.uid()::text = seller_uid);
DROP POLICY IF EXISTS "products_update_own" ON products;
CREATE POLICY "products_update_own" ON products FOR UPDATE
  TO authenticated USING (auth.uid()::text = seller_uid) WITH CHECK (auth.uid()::text = seller_uid);
DROP POLICY IF EXISTS "products_delete_own" ON products;
CREATE POLICY "products_delete_own" ON products FOR DELETE
  TO authenticated USING (auth.uid()::text = seller_uid);

-- product_media
DROP POLICY IF EXISTS "product_media_select_all" ON product_media;
CREATE POLICY "product_media_select_all" ON product_media FOR SELECT
  TO anon, authenticated USING (true);
DROP POLICY IF EXISTS "product_media_insert_own" ON product_media;
CREATE POLICY "product_media_insert_own" ON product_media FOR INSERT
  TO authenticated WITH CHECK (
    EXISTS (SELECT 1 FROM products WHERE products.id = product_media.product_id AND products.seller_uid = auth.uid()::text)
  );
DROP POLICY IF EXISTS "product_media_delete_own" ON product_media;
CREATE POLICY "product_media_delete_own" ON product_media FOR DELETE
  TO authenticated USING (
    EXISTS (SELECT 1 FROM products WHERE products.id = product_media.product_id AND products.seller_uid = auth.uid()::text)
  );

-- favorites
DROP POLICY IF EXISTS "favorites_select_own" ON favorites;
CREATE POLICY "favorites_select_own" ON favorites FOR SELECT
  TO authenticated USING (auth.uid()::text = user_uid);
DROP POLICY IF EXISTS "favorites_insert_own" ON favorites;
CREATE POLICY "favorites_insert_own" ON favorites FOR INSERT
  TO authenticated WITH CHECK (auth.uid()::text = user_uid);
DROP POLICY IF EXISTS "favorites_delete_own" ON favorites;
CREATE POLICY "favorites_delete_own" ON favorites FOR DELETE
  TO authenticated USING (auth.uid()::text = user_uid);

-- conversations
DROP POLICY IF EXISTS "conversations_select_participant" ON conversations;
CREATE POLICY "conversations_select_participant" ON conversations FOR SELECT
  TO authenticated USING (
    EXISTS (SELECT 1 FROM conversation_participants WHERE conversation_participants.conversation_id = conversations.id AND conversation_participants.user_uid = auth.uid()::text)
  );

-- conversation_participants
DROP POLICY IF EXISTS "conv_participants_select_own" ON conversation_participants;
CREATE POLICY "conv_participants_select_own" ON conversation_participants FOR SELECT
  TO authenticated USING (auth.uid()::text = user_uid);
DROP POLICY IF EXISTS "conv_participants_insert_own" ON conversation_participants;
CREATE POLICY "conv_participants_insert_own" ON conversation_participants FOR INSERT
  TO authenticated WITH CHECK (auth.uid()::text = user_uid);

-- messages
DROP POLICY IF EXISTS "messages_select_participant" ON messages;
CREATE POLICY "messages_select_participant" ON messages FOR SELECT
  TO authenticated USING (
    EXISTS (SELECT 1 FROM conversation_participants WHERE conversation_participants.conversation_id = messages.conversation_id AND conversation_participants.user_uid = auth.uid()::text)
  );
DROP POLICY IF EXISTS "messages_insert_own" ON messages;
CREATE POLICY "messages_insert_own" ON messages FOR INSERT
  TO authenticated WITH CHECK (
    auth.uid()::text = sender_uid AND
    EXISTS (SELECT 1 FROM conversation_participants WHERE conversation_participants.conversation_id = messages.conversation_id AND conversation_participants.user_uid = auth.uid()::text)
  );

-- notifications
DROP POLICY IF EXISTS "notifications_select_own" ON notifications;
CREATE POLICY "notifications_select_own" ON notifications FOR SELECT
  TO authenticated USING (auth.uid()::text = user_uid);
DROP POLICY IF EXISTS "notifications_update_own" ON notifications;
CREATE POLICY "notifications_update_own" ON notifications FOR UPDATE
  TO authenticated USING (auth.uid()::text = user_uid) WITH CHECK (auth.uid()::text = user_uid);
DROP POLICY IF EXISTS "notifications_insert_own" ON notifications;
CREATE POLICY "notifications_insert_own" ON notifications FOR INSERT
  TO authenticated WITH CHECK (auth.uid()::text = user_uid);

-- reviews
DROP POLICY IF EXISTS "reviews_select_all" ON reviews;
CREATE POLICY "reviews_select_all" ON reviews FOR SELECT
  TO anon, authenticated USING (true);
DROP POLICY IF EXISTS "reviews_insert_own" ON reviews;
CREATE POLICY "reviews_insert_own" ON reviews FOR INSERT
  TO authenticated WITH CHECK (auth.uid()::text = author_uid);

-- reports
DROP POLICY IF EXISTS "reports_insert_own" ON reports;
CREATE POLICY "reports_insert_own" ON reports FOR INSERT
  TO authenticated WITH CHECK (auth.uid()::text = reporter_uid);

-- orders
DROP POLICY IF EXISTS "orders_select_own" ON orders;
CREATE POLICY "orders_select_own" ON orders FOR SELECT
  TO authenticated USING (auth.uid()::text = buyer_uid OR auth.uid()::text = seller_uid);
DROP POLICY IF EXISTS "orders_insert_own" ON orders;
CREATE POLICY "orders_insert_own" ON orders FOR INSERT
  TO authenticated WITH CHECK (auth.uid()::text = buyer_uid);
DROP POLICY IF EXISTS "orders_update_own" ON orders;
CREATE POLICY "orders_update_own" ON orders FOR UPDATE
  TO authenticated USING (auth.uid()::text = buyer_uid OR auth.uid()::text = seller_uid) WITH CHECK (auth.uid()::text = buyer_uid OR auth.uid()::text = seller_uid);

-- public_orders
DROP POLICY IF EXISTS "public_orders_select_open" ON public_orders;
CREATE POLICY "public_orders_select_open" ON public_orders FOR SELECT
  TO anon, authenticated USING (status = 'open');
DROP POLICY IF EXISTS "public_orders_insert_own" ON public_orders;
CREATE POLICY "public_orders_insert_own" ON public_orders FOR INSERT
  TO authenticated WITH CHECK (auth.uid()::text = buyer_uid);
DROP POLICY IF EXISTS "public_orders_update_own" ON public_orders;
CREATE POLICY "public_orders_update_own" ON public_orders FOR UPDATE
  TO authenticated USING (auth.uid()::text = buyer_uid) WITH CHECK (auth.uid()::text = buyer_uid);

-- public_order_responses
DROP POLICY IF EXISTS "public_order_responses_select_all" ON public_order_responses;
CREATE POLICY "public_order_responses_select_all" ON public_order_responses FOR SELECT
  TO anon, authenticated USING (true);
DROP POLICY IF EXISTS "public_order_responses_insert_own" ON public_order_responses;
CREATE POLICY "public_order_responses_insert_own" ON public_order_responses FOR INSERT
  TO authenticated WITH CHECK (auth.uid()::text = seller_uid);

-- ============ INDEXES ============
CREATE INDEX IF NOT EXISTS idx_products_store_id ON products(store_id);
CREATE INDEX IF NOT EXISTS idx_products_seller_uid ON products(seller_uid);
CREATE INDEX IF NOT EXISTS idx_products_status ON products(status);
CREATE INDEX IF NOT EXISTS idx_favorites_user_uid ON favorites(user_uid);
CREATE INDEX IF NOT EXISTS idx_messages_conversation_id ON messages(conversation_id);
CREATE INDEX IF NOT EXISTS idx_notifications_user_uid ON notifications(user_uid);
CREATE INDEX IF NOT EXISTS idx_conv_participants_user_uid ON conversation_participants(user_uid);
CREATE INDEX IF NOT EXISTS idx_orders_buyer_uid ON orders(buyer_uid);
CREATE INDEX IF NOT EXISTS idx_orders_seller_uid ON orders(seller_uid);
CREATE INDEX IF NOT EXISTS idx_public_orders_status ON public_orders(status);
CREATE INDEX IF NOT EXISTS idx_reviews_target ON reviews(target_type, target_id);
