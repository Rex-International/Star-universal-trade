const CACHE='sut-phase3-cloudinary-single-image-v7-camera-gallery-fix';
const ASSETS=['./','./index.html','./app.js','./supabase-config.js','./styles.css','./manifest.webmanifest','./assets/favicon.svg','./assets/sut-icon.png','./assets/sut-icon-192.png','./assets/sut-icon-512.png','./assets/sut-full-logo.png','./assets/products/bag.svg','./assets/products/beauty.svg','./assets/products/coffee.svg','./assets/products/watch.svg','./assets/products/shoes.svg','./assets/products/power.svg','./assets/products/headphones.svg','./assets/products/office.svg'];
self.addEventListener('install',e=>e.waitUntil(caches.open(CACHE).then(c=>c.addAll(ASSETS)).then(()=>self.skipWaiting())));
self.addEventListener('activate',e=>e.waitUntil(caches.keys().then(keys=>Promise.all(keys.filter(k=>k!==CACHE).map(k=>caches.delete(k)))).then(()=>self.clients.claim())));
self.addEventListener('fetch',e=>{
  if(e.request.method!=='GET')return;
  const url=new URL(e.request.url);
  if(url.origin!==location.origin)return;
  const isAppShell=/\/(?:|index\.html|app\.js|styles\.css|supabase-config\.js|manifest\.webmanifest)$/.test(url.pathname);
  if(isAppShell){
    e.respondWith(fetch(e.request,{cache:'no-store'}).then(r=>{if(r.ok){const copy=r.clone();caches.open(CACHE).then(c=>c.put(e.request,copy))}return r}).catch(()=>caches.match(e.request).then(r=>r||caches.match('./index.html'))));
    return;
  }
  e.respondWith(caches.match(e.request).then(cached=>cached||fetch(e.request).then(r=>{if(r.ok){const copy=r.clone();caches.open(CACHE).then(c=>c.put(e.request,copy))}return r}).catch(()=>caches.match('./index.html'))));
});
