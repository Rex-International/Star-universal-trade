-- Fix profiles SELECT policy: remove the `OR id IS NOT NULL` hole that made ALL profiles public.
-- Keep owner-scoped read (auth.uid()::text = id) so users can only read their own profile.
DROP POLICY IF EXISTS "profiles_select_own" ON profiles;
CREATE POLICY "profiles_select_own" ON profiles FOR SELECT
  TO anon, authenticated USING (auth.uid()::text = id);