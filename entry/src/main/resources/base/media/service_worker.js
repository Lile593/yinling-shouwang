// Service Worker for SilverGuard Hub
const CACHE_NAME = 'silverguard-cache-v1';
const STATIC_ASSETS = [
  '/',
  '/pages/Index.ets',
  '/pages/VoicePage.ets',
  '/pages/ResultPage.ets'
];

// 安装Service Worker
self.addEventListener('install', (event) => {
  event.waitUntil(
    caches.open(CACHE_NAME)
      .then((cache) => {
        console.log('Opened cache');
        return cache.addAll(STATIC_ASSETS);
      })
  );
});

// 激活Service Worker
self.addEventListener('activate', (event) => {
  const cacheWhitelist = [CACHE_NAME];
  event.waitUntil(
    caches.keys().then((cacheNames) => {
      return Promise.all(
        cacheNames.map((cacheName) => {
          if (cacheWhitelist.indexOf(cacheName) === -1) {
            return caches.delete(cacheName);
          }
        })
      );
    })
  );
});

// 拦截网络请求
self.addEventListener('fetch', (event) => {
  event.respondWith(
    caches.match(event.request)
      .then((response) => {
        if (response) {
          return response;
        }
        return fetch(event.request)
          .then((response) => {
            if (!response || response.status !== 200 || response.type !== 'basic') {
              return response;
            }
            const responseToCache = response.clone();
            caches.open(CACHE_NAME)
              .then((cache) => {
                cache.put(event.request, responseToCache);
              });
            return response;
          });
      })
  );
});

// 处理后台同步
self.addEventListener('sync', (event) => {
  if (event.tag === 'sync-appointments') {
    event.waitUntil(syncAppointments());
  }
});

// 同步预约单到服务器
async function syncAppointments() {
  try {
    const appointments = await getCachedAppointments();
    if (appointments.length > 0) {
      // 这里可以添加同步到服务器的逻辑
      console.log('Syncing appointments:', appointments);
      // 同步成功后清空缓存
      await clearCachedAppointments();
    }
  } catch (error) {
    console.error('Error syncing appointments:', error);
  }
}

// 获取缓存的预约单
async function getCachedAppointments() {
  const cache = await caches.open(CACHE_NAME);
  const response = await cache.match('/appointments');
  if (response) {
    return await response.json();
  }
  return [];
}

// 缓存预约单
async function cacheAppointment(appointment) {
  const cache = await caches.open(CACHE_NAME);
  const appointments = await getCachedAppointments();
  // 只保留最近50条
  const updatedAppointments = [appointment, ...appointments].slice(0, 50);
  await cache.put('/appointments', new Response(JSON.stringify(updatedAppointments), {
    headers: { 'Content-Type': 'application/json' }
  }));
}

// 清空缓存的预约单
async function clearCachedAppointments() {
  const cache = await caches.open(CACHE_NAME);
  await cache.put('/appointments', new Response(JSON.stringify([]), {
    headers: { 'Content-Type': 'application/json' }
  }));
}