'use strict';
const MANIFEST = 'flutter-app-manifest';
const TEMP = 'flutter-temp-cache';
const CACHE_NAME = 'flutter-app-cache';

const RESOURCES = {"version.json": "18c6d2b396ceadfb5e4b39f4ab823b67",
"index.html": "cf937fb177d2a836d1ab0da82b912afe",
"/": "cf937fb177d2a836d1ab0da82b912afe",
"main.dart.js": "771af94c86ca26336accd4b9431eb00f",
"flutter.js": "6fef97aeca90b426343ba6c5c9dc5d4a",
"favicon.png": "19cddeda0dabf5a73472924e6a4269c9",
"icons/Icon-192.png": "b5bac01115b6620160e161c4ec4c164e",
"icons/Icon-maskable-512.png": "21565b37133b1e2e609ccf4424bc2887",
"icons/Icon-512.png": "21565b37133b1e2e609ccf4424bc2887",
"icons/Icon-maskable-192.png": "b5bac01115b6620160e161c4ec4c164e",
"manifest.json": "4b3eea7753b9099cfed50e57e748d13d",
"assets/AssetManifest.json": "7b01f9edaf8e1ab305213458f09fde50",
"assets/NOTICES": "4a1d69441c11f8ecde47a8c7424bd2c7",
"assets/FontManifest.json": "dc3d03800ccca4601324923c0b1d6d57",
"assets/packages/cupertino_icons/assets/CupertinoIcons.ttf": "e986ebe42ef785b27164c36a9abc7818",
"assets/shaders/ink_sparkle.frag": "f8b80e740d33eb157090be4e995febdf",
"assets/AssetManifest.bin": "2d780039e8b3c2d91f1ff03cc84590aa",
"assets/fonts/MaterialIcons-Regular.otf": "45ba107693688fbf8362aab6c909ed94",
"assets/assets/logo/icon.png": "21565b37133b1e2e609ccf4424bc2887",
"assets/assets/logo/plate_emblem.png": "3eaa353718b1c6ad5d6f8d09ebd69516",
"assets/assets/logo/logo.jpg": "9697f16ee557230d7b1758e55ce9e7bb",
"assets/assets/icons/mushroom.png": "50fdb891b08a6a69d89035467e6d6584",
"assets/assets/icons/soups.png": "d56556b9c74ae876f331f6f85a47a64d",
"assets/assets/icons/broth.png": "8a144f74d71604a4fa9369b2ba99322c",
"assets/assets/icons/peach.png": "acba99d0faddd85917726fca78e5815a",
"assets/assets/icons/cake.png": "62bfc2bad1a07d0cf9974da825c09457",
"assets/assets/icons/spaghetti.png": "429852c8a2c86a1bb589aafd464a73d2",
"assets/assets/icons/coffee.png": "d3f697fc3be707eec25ffa48b31f1b8d",
"assets/assets/icons/av_frog.png": "40b4f79a9c8719ee2fc75c688786a01a",
"assets/assets/icons/cocktail.png": "11258e8d7e29230ce7e0820431016b7f",
"assets/assets/icons/pancakes.png": "5b95f92caaa13032beef971b247f487d",
"assets/assets/icons/paella.png": "13cc211eeb3a5bea0e5817e5b51f2b02",
"assets/assets/icons/av_woman.png": "859ed523eb488ce543dd0f21d5c57a95",
"assets/assets/icons/av_unicorn.png": "52448c59bc04a42a66f466306e34af13",
"assets/assets/icons/bread.png": "2bd5d2892161b9343e6c06757a1956bf",
"assets/assets/icons/potato.png": "d6e77bb760a9bce8c4c6e9a3315dd20f",
"assets/assets/icons/av_fox.png": "d2d3e1d85082d401037ba5c54d7a230b",
"assets/assets/icons/salt.png": "4d8e276dc8041d1188952146a6393938",
"assets/assets/icons/mains.png": "054852d94dc36309beaf0c81863f8242",
"assets/assets/icons/coconut.png": "6a986a98433a964775e5fe0e99620a11",
"assets/assets/icons/carrot.png": "218e4ed4a4c845fc52706622eead2489",
"assets/assets/icons/cookie.png": "b89be32c90c90129c5a610197692251f",
"assets/assets/icons/beans.png": "1e42eda68a8f5f3e497a332b5ada39b3",
"assets/assets/icons/chicken.png": "ada7ff8fd29abe717f0ea936872498d4",
"assets/assets/icons/honey.png": "6d172946cbc2da307346e614f5a6b5e9",
"assets/assets/icons/shrimp.png": "87d9ce8d63477d12d1ce67f21a2932d5",
"assets/assets/icons/milk.png": "6c0859804a5e11b199fce7f6a86fd106",
"assets/assets/icons/onion.png": "64b550cd3c7fc7ba5a83003b68000588",
"assets/assets/icons/av_man.png": "36ce73d4958b70da65dad871218f1518",
"assets/assets/icons/butter.png": "cfb5fb0e72e1f6c29505f00dfd13861e",
"assets/assets/icons/falafel.png": "1ed52877992a3e615d3d6b04c090340f",
"assets/assets/icons/noodle_soup.png": "4fac38e3188bb483bc3f640be95f683a",
"assets/assets/icons/blueberries.png": "9cc3606a78d97961d1e820a35ebefc5f",
"assets/assets/icons/tomato.png": "650d23eace9362e10eb43dc99b68d9ba",
"assets/assets/icons/target.png": "0d612cae33485e451f063800eebb0bcd",
"assets/assets/icons/av_bear.png": "c11fa3cf94290876127778ffabecb7fd",
"assets/assets/icons/croissant.png": "79d9aee2ca0502c08c2136c58404565f",
"assets/assets/icons/av_cat.png": "3f730bda5b22129303e58a1169f51b94",
"assets/assets/icons/dinner.png": "8ee48d37ac548bf39318ba4f54e4a60e",
"assets/assets/icons/nuts.png": "7254471be3f200b7bf020faf607748c9",
"assets/assets/icons/meat.png": "d1fca9a313b99427cfbf5bb8251d3440",
"assets/assets/icons/pepper.png": "7df657ebe744b8136ebf8637bb21cad3",
"assets/assets/icons/cherries.png": "3c160ba4e52bfd5096b84d2ec1f14212",
"assets/assets/icons/orange.png": "ca11ee9111a0dd07f0dc1362fedd3d56",
"assets/assets/icons/leafy.png": "cfc3b7f2011b66facc48561c62640b5b",
"assets/assets/icons/av_panda.png": "74c6654941ba2b65df73f6a42dc8d88a",
"assets/assets/icons/calculator.png": "bb667babf7f49d597ef67d3a5db88f77",
"assets/assets/icons/snack.png": "7897a48996716d8c969c8b7a405fb137",
"assets/assets/icons/olive.png": "3b997e3985eada38fd604919f6658b4f",
"assets/assets/icons/baked.png": "f3e4658b0178d3b22615125a9a36a850",
"assets/assets/icons/av_owl.png": "7218e598ee8b0d348a1c9b15fbf2e237",
"assets/assets/icons/cheese.png": "e7e8237ffbe8f9aa3e7dfc962bb69d35",
"assets/assets/icons/garlic.png": "14fb233ce744df2140e3a29e663227d6",
"assets/assets/icons/rice.png": "3164077bb551031d2afbec2f6fe7a17a",
"assets/assets/icons/pear.png": "2c1de5133b766e2c4adf138e99e11f3e",
"assets/assets/icons/avocado.png": "40b0a18d3c4ab406788f2cef1fd8a8b8",
"assets/assets/icons/doughnut.png": "1ed5e1bf1765aeaf8922aac16d4b0e1b",
"assets/assets/icons/water.png": "40715d80752bfcf2bd421dda528fc06b",
"assets/assets/icons/peas.png": "5690a46d6d7856b757dc0b48b41e9de9",
"assets/assets/icons/curry.png": "ca2d8fdcf267bcdaca87e3b01f2f256f",
"assets/assets/icons/smoothie.png": "112f7158bdd5f5c79fb538324f7c07a9",
"assets/assets/icons/icecream.png": "4b9f49a43102615e9796834e15c0b961",
"assets/assets/icons/salad.png": "107e93d7fb7c226862a62aa205d58a8b",
"assets/assets/icons/av_rabbit.png": "e9dd6ed7c4d1e5b0417fb0c7a3edc521",
"assets/assets/icons/bubble_tea.png": "f4dc0923ce31733a0957d37fb18e8046",
"assets/assets/icons/cucumber.png": "857d0ffbd31b9682474b2c2dfffb9cbb",
"assets/assets/icons/lemon.png": "55a9f58226465285806c52f49adcb103",
"assets/assets/icons/banana.png": "697d5736e8b3354af0baa9fc48d4bd88",
"assets/assets/icons/kitchen.png": "7c9f444cb24b15b69a1aa812fc49e191",
"assets/assets/icons/sandwich.png": "73754aa900a0869ba3f4df965a8a3986",
"assets/assets/icons/lunch.png": "f326a05cff5ece1d57749b43e96df8dd",
"assets/assets/icons/beetroot.png": "7f0062b2828cde3a61e2ba6e44cb789a",
"assets/assets/icons/strawberry.png": "b1d5f1b4b8f037968c8011f960fd412a",
"assets/assets/icons/egg.png": "fff6baf127acdda324a3d734bcf43423",
"assets/assets/icons/breakfast.png": "502a2ebdf095e3856222fd2b740ce2c0",
"assets/assets/icons/drinks.png": "d3f697fc3be707eec25ffa48b31f1b8d",
"assets/assets/icons/tea.png": "e370be0924eaca6f7efad6a71ece3a3b",
"assets/assets/icons/chocolate.png": "797748f07f991a9e171a0274bd075bad",
"assets/assets/icons/kiwi.png": "873b32b62d73a8a393a9a987dada2a90",
"assets/assets/icons/burger.png": "e83251f8930cc8acb5e526c4210bcac9",
"assets/assets/icons/fish.png": "cae43ccdd84c4d1103018426851a32ea",
"assets/assets/icons/pie.png": "0fe7b01634f0a8aca58c7dcaa99b0d92",
"assets/assets/icons/broccoli.png": "709cee704c57cb967e50ad3b5310f68e",
"assets/assets/data/products.json": "c0569fc8c2071ac414872938df2f9b33",
"canvaskit/skwasm.js": "95f16c6690f955a45b2317496983dbe9",
"canvaskit/skwasm.wasm": "1a074e8452fe5e0d02b112e22cdcf455",
"canvaskit/chromium/canvaskit.js": "96ae916cd2d1b7320fff853ee22aebb0",
"canvaskit/chromium/canvaskit.wasm": "be0e3b33510f5b7b0cc76cc4d3e50048",
"canvaskit/canvaskit.js": "bbf39143dfd758d8d847453b120c8ebb",
"canvaskit/canvaskit.wasm": "42df12e09ecc0d5a4a34a69d7ee44314",
"canvaskit/skwasm.worker.js": "51253d3321b11ddb8d73fa8aa87d3b15"};
// The application shell files that are downloaded before a service worker can
// start.
const CORE = ["main.dart.js",
"index.html",
"assets/AssetManifest.json",
"assets/FontManifest.json"];

