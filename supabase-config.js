// Public Supabase browser configuration. Never place a service_role/secret key here.
(function(){
  const SUPABASE_URL = 'https://zfujqsylxzpylxbmouuu.supabase.co';
  const SUPABASE_PUBLISHABLE_KEY = 'sb_publishable_JDegKG4KiHGqh4nJeqmT8g_7R5xJ69L';
  window.SUT_CONFIG = { cloudinary: { cloudName: 'itmf5kh8', unsignedPreset: 'sut_product_images', folder: 'sut/products' } };
  if (!window.supabase || !window.supabase.createClient) { console.error('Supabase JS library failed to load.'); return; }
  window.sutSupabase = window.supabase.createClient(SUPABASE_URL, SUPABASE_PUBLISHABLE_KEY, { auth: { persistSession: true, autoRefreshToken: true, detectSessionInUrl: true } });
})();
