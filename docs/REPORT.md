# Symmetry News App — Project Report

## 1. Introduction

When I first opened the project, I felt a mix of excitement and challenge. The assignment combined several technologies I was eager to work with — Flutter, Clean Architecture, BLoC, and Firebase — into a real-world application that demanded pixel-perfect design, solid architecture, and full end-to-end functionality. As someone passionate about building products that work flawlessly, this project was a perfect opportunity to demonstrate my approach to software development: understand the requirements deeply, follow the architecture strictly, and then go beyond what's asked.

The goal was clear: build a cross-platform news application where journalists can browse daily news from NewsAPI and publish their own articles with thumbnails to Firebase (Firestore + Cloud Storage), all following Clean Architecture principles with BLoC state management.

## 2. Learning Journey

### Technologies Learned & Applied

- **Flutter & Dart** — Cross-platform UI framework with a widget-based architecture. I learned to think in terms of widget composition, state management patterns, and platform-specific adaptations.
- **BLoC Pattern** (`flutter_bloc ^9.1.1`) — Event-driven state management that cleanly separates business logic from the UI layer. Each user action becomes an Event, and the UI reacts to State changes.
- **Clean Architecture** — Three-layer separation following Robert C. Martin's principles:
  - **Domain** (pure Dart) — Entities, repository interfaces, and use cases with zero external dependencies
  - **Data** — Models, data sources (Firebase, REST API, local DB), and repository implementations
  - **Presentation** — Screens, widgets, and BLoCs that never touch data sources directly
- **Firebase Firestore** — NoSQL cloud database for storing published articles with server-side timestamps
- **Firebase Cloud Storage** — Media storage for article thumbnails at `media/articles/{articleId}/`
- **Retrofit + Dio** — Type-safe HTTP client for consuming NewsAPI REST endpoints with automatic JSON deserialization
- **Floor (sqflite)** — Local SQLite ORM for offline article bookmarking
- **GetIt** — Service locator pattern for dependency injection, wiring all layers together
- **image_picker** — Cross-platform image selection using `Uint8List` bytes for web compatibility

### Resources Used

- Flutter official documentation (flutter.dev)
- Firebase for Flutter documentation (firebase.google.com)
- BLoC library documentation and migration guides (bloclibrary.dev)
- Clean Architecture principles by Robert C. Martin
- The project's own documentation files (`APP_ARCHITECTURE.md`, `CODING_GUIDELINES.md`, `ARCHITECTURE_VIOLATIONS.md`)
- Reso Coder's Clean Architecture Flutter tutorial (as recommended in the project README)

## 3. Challenges Faced

### 3.1 Cross-Platform Compatibility (Web + Mobile)

**Problem:** `dart:io File` is not available on Flutter Web, which broke the entire image upload flow — from the picker widget through the params, use case, data source, and Firebase upload.

**Solution:** Refactored the complete thumbnail pipeline across all layers to use `Uint8List` bytes + `String fileName` instead of `File` objects:
- `PublishArticleParams` → `thumbnailBytes: Uint8List` + `thumbnailFileName: String`
- `ThumbnailPickerWidget` → `MemoryImage(bytes)` instead of `FileImage(file)`
- Firebase Storage → `putData(bytes)` instead of `putFile(file)` (works on all platforms)

**Lesson:** Always design data contracts platform-agnostically from the start. Using bytes instead of File objects makes the code truly cross-platform without conditional imports.

### 3.2 Firebase Storage CORS

**Problem:** Images uploaded to Firebase Storage loaded correctly on mobile but showed broken image placeholders on web due to browser CORS restrictions.

**Solution:** Configured CORS policy on the Firebase Storage bucket using:
```bash
gsutil cors set cors.json gs://symmetry-news-app-5dcc3.firebasestorage.app
```
With a policy allowing GET/HEAD requests from all origins with a 1-hour cache.

**Lesson:** When building for web, CORS must be explicitly configured on every external service, including Firebase Storage.

### 3.3 NewsAPI CORS on Web

