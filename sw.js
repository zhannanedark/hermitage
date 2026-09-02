/* Офлайн-кэш: карта работает и в залах, где сеть не ловит.
   Страница — сеть-первая (обновления доходят сразу, офлайн — из кэша).
   Стили/данные (версионированы ?v=) и картинки — кэш-первый с фоновым обновлением. */
const CACHE='hermitage-v1';
self.addEventListener('install',e=>self.skipWaiting());
self.addEventListener('activate',e=>e.waitUntil(clients.claim()));
self.addEventListener('fetch',e=>{
  if(e.request.method!=='GET')return;
  const u=new URL(e.request.url);
  const ours=u.origin===location.origin;
  const media=/upload\.wikimedia\.org|wikipedia\.org|fonts\.gstatic\.com|fonts\.googleapis\.com/.test(u.host);
  if(!ours&&!media)return;
  const isPage=ours&&(u.pathname.endsWith('.html')||u.pathname.endsWith('/'));
  e.respondWith((async()=>{
    const c=await caches.open(CACHE);
    const net=fetch(e.request).then(r=>{if(r&&r.ok)c.put(e.request,r.clone());return r}).catch(()=>null);
    if(isPage){const r=await net;return r||(await c.match(e.request))||Response.error()}
    const hit=await c.match(e.request);
    if(hit){net;return hit}
    return (await net)||Response.error();
  })());
});
