### MultiDevBootcamp – News App Skeleton (Core Data + BuddiesNetwork)

SwiftUI + MVVM app demonstrating a modular architecture:
- Fetch live headlines from NewsAPI using a `BuddiesNetwork`-powered client.
- Persist articles, Favorites, and Read Later with Core Data.
- Three tabs: News, Favorites, Read Later.

---

### Requirements
- Xcode 15+ (iOS 17 SDK)
- iOS 17 simulator or device
- Swift 5.9+

---

### Getting Started
1) Open `MultiDevBootcamp.xcodeproj` in Xcode.
2) Select the `MultiDevBootcamp` scheme and your target device/simulator.
3) Set your NewsAPI key so the News tab fetches real data:
   - Product → Scheme → Edit Scheme… → Run → Arguments → Environment Variables
   - Add key `NEWS_API_KEY` with your API key value
   - The network layer adds the key via `x-api-key` header to requests (e.g., `top-headlines?country=us`).
4) Run.

Notes:
- If the API key is missing or invalid, live fetching will fail; the News tab will only show any previously cached Core Data articles (if present).
- You can later move the key into Keychain (see TODO in `ContentView.swift`).

---

### Project Structure (high-level)
- `MultiDevBootcamp/MultiDevBootcampApp.swift`: App entry point; builds the network stack in `AppDelegate` and sets `NewsAPIClient.shared`.
- `Models/`
  - `NewsArticle.swift`: Domain model used across views.
- `Scenes/`
  - `NewsList/View/NewsListView.swift`: News list UI.
  - `NewsList/ViewModel/NewsListViewModel.swift`: Fetches latest headlines via `NewsAPIClient.watch`, maps to `NewsArticle`, and interacts with storage for toggles.
  - `Favorites/View/FavoritesView.swift`: Favorites-only UI.
  - `Favorites/ViewModel/FavoritesViewModel.swift`: Loads favorite articles from storage.
  - `ReadLater/View/ReadLaterView.swift`: Read Later list UI.
  - `ReadLater/ViewModel/ReadLaterViewModel.swift`: Loads Read Later articles from storage.
- `ViewComponents/`
  - `ArticleRowView.swift`: Row with Favorite and Read Later toggles.
- `Services/`
  - `NewsAPIClient/NewsAPIClient.swift`: Thin wrapper around `BuddiesNetwork` with async/await and streaming (`watch`).
  - `NewsAPIClient/NewsInterceptorProvider.swift`: Interceptor chain: API key injection, retry, network fetch, JSON decoding (ISO-8601 dates).
  - `BasicNewsService.swift`: Temporary stub for simple fetching; currently used only as a dependency placeholder for the Read Later scene.
- `Network/`
  - `EndpointManager.swift`: Endpoints (`everything`, `top-headlines`) and hosts (`prod` → `https://newsapi.org/v2`).
  - `AccessProvider.swift`: Reads `NEWS_API_KEY` from process environment.
  - `NewsAPIModels.swift`: Request/response DTOs (`NewsRequest`, `NewsDataResponse`).
- `Storage/`
  - `CoreData/Manager/CoreDataManager.swift`: Loads `ArticleDatabase` model, configures SQLite store, and exposes a background `NSManagedObjectContext`.
  - `CoreData/NewsDataStorage/Protocols/NewsStorageProtocol.swift`: Storage abstraction used by ViewModels.
  - `CoreData/NewsDataStorage/CoreDataNewsStorage.swift`: Concrete implementation using `ArticleEntity` with `isFavorite` and `isReadLater` flags.
  - `ArticleDatabase.xcdatamodeld`: Core Data model containing `ArticleEntity`.

---

### Data Flow
- News tab
  - On init: loads cached articles from Core Data: `storage.loadArticles()`.
  - On refresh: creates `LatestFetchRequest(query:nil, page:1, pageSize:10, country:"us")` and calls `NewsAPIClient.watch` with cache policy `.returnCacheDataAndFetch`.
  - Maps network response to `[NewsArticle]` for display. Toggling Favorite/Read Later persists to Core Data; if an article is not yet stored, it is saved first.
- Favorites tab
  - Loads favorite articles directly from Core Data: `storage.loadFavoriteArticles()`.
- Read Later tab
  - Loads read-later articles directly from Core Data: `storage.loadReadLaterArticles()`.

Edge cases handled:
- Missing API key → network request fails; the UI remains on cached data if available.
- Core Data operations are guarded; failures surface as simple error messages and logs.

---

### Networking
- Client: `NewsAPIClient` built on `BuddiesNetwork`.
- Interceptors: `ApiKeyProviderInterceptor` (injects `x-api-key` from `AccessProvider`), `MaxRetryInterceptor`, `NetworkFetchInterceptor`, `NewsJSONDecodingInterceptor` (ISO-8601 dates).
- Endpoints: `EndpointManager.Path.topHeadlines.url()` builds `https://newsapi.org/v2/top-headlines` by default.
- Requests: `LatestFetchRequest` encodes `query`, `page`, `pageSize`, `country` into the HTTP operation.
- Streaming: `.watch(..., cachePolicy: .returnCacheDataAndFetch)` yields cached data first (if any), then server data.

---

### Storage
- Abstraction: `NewsStorageProtocol` provides save/load, favorites API, read-later API, filtered loads, and deletion.
- Implementation: `CoreDataNewsStorage` maps `ArticleEntity` ⇄ `NewsArticle` and preserves `isFavorite` / `isReadLater` flags on updates.
- Identifiers: Storage keys use `article.url.absoluteString` when available; otherwise the article `id`.

---

### Known Limitations
- No pagination or search on the News tab yet.
- Error UI is minimal; many failures are logged.
- `BasicNewsService` is a stub; network fetches in the News tab use `NewsAPIClient` instead.
- The QA host in `EndpointManager.Hosts` points to a placeholder and is not used.

---

### Troubleshooting
- 401/403 or "API KEY not found": ensure `NEWS_API_KEY` is set in the scheme and valid.
- Empty lists: verify you have network connectivity and that your API key is authorized for NewsAPI.
- Date decoding errors: the decoder uses ISO-8601; responses must match that format.

---

### Next Steps (Ideas)
- Add pagination and search (e.g., `everything` endpoint with `q`).
- Improve error and empty states; add offline-first behavior.
- Move `NEWS_API_KEY` to Keychain and add an onboarding prompt.
- Unit tests for storage and networking layers.