**Problem:** NewsAPI blocks direct browser requests with its CORS policy, returning opaque responses.

**Solution:** Implemented a Dio interceptor that dynamically routes requests through a CORS proxy (`corsproxy.io`) only when `kIsWeb` is true:
```dart
if (kIsWeb) {
  dio.interceptors.add(InterceptorsWrapper(
    onRequest: (options, handler) {
      final original = options.uri.toString();
      options.path = 'https://corsproxy.io/?${Uri.encodeComponent(original)}';
      options.baseUrl = '';
      options.queryParameters = {};
      handler.next(options);
    },
  ));
}
```
Native platforms (Android, iOS) remain completely unaffected.

### 3.4 Local Database on Web

**Problem:** sqflite/Floor crashes on Flutter Web during startup since it relies on native SQLite bindings.

**Solution:** Created `_NoOpAppDatabase` and `_NoOpArticleDao` fallback classes that return empty results on web. The saved-articles feature degrades gracefully — the rest of the app works perfectly:
```dart
if (kIsWeb) {
  try {
    database = await $FloorAppDatabase.inMemoryDatabaseBuilder().build();
  } catch (_) {
    database = _NoOpAppDatabase();
  }
}
```

### 3.5 Xcode 26 Code Signing (macOS/iOS)

**Problem:** Xcode 26 beta adds an irremovable `com.apple.provenance` extended attribute to all copied framework files, making code signing fail with "resource fork, Finder information, or similar detritus not allowed."