// During install, the TEMP cache is populated with the application shell files.
self.addEventListener("install", (event) => {
  self.skipWaiting();
  return event.waitUntil(
    caches.open(TEMP).then((cache) => {
      return cache.addAll(
        CORE.map((value) => new Request(value, {'cache': 'reload'})));
    })
  );
});
// During activate, the cache is populated with the temp files downloaded in
// install. If this service worker is upgrading from one with a saved
// MANIFEST, then use this to retain unchanged resource files.
self.addEventListener("activate", function(event) {
  return event.waitUntil(async function() {
    try {
      var contentCache = await caches.open(CACHE_NAME);
      var tempCache = await caches.open(TEMP);
      var manifestCache = await caches.open(MANIFEST);
      var manifest = await manifestCache.match('manifest');
      // When there is no prior manifest, clear the entire cache.
      if (!manifest) {
        await caches.delete(CACHE_NAME);
        contentCache = await caches.open(CACHE_NAME);
        for (var request of await tempCache.keys()) {
          var response = await tempCache.match(request);
          await contentCache.put(request, response);
        }
        await caches.delete(TEMP);
        // Save the manifest to make future upgrades efficient.
        await manifestCache.put('manifest', new Response(JSON.stringify(RESOURCES)));
        // Claim client to enable caching on first launch
        self.clients.claim();
        return;
      }
      var oldManifest = await manifest.json();
      var origin = self.location.origin;
      for (var request of await contentCache.keys()) {
        var key = request.url.substring(origin.length + 1);
        if (key == "") {
          key = "/";
        }
        // If a resource from the old manifest is not in the new cache, or if
        // the MD5 sum has changed, delete it. Otherwise the resource is left
        // in the cache and can be reused by the new service worker.
        if (!RESOURCES[key] || RESOURCES[key] != oldManifest[key]) {
          await contentCache.delete(request);
        }
      }
      // Populate the cache with the app shell TEMP files, potentially overwriting
      // cache files preserved above.
      for (var request of await tempCache.keys()) {
        var response = await tempCache.match(request);
        await contentCache.put(request, response);
      }
      await caches.delete(TEMP);
      // Save the manifest to make future upgrades efficient.
      await manifestCache.put('manifest', new Response(JSON.stringify(RESOURCES)));
      // Claim client to enable caching on first launch
      self.clients.claim();
      return;
    } catch (err) {
      // On an unhandled exception the state of the cache cannot be guaranteed.
      console.error('Failed to upgrade service worker: ' + err);
      await caches.delete(CACHE_NAME);
      await caches.delete(TEMP);
      await caches.delete(MANIFEST);
    }
  }());
});
// The fetch handler redirects requests for RESOURCE files to the service
// worker cache.
self.addEventListener("fetch", (event) => {
  if (event.request.method !== 'GET') {
    return;
  }
  var origin = self.location.origin;
  var key = event.request.url.substring(origin.length + 1);
  // Redirect URLs to the index.html
  if (key.indexOf('?v=') != -1) {
    key = key.split('?v=')[0];
  }
  if (event.request.url == origin || event.request.url.startsWith(origin + '/#') || key == '') {
    key = '/';
  }
  // If the URL is not the RESOURCE list then return to signal that the
  // browser should take over.
  if (!RESOURCES[key]) {
    return;
  }
  // If the URL is the index.html, perform an online-first request.
  if (key == '/') {
    return onlineFirst(event);
  }
  event.respondWith(caches.open(CACHE_NAME)
    .then((cache) =>  {
      return cache.match(event.request).then((response) => {
        // Either respond with the cached resource, or perform a fetch and
        // lazily populate the cache only if the resource was successfully fetched.
        return response || fetch(event.request).then((response) => {
          if (response && Boolean(response.ok)) {
            cache.put(event.request, response.clone());
          }
          return response;
        });
      })
    })
  );
});
self.addEventListener('message', (event) => {
  // SkipWaiting can be used to immediately activate a waiting service worker.
  // This will also require a page refresh triggered by the main worker.
  if (event.data === 'skipWaiting') {
    self.skipWaiting();
    return;
  }
  if (event.data === 'downloadOffline') {
    downloadOffline();
    return;
  }
});
// Download offline will check the RESOURCES for all files not in the cache
// and populate them.
async function downloadOffline() {
  var resources = [];
  var contentCache = await caches.open(CACHE_NAME);
  var currentContent = {};
  for (var request of await contentCache.keys()) {
    var key = request.url.substring(origin.length + 1);
    if (key == "") {
      key = "/";
    }
    currentContent[key] = true;
  }
  for (var resourceKey of Object.keys(RESOURCES)) {
    if (!currentContent[resourceKey]) {
      resources.push(resourceKey);
    }
  }
  return contentCache.addAll(resources);
}
// Attempt to download the resource online before falling back to
// the offline cache.
function onlineFirst(event) {
  return event.respondWith(
    fetch(event.request).then((response) => {
      return caches.open(CACHE_NAME).then((cache) => {
        cache.put(event.request, response.clone());
        return response;
      });
    }).catch((error) => {
      return caches.open(CACHE_NAME).then((cache) => {
        return cache.match(event.request).then((response) => {
          if (response != null) {
            return response;
          }
          throw error;
        });
      });
    })
  );
}
