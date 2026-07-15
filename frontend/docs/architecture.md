# StudyFlow AI — Architecture Guide

## Overview

StudyFlow AI uses **Feature-First Clean Architecture** — a scalable pattern where the codebase is organized by feature, and each feature has three internal layers (domain, presentation, data) rather than grouping all screens in one place or all models in one place.

## Directory Map

```
lib/
├── main.dart                    # App entry point (ProviderScope + MaterialApp)
├── config/                      # App-wide configuration
│   ├── environment/             # Environment settings (API URLs, flavors)
│   ├── routing/                 # GoRouter setup and route constants
│   ├── theme/                   # Material 3 design tokens and ThemeData
│   ├── di/                      # Dependency injection (Riverpod + GetIt stub)
│   └── localization/            # i18n setup (English default, future languages)
├── core/                        # Shared infrastructure (no UI)
│   ├── constants/               # App-wide constants, asset paths, API endpoints
│   ├── errors/                  # Exception hierarchy → Failure types → ErrorHandler
│   ├── network/                 # Dio client stub, interceptors, NetworkInfo
│   ├── storage/                 # Hive box manager stubs, StorageKeys
│   └── utils/                   # Logger, Validators, DateFormatter, Result<T>, extensions
├── shared/                      # Reusable UI components used across features
│   ├── widgets/                 # Buttons, cards, inputs, dialogs, layouts, state widgets
│   ├── extensions/              # Feature-specific Dart extensions
│   └── mixins/                  # ValidationMixin, LoadingStateMixin
├── features/                    # Feature modules (14 total)
│   ├── splash/
│   ├── onboarding/
│   ├── authentication/
│   ├── dashboard/
│   ├── semesters/
│   ├── subjects/
│   ├── notes/
│   ├── assignments/
│   ├── quizzes/
│   ├── schedules/
│   ├── grades/
│   ├── profile/
│   ├── settings/
│   └── ai_assistant/            # Future AI feature placeholder
└── legacy/                      # Bridge: existing screens during migration
    └── index.dart               # Barrel exports for legacy code
```

## Layers Explained

### config/ — Configuration Layer
Centralises everything that configures the app at startup.

| File | Purpose |
|------|---------|
| `environment/app_config.dart` | API base URL |
| `environment/flavor_config.dart` | Dev/staging/prod settings |
| `routing/app_router.dart` | GoRouter definition |
| `routing/route_paths.dart` | Type-safe route path constants |
| `routing/route_guards.dart` | Auth redirect guard |
| `theme/app_theme.dart` | `AppTheme.lightTheme` — full Material 3 ThemeData |
| `theme/app_colors.dart` | Brand and semantic color palette |
| `theme/app_typography.dart` | Poppins-based text styles |
| `theme/app_spacing.dart` | 8dp grid spacing constants |
| `theme/app_radius.dart` | Border radius constants |
| `theme/app_shadows.dart` | Elevation shadow definitions |
| `di/service_locator.dart` | GetIt setup (Phase 2) |
| `di/provider_container.dart` | Riverpod provider hierarchy docs |

### core/ — Infrastructure Layer
Shared utilities with **no Flutter UI dependency** (except extensions/context).

| Directory | Purpose |
|-----------|---------|
| `constants/` | `AppConstants`, `ApiEndpoints`, `AppAssets` |
| `errors/` | `AppException` subtypes, `Failure` subtypes, `ErrorHandler` |
| `network/` | `DioClient`, `AuthInterceptor`, `NetworkInfo`, `ApiResponse<T>` |
| `storage/` | `StorageKeys`, `BoxManager`, `AppHiveService` |
| `utils/` | `Logger`, `Validators`, `DateFormatter`, `Result<T>`, extensions |

### shared/ — Shared UI Components
Reusable widgets used by multiple features. All widgets use **design tokens only** — no hardcoded colors, sizes, or spacing.

| Widget | Purpose |
|--------|---------|
| `PrimaryButton` | Main CTA button with loading state |
| `SecondaryButton` | Outlined secondary action button |
| `IconButtonCustom` | Icon-only action button |
| `AppTextField` | Material 3 form field with validation |
| `SearchBarCustom` | Pill-shaped search input |
| `AppCard` | Base tappable card with shadow/border |
| `LoadingWidget` | Centered spinner with optional message |
| `EmptyState` | Empty list placeholder with optional action |
| `ErrorState` | Error display with retry button |
| `AppScaffold` | Standardized page scaffold |
| `ResponsiveContainer` | Max-width constrained layout |

### features/ — Feature Modules
Each feature is self-contained with three layers:

```
features/{name}/
├── domain/         ← Pure Dart — no Flutter imports
│   ├── entities/   ← Immutable business objects
│   ├── repositories/ ← Abstract repository interfaces
│   └── usecases/   ← Single-purpose business operations
├── presentation/   ← Flutter UI
│   ├── screens/    ← Full-page views (ConsumerWidget)
│   ├── widgets/    ← Feature-specific widgets
│   └── providers/  ← Riverpod StateNotifier providers
└── data/           ← External data access
    ├── models/     ← Data objects with JSON/Hive serialization
    ├── datasources/ ← API and Hive data source implementations
    └── repositories/ ← Repository implementations (offline-first)
```

**Dependency rule:** `domain/` must never import from `presentation/` or `data/`.

### legacy/ — Migration Bridge
All existing screens (`lib/screens/`) and services (`lib/notesApiServices/`) are preserved exactly as-is. The `lib/legacy/index.dart` barrel file re-exports them for new code to reference during migration. See `docs/migration_guide.md` for the step-by-step process.

## State Management (Riverpod)

Provider types used:

| Type | When to use |
|------|------------|
| `Provider` | Immutable singleton services |
| `StateProvider` | Simple bool/int/enum state |
| `FutureProvider` | One-time async fetch |
| `StreamProvider` | Continuous streams (Firebase Auth) |
| `StateNotifierProvider` | Complex state with CRUD operations |

## Navigation (GoRouter)

All routes are defined in `config/routing/app_router.dart`. Always navigate using `RoutePaths` constants:

```dart
// ✅ Correct
context.go(RoutePaths.login);
context.go(RoutePaths.noteDetailPath(noteId));

// ❌ Never use magic strings
context.go('/login');
```

## Error Handling Pattern

```dart
// Repository returns Result<T>
final result = await noteRepository.createNote(params);

// Widget or notifier handles both outcomes
result.fold(
  (failure) => ErrorHandler.showError(context, failure),
  (note) => navigateToNote(note.id),
);
```

## Adding a New Feature

1. Create the folder structure under `lib/features/{name}/`
2. Define entities in `domain/entities/`
3. Define repository interface in `domain/repositories/`
4. Implement use cases in `domain/usecases/`
5. Create models in `data/models/`
6. Implement data sources in `data/datasources/`
7. Implement repository in `data/repositories/`
8. Create screen(s) in `presentation/screens/`
9. Add providers in `presentation/providers/`
10. Register routes in `config/routing/app_router.dart`