**Solution:** After exhaustive investigation (patching Flutter SDK's `removeFinderExtendedAttributes`, clearing xattrs from build folders, trying `CODE_SIGNING_ALLOWED=NO`), this was confirmed as an unresolvable Apple beta bug. The app targets web and Android for demo purposes while the code remains fully cross-platform for when Apple ships the fix.

## 4. Reflection and Future Directions

### What I Learned

- **Clean Architecture discipline** — The strict layer separation felt verbose at first (creating entities, models, use cases, repositories, data sources for each feature), but it pays off immediately when adding new features. Adding delete/update functionality required minimal changes to existing code because each layer has a single responsibility.

- **BLoC predictability** — The event → state flow makes the app behavior completely deterministic. Every state transition is explicit, making debugging straightforward. The `BlocConsumer` pattern (listening for side effects while building UI from states) is particularly elegant.

- **Cross-platform thinking** — Building for web, mobile, and desktop simultaneously forces you to design abstractions correctly from the start. The `Uint8List` refactoring taught me that platform-specific types should never leak into domain or data contracts.

- **Firebase as a rapid backend** — With Firestore, Storage, and security rules, I had a production-ready backend without writing a single line of server code. The declarative security rules are powerful for a project of this scope.

### Growth as a Developer

This project strengthened my ability to:
- Navigate unfamiliar codebases and architecture patterns quickly
- Make pragmatic decisions when facing blockers (Xcode 26 bug → pivot to web/Android)
- Follow documentation rigorously while still finding room for innovation
- Build features end-to-end across all architectural layers

### Future Improvements

- **User Authentication** — Firebase Auth for journalist identity, so articles are tied to real users
- **Pagination** — Infinite scroll loading for the article feed using Firestore cursors
- **Offline-first** — Firestore local persistence for reading articles without internet
- **Unit & Widget Tests** — BLoC tests for every event/state transition, widget tests for UI components
- **Article Categories** — Filter by topic (technology, sports, politics) using NewsAPI parameters
- **Push Notifications** — Alert users when new articles are published via Firebase Cloud Messaging

## 5. Proof of the Project

### How to Run

1. Clone the repository:
   ```bash
   git clone https://github.com/Guillegas/SymmetryPrueba.git
   ```
2. Navigate to the frontend:
   ```bash
   cd starter-project/frontend
   ```
3. Install dependencies:
   ```bash
   flutter pub get
   ```
4. Run on Chrome (web):
   ```bash
   flutter run -d chrome
   ```
5. Run on Android (emulator or device):
   ```bash
   flutter run -d android
   ```

### Key Flows to Test

1. **Home screen** loads articles from NewsAPI + Firebase Firestore
2. **Search bar** filters articles in real-time by title, description, or author
3. **Pull to refresh** reloads the entire feed
4. **Tap (+) FAB** → Create Article form with validation
5. **Publish** uploads thumbnail to Storage, saves document to Firestore
6. **Published articles** appear at the top of the home feed
7. **Tap an article** → Detail view with full content
8. **Own articles** show edit/delete options in the detail view's menu (⋮)
9. **Share button** shares article text natively (Android) or via dialog (web)
10. **Bookmark FAB** saves articles locally
11. **Dark mode toggle** (sun/moon icon in the app bar) switches between light and dark themes
12. **Bookmark icon** in the app bar opens saved articles, where articles can be removed

## 6. Overdelivery

### 6.1 New Features Implemented

Beyond the base requirements (browse NewsAPI + publish articles), I implemented **5 additional features**:

#### 🔍 Real-Time Search
- **What:** A search bar at the top of the home screen that filters all articles (both NewsAPI and published) in real-time as you type.
- **How:** Client-side filtering by title, description, and author. Shows "No articles found" when the query matches nothing.
- **Why:** Essential UX feature for any news app — users need to find specific articles quickly.
- **Location:** `lib/features/daily_news/presentation/pages/home/daily_news.dart`

#### 🔄 Pull to Refresh
- **What:** Swipe down on the home screen to reload all articles from both data sources.
- **How:** Uses Flutter's `RefreshIndicator` widget, triggering `GetArticles` event on the `RemoteArticlesBloc`. Also auto-refreshes when returning from the Create Article screen.
- **Why:** Users expect fresh content on demand, especially in a news app.
- **Location:** `lib/features/daily_news/presentation/pages/home/daily_news.dart`

#### ✏️ Full CRUD (Edit & Delete Own Articles)
- **What:** Journalists can edit the title/content of their published articles, or delete them entirely (including the thumbnail from Firebase Storage).
- **How:** Added complete architectural flow following Clean Architecture:
  - **Domain:** `DeleteArticleUseCase`, `UpdateArticleUseCase` with their params
  - **Data:** Extended `ArticlePublisherDataSource` with `deleteArticle()` and `updateArticle()` methods
  - **Presentation:** New `EditArticleScreen`, new BLoC events (`DeleteArticleEvent`, `UpdateArticleEvent`) and states (`ArticlePublisherDeleted`, `ArticlePublisherUpdated`)
  - Own articles are identified by the `firestoreId` field on `ArticleEntity`
  - The detail view shows a popup menu (⋮) with Edit and Delete options only for own articles
  - Delete shows a confirmation dialog before proceeding
- **Why:** A publishing platform without edit/delete is incomplete. This demonstrates full mastery of the Clean Architecture pattern by adding a complete feature across all layers.
- **Location:**
  - `lib/features/article_publisher/domain/use_cases/delete_article_usecase.dart`
  - `lib/features/article_publisher/domain/use_cases/update_article_usecase.dart`
  - `lib/features/article_publisher/presentation/screens/edit_article_screen.dart`

#### 📤 Share Article
- **What:** Share button in the article detail screen that uses the native share sheet (Android) or clipboard-friendly dialog (web).
- **How:** Uses `share_plus` package for native sharing. Composes a message with the article title, description, and URL.
- **Why:** Sharing is a core feature of any news app — readers want to send interesting articles to others.
- **Location:** `lib/features/daily_news/presentation/pages/article_detail/article_detail.dart`

#### 🌙 Dark Mode
- **What:** Toggle between light and dark themes with a single tap on the sun/moon icon in the app bar.
- **How:** Implemented using a `ThemeCubit` (lightweight BLoC) that manages `ThemeMode`. Both `lightTheme()` and `darkTheme()` are defined with appropriate color schemes. The `MaterialApp` responds to theme changes via `BlocBuilder`.
- **Why:** Dark mode is an expected feature in modern apps, improves readability in low-light environments, and reduces battery consumption on OLED screens.
- **Location:**
  - `lib/config/theme/theme_cubit.dart`
  - `lib/config/theme/app_themes.dart`

### 6.2 Prototypes Created

#### Architecture Extension for CRUD
The Edit/Delete feature demonstrates how Clean Architecture scales. Adding a new operation requires touching each layer exactly once:

```
Domain:  UseCase + Params        (pure Dart, no dependencies)
   ↓
Data:    DataSource + Repository (Firebase implementation)
   ↓
Presentation: Event + State + Screen  (UI + BLoC)
   ↓
DI:      Register in GetIt      (injection_container.dart)
```

This pattern can be replicated for any new feature (e.g., comments, likes, user profiles) without modifying existing code — following the Open/Closed Principle.

#### Combined Feed Architecture
The `RemoteArticlesBloc` implements a unified feed pattern that merges articles from two completely different data sources (REST API + Firestore) into a single list:

```dart
// Fetch both sources
final dataState = await _getArticleUseCase();
final publishedState = await _getPublishedArticlesUseCase();

// Merge: published articles at the top
allArticles.insertAll(0, publishedState.data!.map(_mapToArticleEntity));
allArticles.addAll(dataState.data!);
```

This pattern is extensible — additional sources (RSS feeds, other APIs) can be added by simply registering another use case and adding its results to the combined list.

### 6.3 How Can You Improve This

1. **User Authentication** — Firebase Auth would allow multiple journalists, each managing their own articles. The `author` field would come from the authenticated user's profile instead of being hardcoded.

2. **Real-Time Feed Updates** — Replace the one-time Firestore `get()` with a `snapshots()` stream so published articles appear instantly for all users without manual refresh.

3. **Image Compression & Multiple Images** — Add client-side image compression before upload, and support multiple images per article with a gallery view.

4. **Article Categories & Tags** — Let journalists tag articles with categories, and add filter chips on the home screen to browse by topic.

5. **Offline-First Architecture** — Enable Firestore persistence so the app works offline, syncing when connectivity returns.

6. **Testing Suite** — Add unit tests for all BLoCs (event → state transitions), use cases, and repository implementations. Add widget tests for critical UI flows.

7. **CI/CD Pipeline** — GitHub Actions workflow to run tests, analyze code, and build APK/web artifacts on every push.

## 7. Extra Sections

### Web Compatibility Note

The project contains auto-generated JavaScript files (in the `web/` directory) that are required for Firebase to function in the browser. These files are **not application source code** — they are configuration files generated by `flutterfire configure` and are necessary for:
- Firebase SDK initialization on web
- Firebase Auth, Firestore, and Storage web SDKs
- Service worker registration for PWA support

All application logic is written **entirely in Dart/Flutter**, as required by the project specification. The JS files are infrastructure-level dependencies, similar to how `google-services.json` (Android) and `GoogleService-Info.plist` (iOS) are platform-specific configuration files.

### Dependency Injection Architecture

The `injection_container.dart` file serves as the single source of truth for wiring all dependencies:

```
Firebase instances (Firestore, Storage)
    ↓
Data Sources (NewsApiService, ArticlePublisherDataSourceImpl)
    ↓
Repositories (ArticleRepositoryImpl, ArticlePublisherRepositoryImpl)
    ↓
Use Cases (GetArticle, PublishArticle, DeleteArticle, UpdateArticle, ...)
    ↓
BLoCs (RemoteArticlesBloc, LocalArticleBloc, ArticlePublisherBloc)
```

Each layer only depends on the layer above it. BLoCs depend on Use Cases, Use Cases depend on Repository interfaces (not implementations), and only the DI container knows the concrete implementations — achieving full inversion of control.

### Firebase Security Rules

The deployed Firestore and Storage rules enforce:
- **Firestore:** Read/write access for all authenticated operations, field-level validation ensuring `title`, `content`, `author`, `thumbnailUrl`, and `publishedAt` are present
- **Storage:** Maximum 5MB file size, image-only content types, organized under `media/articles/{articleId}/`
