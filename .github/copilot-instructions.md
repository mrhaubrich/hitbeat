# Copilot / AI Assistant Project Instructions

Concise, project-specific guidance for automated coding agents working in this repository.

## 1. Purpose & High-Level Architecture
HitBeat is a desktop-focused Flutter app (Windows/Linux/macOS) built with `flutter_modular` for routing + DI, `drift` for a local SQLite DB, and a JustAudio + MediaKit powered playback pipeline.

Bootstrap flow:
1. `lib/main.dart` ensures bindings, initializes `CoverCacheService`, media backends, and sets an empty native menu (`menubar`).
2. Wraps the app in `ModularApp(module: AppModule(), child: AppWidget())`.
3. `AppWidget` builds a `MaterialApp.router` and lazily initializes `HitbeatAudioHandler` via a FutureBuilder obtaining an injected `IAudioPlayer`.

Modular layering:
- `AppModule` imports `PlayerModule` and sets initial route to Home (`HomeModule`).
- `HomeModule` composes parallel child routes (`/dashboard`, `/tracks`, `/ice-cream`, `/search`, `/settings`) under the HomePage shell + sidebar.
- Feature submodules (e.g. `DashboardModule`, `TrackModule`, `PlayerModule`) provide scoped binds & routes; `PlayerModule` exports audio + metadata services; `DatabaseModule` (currently commented import in Dashboard) exposes `HitBeatDatabase`.

## 2. Dependency Injection & Service Patterns
Use `flutter_modular` binds:
- Exported singletons (`PlayerModule.exportedBinds`) for cross-module availability (e.g. `IAudioPlayer`, `IMetadataExtractor`).
- Regular `binds` for module-local controllers/blocs (e.g. `AddSongsBloc`, `DragNDropBloc`). Prefer `addSingleton` when internal state must persist across routes.
- Acquire via `Modular.get<Type>()`. Avoid manual instantiation—honor existing abstractions: `IAudioPlayer`, `IMetadataExtractor`.

Cover art caching (`CoverCacheService`): static `ensureInitialized()` must run before storing covers; storing returns a hash used in DB tables (`Albums.coverHash`). Don’t attempt async path operations before `ensureInitialized()` completes.

## 3. Database & Data Flow
Drift schema in `src/data/database/database.dart` with tables Artists, Albums, Genres, Tracks, TrackGenres.
- Composite uniqueness: Albums enforce `(name, artistId)`; lookups follow helper methods (`getAlbumByNameAndArtist`).
- Retrieval pattern: Higher-level entity assembly methods wrap multiple table queries (e.g. `getAllDbTracks()` builds `DbTrack` with joined album/artist/genres).
- Conversion: Entities under `src/data/models/*` map DB rows <-> domain objects (`DbTrack.toEntity()` ↔ `Track`). When adding new fields, update both conversion directions and linked table definitions + migrations (increment `schemaVersion`).

## 4. Audio Pipeline
`HitbeatAudioHandler.initialize(player)` (see `audio_handler.dart`) integrates with `audio_service` + OS media controls. Ensure initialization happens once (guarded by `isInitialized`). Use injected `IAudioPlayer` implementation (`AudioPlayerJustAudio`) for playback; metadata extraction through `IMetadataExtractor`.

## 5. UI / Theming Conventions
Global theme defined in `custom_theme.dart` with a custom `SidebarThemeExtension` for sidebar-specific colors. Reuse colors from `colors.dart` or the Theme extension instead of hard-coded literals. For new sidebar visual states, extend `SidebarThemeExtension` rather than introducing ad-hoc constants.

## 6. Routing Patterns
- Root: `'/'` → `HomePage` shell; nested parallel routes each define feature areas.
- For new feature modules: create `<Feature>Module extends Module`, add binds, and integrate with `HomeModule` via `ParallelRoute.module('/feature', module: FeatureModule())`.
- Avoid deep child chains; prefer parallel routes under the shell for simultaneous state (e.g., sidebar selection + active page).

## 7. Adding Media & Files
Dashboard flow for importing songs uses `AddSongsBloc`, `FileHandlerService`, and (optionally) `DatabaseModule` once enabled. Follow existing pattern: parse file → extract metadata → store cover (returns hash) → upsert artist/album/genres → insert track & trackGenres.

## 8. Testing & Analysis
Current tests minimal (`test/widget_test.dart`). For new logic, prefer small unit tests over widget tests. Run:
```bash
flutter test
```
Static analysis/lints:
```bash
flutter analyze
```
Packages: `very_good_analysis` + `flutter_lints`. Keep code doc-commented (existing style uses `///` with {@template}).

## 9. Platform / Desktop Specifics
- Requires Rust (README) for `super_context_menu` build; ensure dev environment has updated toolchain.
- MediaKit libs are platform-specific; when adding new target behaviors, guard initialization flags in `JustAudioMediaKit.ensureInitialized(macOS: true, ...)`.
- Native menus set via `menubar` (`setApplicationMenu([])` currently empty). Extend by providing menu items before `runApp`.

## 10. Conventions & Gotchas
- Prefer async factory initializers (`ensureInitialized`) before DI usage for file-system bound services.
- Use `Modular.setInitialRoute('/dashboard')` inside `HomeModule` for default page; if changing, update sidebar default selection accordingly.
- Do not block UI during audio handler init—keep FutureBuilder pattern; if adding splash logic, chain futures there.
- Album cover hashing uses MD5; changing algorithm would invalidate paths—coordinate migration strategy.
- Keep route strings kebab-case (`/ice-cream`) and DB field names snake_case in maps.

## 11. Safe Extension Points
Add:
- New table: increment `schemaVersion`, write migration, add model + conversion.
- New audio feature: extend `IAudioPlayer` or add service, then bind in `PlayerModule.exportedBinds`.
- Sidebar item: update `widgets/sidebar.dart` and add parallel route in `HomeModule`.

## 12. Quick Checklist for Agents
- Initialize services (don’t remove `ensureInitialized()` calls).
- Use DI, avoid `new` for injected types.
- Keep theme consistency via `Theme.of(context)` & extensions.
- Maintain drift data conversions when adjusting schema.
- Follow module + parallel route pattern for features.

Feedback welcome—clarify database migration strategy or audio handler details if expanding.
