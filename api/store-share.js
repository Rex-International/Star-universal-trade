const SUPABASE_URL = 'https://zfujqsylxzpylxbmouuu.supabase.co';
const SUPABASE_PUBLISHABLE_KEY = 'sb_publishable_JDegKG4KiHGqh4nJeqmT8g_7R5xJ69L';
const FALLBACK_COVER = 'https://images.unsplash.com/photo-1472851294608-062f824d29cc?auto=format&fit=crop&w=1200&q=85';
const COVERS = {
  Electronics: 'https://images.unsplash.com/photo-1511707171634-5f897ff02aa9?auto=format&fit=crop&w=1200&q=85',
  Fashion: 'https://images.unsplash.com/photo-1483985988355-763728e1935b?auto=format&fit=crop&w=1200&q=85',
  'Home & Living': 'https://images.unsplash.com/photo-1600210492486-724fe5c67fb0?auto=format&fit=crop&w=1200&q=85',
  Beauty: 'https://images.unsplash.com/photo-1608248543803-ba4f8c70ae0b?auto=format&fit=crop&w=1200&q=85',
  Office: 'https://images.unsplash.com/photo-1497366754035-f200968a6e72?auto=format&fit=crop&w=1200&q=85',
  Services: 'https://images.unsplash.com/photo-1521737711867-e3b97375f902?auto=format&fit=crop&w=1200&q=85'
};
const esc = value => String(value ?? '').replace(/[&<>"']/g, ch => ({'&':'&amp;','<':'&lt;','>':'&gt;','"':'&quot;',"'":'&#39;'}[ch]));

module.exports = async (req, res) => {
  const id = String(req.query.id || '').trim();
  if (!id || !/^[a-zA-Z0-9-]{8,80}$/.test(id)) {
    res.status(400).setHeader('Content-Type', 'text/html; charset=utf-8');
    return res.end('<!doctype html><title>Store link unavailable</title><h1>Invalid store link</h1>');
  }
  try {
    const endpoint = `${SUPABASE_URL}/rest/v1/stores?id=eq.${encodeURIComponent(id)}&select=id,store_name,description,category_name,country,city,slug,status&limit=1`;
    const response = await fetch(endpoint, { headers: { apikey: SUPABASE_PUBLISHABLE_KEY, Authorization: `Bearer ${SUPABASE_PUBLISHABLE_KEY}` } });
    if (!response.ok) throw new Error(`Store lookup failed (${response.status})`);
    const rows = await response.json();
    const store = rows && rows[0];
    if (!store || store.status && store.status !== 'active') {
      res.status(404).setHeader('Content-Type', 'text/html; charset=utf-8');
      return res.end('<!doctype html><title>Store unavailable</title><h1>This SUT store is unavailable.</h1>');
    }
    const origin = `https://${req.headers.host}`;
    const destination = `${origin}/#/store/${encodeURIComponent(store.id)}`;
    const title = esc(`${store.store_name || 'SUT Store'} | Star Universal Trade`);
    const description = esc((store.description || `${store.category_name || 'Store'} · ${[store.city, store.country].filter(Boolean).join(', ')} · Discover and connect directly on SUT.`).slice(0, 280));
    const image = esc(COVERS[store.category_name] || FALLBACK_COVER);
    const canonical = esc(`${origin}/api/store-share?id=${encodeURIComponent(store.id)}`);
    res.setHeader('Content-Type', 'text/html; charset=utf-8');
    res.setHeader('Cache-Control', 'public, s-maxage=300, stale-while-revalidate=600');
    res.setHeader('X-Content-Type-Options', 'nosniff');
    return res.status(200).end(`<!doctype html><html lang="en"><head><meta charset="utf-8"><meta name="viewport" content="width=device-width,initial-scale=1"><title>${title}</title><meta name="description" content="${description}"><link rel="canonical" href="${canonical}"><meta property="og:type" content="website"><meta property="og:site_name" content="Star Universal Trade"><meta property="og:title" content="${title}"><meta property="og:description" content="${description}"><meta property="og:url" content="${canonical}"><meta property="og:image" content="${image}"><meta property="og:image:width" content="1200"><meta property="og:image:height" content="630"><meta name="twitter:card" content="summary_large_image"><meta name="twitter:title" content="${title}"><meta name="twitter:description" content="${description}"><meta name="twitter:image" content="${image}"><meta http-equiv="refresh" content="0;url=${destination}"><script>location.replace(${JSON.stringify(destination)})</script></head><body><p>Opening <a href="${destination}">${title}</a> on Star Universal Trade…</p></body></html>`);
  } catch (error) {
    console.error('SUT store share preview:', error);
    res.status(503).setHeader('Content-Type', 'text/html; charset=utf-8');
    return res.end('<!doctype html><title>SUT Store</title><h1>Store preview is temporarily unavailable.</h1><p>Please open the store link again later.</p>');
  }
};
