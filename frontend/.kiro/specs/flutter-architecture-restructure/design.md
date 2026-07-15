# Technical Design Document

## Overview

This document specifies the technical architecture for restructuring the StudyFlow AI Flutter application from a flat directory structure to a production-ready Feature-First Clean Architecture. The design establishes clear separation of concerns through layered architecture while preserving all existing functionality during migration.

### Purpose

Transform the existing monolithic Flutter application structure into a scalable, maintainable architecture that:
- Enables feature teams to work independently with minimal conflicts
- Enforces clean separation between UI, business logic, and data access
- Provides a comprehensive Material 3 design system for consistent UI
- Prepares the codebase for future AI feature integration
- Maintains backward compatibility during gradual migration

### Scope

**In Scope:**
- Feature-First Clean Architecture implementation
- Material 3 design system with comprehensive theming
- GoRouter-based navigation architecture
- Riverpod state management configuration
- Reusable widget system design
- Asset management structure
- Localization-ready architecture
- Error handling strategy
- Dependency injection setup
- Offline-ready architecture foundations

**Out of Scope:**
- Code implementation (this is design-only)
- Backend API modifications
- Firebase/Supabase integration details
- Actual feature migration from legacy to new structure
- AI feature implementation

### Key Design Decisions

| Decision | Rationale |
|----------|-----------|
| Feature-First over Layer-First | Features are self-contained, reducing merge conflicts and enabling team autonomy |
| GoRouter over Navigator 2.0 directly | Declarative routing with type-safe navigation and deep linking support |
| Riverpod over Provider/Bloc alone | Compile-time safety, better testability, and improved developer experience |
| Material 3 over Material 2 | Modern design language, better accessibility, improved theming capabilities |
| Hive over other local storage | Already in use, performant, and well-suited for offline-first architecture |
| Gradual migration over big-bang | Minimizes risk, maintains functionality, allows incremental team learning |

## Architecture

### High-Level Architecture Overview

```
┌─────────────────────────────────────────────────────────────┐
│                      Presentation Layer                      │
│  ┌────────────┐  ┌────────────┐  ┌────────────┐             │
│  │  Screens   │  │  Widgets   │  │   Riverpod │             │
│  │            │  │            │  │   Providers│             │
│  └─────┬──────┘  └─────┬──────┘  └─────┬──────┘             │
│        │               │               │                    │
└────────┼───────────────┼───────────────┼────────────────────┘
         │               │               │
┌────────┼───────────────┼───────────────┼────────────────────┐
│        │      Domain (Business Logic) Layer                  │
│  ┌─────▼──────┐  ┌─────▼──────┐  ┌─────▼──────┐             │
│  │  Entities  │  │  Use Cases │  │ Repository │             │
│  │            │  │            │  │ Interfaces │             │
│  └────────────┘  └────────────┘  └─────┬──────┘             │
│                                        │                    │
└────────────────────────────────────────┼────────────────────┘
                                         │
┌────────────────────────────────────────┼────────────────────┐
│               Data Layer               │                    │
│  ┌─────────────┐  ┌─────────────┐  ┌──▼──────────┐         │
│  │   Models    │  │ Data Sources│  │ Repository  │         │
│  │             │  │ (API, Hive) │  │ Impl        │         │
│  └─────────────┘  └─────────────┘  └─────────────┘         │
│                                                             │
└─────────────────────────────────────────────────────────────┘

┌─────────────────────────────────────────────────────────────┐
│                     Core Infrastructure                      │
│   Constants │ Errors │ Network │ Storage │ Utils            │
└─────────────────────────────────────────────────────────────┘

┌─────────────────────────────────────────────────────────────┐
│                    Configuration Layer                       │
│   Environment │ Routing │ Theme │ DI │ Localization        │
└─────────────────────────────────────────────────────────────┘
```

### Architectural Layers

#### 1. Presentation Layer (UI)
- **Screens**: Full-page views orchestrating widgets and state
- **Widgets**: Reusable UI components (stateless/stateful)
- **Providers**: Riverpod state management (StateNotifier, FutureProvider, StreamProvider)
- **Responsibility**: Display data, capture user input, delegate to domain layer

#### 2. Domain Layer (Business Logic)
- **Entities**: Core business objects (immutable, framework-agnostic)
- **Use Cases**: Single-purpose business operations
- **Repository Interfaces**: Abstract contracts for data access
- **Responsibility**: Pure business logic independent of frameworks

#### 3. Data Layer (External Services)
- **Models**: Data transfer objects (JSON serialization)
- **Data Sources**: API clients (Dio), local storage (Hive)
- **Repository Implementations**: Concrete data access with caching/sync logic
- **Responsibility**: Fetch, cache, and persist data

#### 4. Core Infrastructure Layer
- **Constants**: App-wide configuration values
- **Errors**: Custom exception hierarchy
- **Network**: HTTP clients, interceptors, connectivity monitoring
- **Storage**: Hive initialization, box managers
- **Utils**: Helper functions, extensions, validators

#### 5. Configuration Layer
- **Environment**: Development/staging/production configs
- **Routing**: GoRouter configuration with guards
- **Theme**: Material 3 design tokens (colors, typography, spacing)
- **DI**: Service locator/dependency injection setup
- **Localization**: i18n configuration (future)

## Components and Interfaces

### Folder Structure

```
frontend/
├── lib/
│   ├── main.dart                          # App entry point
│   │
│   ├── config/                            # Configuration layer
│   │   ├── environment/
│   │   │   ├── app_config.dart            # Environment settings (API URLs)
│   │   │   └── flavor_config.dart         # Dev/staging/prod flavors
│   │   ├── routing/
│   │   │   ├── app_router.dart            # GoRouter configuration
│   │   │   ├── route_paths.dart           # Route path constants
│   │   │   └── route_guards.dart          # Auth/permission guards
│   │   ├── theme/
│   │   │   ├── app_colors.dart            # Color palette definitions
│   │   │   ├── app_typography.dart        # Text styles
│   │   │   ├── app_spacing.dart           # Spacing constants
│   │   │   ├── app_radius.dart            # Border radius values
│   │   │   ├── app_shadows.dart           # Shadow/elevation
│   │   │   └── app_theme.dart             # Complete theme composition
│   │   ├── di/
│   │   │   ├── service_locator.dart       # GetIt/Riverpod DI setup
│   │   │   └── provider_container.dart    # Global provider configuration
│   │   └── localization/
│   │       ├── app_localizations.dart     # i18n setup (placeholder)
│   │       └── supported_locales.dart     # Locale configuration
│   │
│   ├── core/                              # Core infrastructure
│   │   ├── constants/
│   │   │   ├── app_assets.dart            # Asset path constants
│   │   │   ├── app_constants.dart         # App-wide constants
│   │   │   └── api_endpoints.dart         # API endpoint paths
│   │   ├── errors/
│   │   │   ├── exceptions.dart            # Custom exception classes
│   │   │   ├── failures.dart              # Failure result types
│   │   │   └── error_handler.dart         # Global error handling
│   │   ├── network/
│   │   │   ├── dio_client.dart            # Configured Dio instance
│   │   │   ├── api_interceptor.dart       # Auth/logging interceptors
│   │   │   ├── network_info.dart          # Connectivity checking
│   │   │   └── api_response.dart          # Generic API response wrapper
│   │   ├── storage/
│   │   │   ├── hive_service.dart          # Hive initialization
│   │   │   ├── box_manager.dart           # Type-safe box access
│   │   │   └── storage_keys.dart          # Storage key constants
│   │   └── utils/
│   │       ├── logger.dart                # Logging utility
│   │       ├── validators.dart            # Input validation helpers
│   │       ├── date_formatter.dart        # Date/time utilities
│   │       └── extensions/
│   │           ├── string_extensions.dart
│   │           ├── date_extensions.dart
│   │           └── context_extensions.dart
│   │
│   ├── shared/                            # Shared components
│   │   ├── widgets/
│   │   │   ├── buttons/
│   │   │   │   ├── primary_button.dart
│   │   │   │   ├── secondary_button.dart
│   │   │   │   └── icon_button_custom.dart
│   │   │   ├── cards/
│   │   │   │   ├── note_card.dart
│   │   │   │   ├── semester_card.dart
│   │   │   │   └── file_card.dart
│   │   │   ├── dialogs/
│   │   │   │   ├── confirmation_dialog.dart
│   │   │   │   ├── loading_dialog.dart
│   │   │   │   └── error_dialog.dart
│   │   │   ├── inputs/
│   │   │   │   ├── custom_text_field.dart
│   │   │   │   └── search_bar_custom.dart
│   │   │   └── layouts/
│   │   │       ├── app_scaffold.dart
│   │   │       └── responsive_container.dart
│   │   ├── extensions/
│   │   │   └── (Additional feature-specific extensions)
│   │   └── mixins/
│   │       ├── validation_mixin.dart
│   │       └── loading_state_mixin.dart
│   │
│   ├── features/                          # Feature modules
│   │   ├── splash/
│   │   │   ├── domain/
│   │   │   │   ├── entities/
│   │   │   │   └── repositories/
│   │   │   ├── presentation/
│   │   │   │   ├── screens/
│   │   │   │   │   └── splash_screen.dart
│   │   │   │   ├── widgets/
│   │   │   │   └── providers/
│   │   │   └── data/
│   │   │       ├── models/
│   │   │       ├── datasources/
│   │   │       └── repositories/
│   │   │
│   │   ├── onboarding/
│   │   │   ├── domain/
│   │   │   ├── presentation/
│   │   │   └── data/
│   │   │
│   │   ├── authentication/
│   │   │   ├── domain/
│   │   │   │   ├── entities/
│   │   │   │   │   └── user_entity.dart
│   │   │   │   ├── repositories/
│   │   │   │   │   └── auth_repository.dart
│   │   │   │   └── usecases/
│   │   │   │       ├── sign_in_usecase.dart
│   │   │   │       └── sign_up_usecase.dart
│   │   │   ├── presentation/
│   │   │   │   ├── screens/
│   │   │   │   │   ├── login_screen.dart
│   │   │   │   │   └── signup_screen.dart
│   │   │   │   ├── widgets/
│   │   │   │   │   └── auth_form_field.dart
│   │   │   │   └── providers/
│   │   │   │       └── auth_provider.dart
│   │   │   └── data/
│   │   │       ├── models/
│   │   │       │   └── user_model.dart
│   │   │       ├── datasources/
│   │   │       │   ├── auth_remote_datasource.dart
│   │   │       │   └── auth_local_datasource.dart
│   │   │       └── repositories/
│   │   │           └── auth_repository_impl.dart
│   │   │
│   │   ├── dashboard/
│   │   │   ├── domain/
│   │   │   ├── presentation/
│   │   │   │   ├── screens/
│   │   │   │   │   └── dashboard_screen.dart
│   │   │   │   ├── widgets/
│   │   │   │   │   └── dashboard_card.dart
│   │   │   │   └── providers/
│   │   │   └── data/
│   │   │
│   │   ├── semesters/
│   │   │   ├── domain/
│   │   │   │   ├── entities/
│   │   │   │   │   └── semester_entity.dart
│   │   │   │   ├── repositories/
│   │   │   │   │   └── semester_repository.dart
│   │   │   │   └── usecases/
│   │   │   ├── presentation/
│   │   │   │   ├── screens/
│   │   │   │   ├── widgets/
│   │   │   │   └── providers/
│   │   │   └── data/
│   │   │       ├── models/
│   │   │       │   └── semester_model.dart
│   │   │       ├── datasources/
│   │   │       │   ├── semester_remote_datasource.dart
│   │   │       │   └── semester_local_datasource.dart
│   │   │       └── repositories/
│   │   │
│   │   ├── subjects/
│   │   │   ├── domain/
│   │   │   ├── presentation/
│   │   │   └── data/
│   │   │
│   │   ├── notes/
│   │   │   ├── domain/
│   │   │   │   ├── entities/
│   │   │   │   │   └── note_entity.dart
│   │   │   │   ├── repositories/
│   │   │   │   └── usecases/
│   │   │   │       ├── create_note_usecase.dart
│   │   │   │       ├── update_note_usecase.dart
│   │   │   │       └── sync_notes_usecase.dart
│   │   │   ├── presentation/
│   │   │   │   ├── screens/
│   │   │   │   ├── widgets/
│   │   │   │   └── providers/
│   │   │   └── data/
│   │   │       ├── models/
│   │   │       ├── datasources/
│   │   │       └── repositories/
│   │   │
│   │   ├── assignments/
│   │   ├── quizzes/
│   │   ├── schedules/
│   │   ├── grades/
│   │   ├── profile/
│   │   ├── settings/
│   │   └── ai_assistant/         # Placeholder for future AI features
│   │       ├── domain/
│   │       ├── presentation/
│   │       └── data/
│   │
│   └── legacy/                            # Existing code bridge
│       ├── screens/                       # Original screens preserved
│       │   ├── auth/
│       │   ├── dashboard/
│       │   ├── explore/
│       │   └── splash/
│       ├── notesApiServices/              # Original API services
│       ├── clippers/                      # Custom clippers
│       └── dialogs/                       # Existing dialogs
│
├── assets/                                 # Application assets
│   ├── images/
│   │   ├── splash/
│   │   ├── onboarding/
│   │   └── icons/
│   ├── fonts/
│   │   └── (Custom fonts if any)
│   └── animations/
│       └── (Lottie/Rive files)
│
├── docs/                                   # Documentation
│   ├── architecture.md
│   ├── theme_system.md
│   └── migration_guide.md
│
└── test/                                   # Test structure mirrors lib/
    ├── features/
    ├── core/
    └── shared/
```

### Folder Responsibility Matrix

| Folder | Responsibility | Examples |
|--------|---------------|----------|
| `config/environment/` | Environment-specific configuration | API URLs, feature flags, build configs |
| `config/routing/` | Navigation setup and route definitions | GoRouter config, route guards, deep linking |
| `config/theme/` | Design system tokens and theme composition | Colors, typography, spacing, Material 3 theme |
| `config/di/` | Dependency injection container setup | Service registration, provider configuration |
| `core/constants/` | App-wide constant values | Asset paths, API endpoints, magic numbers |
| `core/errors/` | Error handling infrastructure | Exceptions, failures, error mappers |
| `core/network/` | HTTP client configuration | Dio setup, interceptors, connectivity |
| `core/storage/` | Local storage initialization | Hive setup, box managers, adapters |
| `core/utils/` | Reusable utility functions | Validators, formatters, loggers, extensions |
| `shared/widgets/` | Reusable UI components | Buttons, cards, inputs, dialogs |
| `shared/extensions/` | Dart extension methods | String, DateTime, BuildContext extensions |
| `features/{name}/domain/` | Business logic, entities, repository interfaces | User entity, CreateNote use case |
| `features/{name}/presentation/` | Screens, widgets, state providers | LoginScreen, AuthNotifier |
| `features/{name}/data/` | Data sources, models, repository implementations | NoteModel, HiveDataSource |
| `legacy/` | Preserved existing code | All current screens and services |

## Navigation Architecture (GoRouter)

### Navigation Design

GoRouter provides declarative, type-safe routing with deep linking support. The architecture uses shell routes for persistent bottom navigation and guards for authentication-protected routes.

```
┌─────────────────────────────────────────┐
│           GoRouter Root Config           │
├─────────────────────────────────────────┤
│  /splash       → SplashScreen           │
│  /onboarding   → OnboardingScreen       │
│  /auth                                  │
│  ├── /login    → LoginScreen            │
│  └── /signup   → SignUpScreen           │
│                                         │
│  /app (ShellRoute — main nav)           │
│  ├── /home     → DashboardHome          │
│  ├── /explore  → ExploreScreen         │
│  ├── /schedule → ScheduleScreen         │
│  └── /profile  → ProfileScreen         │
│                                         │
│  Sub-routes (nested under features)     │
│  /semesters/:id → SemesterDetail        │
│  /subjects/:id  → SubjectDetail         │
│  /notes/:id     → NoteDetail            │
│  /grades        → GradeCalculator       │
│  /settings      → SettingsScreen        │
│  /ai            → AIAssistantScreen     │
└─────────────────────────────────────────┘
```

### Router Configuration Design

**File:** `lib/config/routing/app_router.dart`

```dart
// Design — not implementation
// GoRouter configuration contract:

// 1. The router MUST observe Firebase Auth state changes
//    and redirect unauthenticated users to /auth/login
// 2. The router MUST redirect authenticated users away
//    from auth routes to /app/home
// 3. ShellRoute MUST host persistent bottom navigation
// 4. All routes MUST be defined using GoRoute, not string navigation
// 5. Deep links must be handled for note sharing (future)
// 6. Route transitions should use MaterialPage for Android
//    and CupertinoPage for iOS (platform-adaptive)
```

**File:** `lib/config/routing/route_paths.dart`

```dart
// Design — constants for type-safe navigation

class RoutePaths {
  // Root routes
  static const splash = '/';
  static const onboarding = '/onboarding';
  
  // Auth routes
  static const login = '/auth/login';
  static const signup = '/auth/signup';
  
  // Main app routes (shell)
  static const home = '/app/home';
  static const explore = '/app/explore';
  static const schedule = '/app/schedule';
  static const profile = '/app/profile';
  
  // Feature routes
  static const semesterDetail = '/semesters/:id';
  static const subjectDetail = '/subjects/:id';
  static const noteDetail = '/notes/:id';
  static const chapterDetail = '/chapters/:id';
  static const gradeCalculator = '/grades';
  static const settings = '/settings';
  static const aiAssistant = '/ai';
}
```

**File:** `lib/config/routing/route_guards.dart`

```dart
// Design — authentication guard contract

// AuthGuard responsibilities:
// 1. Check Firebase Auth currentUser
// 2. If authenticated → allow navigation
// 3. If unauthenticated → redirect to /auth/login
// 4. Store intended destination for post-login redirect

// Example guard contract (pseudocode):
// redirect: (context, state) {
//   final isAuthenticated = FirebaseAuth.instance.currentUser != null;
//   final isAuthRoute = state.location.startsWith('/auth');
//   
//   if (!isAuthenticated && !isAuthRoute) return '/auth/login';
//   if (isAuthenticated && isAuthRoute) return '/app/home';
//   return null; // No redirect
// }
```

### Route Parameter Passing

```dart
// Design pattern for passing parameters:

// 1. Path parameters for entity IDs:
//    context.go('/notes/${noteId}')
//    Use for navigation that should be URL-addressable

// 2. Extra parameters for complex objects:
//    context.go('/notes/edit', extra: noteEntity)
//    Use when full object needed and not URL-addressable

// 3. Query parameters for filters:
//    context.go('/notes?semester=$id&subject=$subjectId')
//    Use for optional parameters and filtering
```

## State Management Architecture (Riverpod)

### Riverpod Design Philosophy

Riverpod provides compile-time safe, testable state management without BuildContext dependency. The architecture uses different provider types based on state requirements:

| Provider Type | Use Case | Example |
|--------------|----------|---------|
| `Provider` | Immutable dependencies | Dio client, API service instances |
| `StateProvider` | Simple mutable state | UI toggles, selected index |
| `FutureProvider` | One-time async data fetch | User profile fetch |
| `StreamProvider` | Continuous async streams | Firebase Auth state |
| `StateNotifierProvider` | Complex state with business logic | Notes list with CRUD |
| `ChangeNotifierProvider` | Legacy compatibility | Migrating old Provider code |

### Provider Organization Pattern

```dart
// Design pattern for provider organization:

// 1. Global providers in config/di/provider_container.dart
//    - Services (Dio, Hive, API clients)
//    - Repositories
//    - Auth state stream

// 2. Feature providers in features/{name}/presentation/providers/
//    - Feature-specific state notifiers
//    - Feature-specific data providers
//    - Feature-specific use cases

// 3. Provider naming convention:
//    - Service: {Name}ServiceProvider
//    - Repository: {Name}RepositoryProvider
//    - Use Case: {Action}{Entity}UseCaseProvider
//    - State: {Feature}StateProvider
//    - Notifier: {Feature}NotifierProvider
```

### Example Provider Hierarchy

```dart
// Design hierarchy (pseudocode notation):

// Layer 1: Infrastructure providers
final dioProvider = Provider<Dio>((ref) => configured_dio_client);
final hiveProvider = Provider<HiveInterface>((ref) => Hive);
final connectivityProvider = StreamProvider<ConnectivityResult>(...);

// Layer 2: Data source providers
final noteLocalDataSourceProvider = Provider<NoteLocalDataSource>((ref) {
  final hive = ref.watch(hiveProvider);
  return HiveNoteDataSource(hive);
});

final noteRemoteDataSourceProvider = Provider<NoteRemoteDataSource>((ref) {
  final dio = ref.watch(dioProvider);
  return ApiNoteDataSource(dio);
});

// Layer 3: Repository providers
final noteRepositoryProvider = Provider<NoteRepository>((ref) {
  final localDS = ref.watch(noteLocalDataSourceProvider);
  final remoteDS = ref.watch(noteRemoteDataSourceProvider);
  final connectivity = ref.watch(connectivityProvider);
  return NoteRepositoryImpl(localDS, remoteDS, connectivity);
});

// Layer 4: Use case providers
final createNoteUseCaseProvider = Provider<CreateNoteUseCase>((ref) {
  final repo = ref.watch(noteRepositoryProvider);
  return CreateNoteUseCase(repo);
});

// Layer 5: State notifier providers
final notesNotifierProvider = 
  StateNotifierProvider<NotesNotifier, AsyncValue<List<Note>>>((ref) {
    final createUseCase = ref.watch(createNoteUseCaseProvider);
    final updateUseCase = ref.watch(updateNoteUseCaseProvider);
    final deleteUseCase = ref.watch(deleteNoteUseCaseProvider);
    return NotesNotifier(createUseCase, updateUseCase, deleteUseCase);
  });
```

### State Notifier Design Pattern

```dart
// Design contract for StateNotifier:

// 1. State MUST be immutable (use @freezed or immutable classes)
// 2. State updates MUST be atomic (replace entire state)
// 3. Async operations MUST use AsyncValue<T> for loading/error states
// 4. Business logic MUST be delegated to use cases
// 5. Notifier MUST NOT directly call data sources
// 6. Notifier MUST handle all error states explicitly

// Example state class (design):
@freezed
class NotesState with _$NotesState {
  const factory NotesState({
    required List<Note> notes,
    required bool isLoading,
    String? errorMessage,
    Note? selectedNote,
  }) = _NotesState;
}

// Example notifier (design contract):
class NotesNotifier extends StateNotifier<AsyncValue<List<Note>>> {
  // Dependencies injected via constructor
  final CreateNoteUseCase createUseCase;
  final UpdateNoteUseCase updateUseCase;
  
  // Methods emit new states
  Future<void> createNote(String title, String content) async {
    state = const AsyncValue.loading();
    final result = await createUseCase.execute(title, content);
    state = result.fold(
      (failure) => AsyncValue.error(failure.message, StackTrace.current),
      (note) => AsyncValue.data([...state.value ?? [], note]),
    );
  }
}
```

### Provider Consumption Patterns

```dart
// Design patterns for consuming providers in widgets:

// 1. ConsumerWidget for building with provider state:
class NotesList extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final notesAsync = ref.watch(notesNotifierProvider);
    
    return notesAsync.when(
      data: (notes) => ListView(...),
      loading: () => CircularProgressIndicator(),
      error: (error, stack) => ErrorWidget(error),
    );
  }
}

// 2. Consumer for local provider access:
Consumer(
  builder: (context, ref, child) {
    final count = ref.watch(counterProvider);
    return Text('$count');
  },
)

// 3. ref.listen for side effects:
ref.listen<AsyncValue<List<Note>>>(notesNotifierProvider, (prev, next) {
  next.whenOrNull(
    error: (error, _) => showErrorSnackbar(error),
  );
});

// 4. ref.read for one-time actions (in callbacks):
onPressed: () => ref.read(notesNotifierProvider.notifier).createNote(...),
```

## Reusable Widget System

### Widget Design Principles

1. **Composition over Inheritance**: Build complex widgets from simple ones
2. **Single Responsibility**: Each widget has one clear purpose
3. **Configurability**: Accept parameters for customization
4. **Consistency**: Use theme tokens, not hardcoded values
5. **Accessibility**: Include semantic labels and sufficient tap targets

### Widget Categories

#### 1. Button Widgets

**Primary Button** (`shared/widgets/buttons/primary_button.dart`)
- Used for primary actions (Save, Submit, Continue)
- Uses `AppColors.primary` background
- Full width by default, can be constrained
- Loading state with spinner
- Disabled state with reduced opacity

**Secondary Button** (`shared/widgets/buttons/secondary_button.dart`)
- Used for secondary actions (Cancel, Back)
- Outlined style with `AppColors.primary` border
- Transparent background
- Same sizing as primary button

**Icon Button Custom** (`shared/widgets/buttons/icon_button_custom.dart`)
- Used for icon-only actions (delete, edit, share)
- Circular or square variants
- Configurable size and color
- Splash effect on tap

```dart
// Design contracts for buttons:

// PrimaryButton requirements:
// - onPressed callback (nullable for disabled state)
// - text parameter
// - optional isLoading flag
// - optional width constraint
// - minimum height 48dp (accessibility)
// - uses AppSpacing for padding

// Example usage:
PrimaryButton(
  text: 'Save Note',
  onPressed: () => saveNote(),
  isLoading: isSubmitting,
)
```

#### 2. Card Widgets

**Note Card** (`shared/widgets/cards/note_card.dart`)
- Displays note preview with title, date, excerpt
- Tap to open note detail
- Long-press for context menu
- Swipe actions (delete, share)
- Uses Material 3 Card with elevation

**Semester Card** (`shared/widgets/cards/semester_card.dart`)
- Shows semester info with subject count
- Color-coded by semester status (active/past/future)
- Progress indicator for completion
- Navigate to semester detail on tap

**File Card** (`shared/widgets/cards/file_card.dart`)
- Displays file attachment with icon, name, size
- Different icons for PDF, image, doc types
- Download/open actions
- Loading state during download

```dart
// Design contract for cards:

// Cards MUST:
// - Use AppRadius.md for corner rounding
// - Use AppShadows.sm for elevation
// - Include padding from AppSpacing
// - Support tap callbacks
// - Show loading/error states when needed
// - Be responsive (width adapts to container)
```

#### 3. Input Widgets

**Custom Text Field** (`shared/widgets/inputs/custom_text_field.dart`)
- Consistent Material 3 text input
- Label, hint, prefix/suffix icon support
- Validation message display
- Password visibility toggle variant
- Character counter option
- Multiline support

**Search Bar Custom** (`shared/widgets/inputs/search_bar_custom.dart`)
- Search input with magnifying glass icon
- Clear button when text present
- Voice input button option
- Debounced onChange for search queries
- Recent searches dropdown (future)

```dart
// CustomTextField design contract:

// Parameters:
// - controller: TextEditingController
// - label: String
// - hint: String?
// - validator: String? Function(String?)?
// - prefixIcon: IconData?
// - suffixIcon: IconData?
// - obscureText: bool = false
// - maxLines: int = 1
// - enabled: bool = true
// - onChanged: Function(String)?

// Behavior:
// - Shows error text below field when validation fails
// - Error border color from AppColors.error
// - Focus border color from AppColors.primary
// - Uses AppTypography.bodyMedium for input text
// - Uses AppTypography.labelSmall for label/hint
```

#### 4. Dialog Widgets

**Confirmation Dialog** (`shared/widgets/dialogs/confirmation_dialog.dart`)
- Generic yes/no confirmation
- Customizable title, message, button labels
- Returns boolean result
- Destructive action variant (red confirm button)

**Loading Dialog** (`shared/widgets/dialogs/loading_dialog.dart`)
- Blocks interaction during async operations
- Shows spinner with optional message
- Non-dismissible by back button
- Automatically dismisses when operation completes

**Error Dialog** (`shared/widgets/dialogs/error_dialog.dart`)
- Displays error with icon and message
- Retry and dismiss actions
- Can include error details (collapsible)

```dart
// Dialog design patterns:

// Show confirmation dialog:
final confirmed = await showDialog<bool>(
  context: context,
  builder: (_) => ConfirmationDialog(
    title: 'Delete Note?',
    message: 'This action cannot be undone.',
    confirmText: 'Delete',
    isDestructive: true,
  ),
);

// Show loading dialog (controlled externally):
showDialog(
  context: context,
  barrierDismissible: false,
  builder: (_) => LoadingDialog(message: 'Saving...'),
);
// Later: Navigator.of(context).pop();
```

#### 5. Layout Widgets

**App Scaffold** (`shared/widgets/layouts/app_scaffold.dart`)
- Standardized page structure
- App bar with consistent styling
- Body with safe area
- Optional floating action button
- Optional bottom navigation bar
- Keyboard-aware scrolling

**Responsive Container** (`shared/widgets/layouts/responsive_container.dart`)
- Adapts to screen size breakpoints
- Maximum width constraint for tablets
- Padding scales with screen size
- Used for form pages and content areas

```dart
// AppScaffold design contract:

AppScaffold({
  required String title,
  required Widget body,
  List<Widget>? actions,
  Widget? floatingActionButton,
  Widget? bottomNavigationBar,
  bool showBackButton = false,
  bool resizeToAvoidBottomInset = true,
})

// Behavior:
// - Title uses AppTypography.headlineSmall
// - AppBar background from AppColors.primary
// - Body wrapped in SafeArea
// - Back button automatically shows if can pop
```

## Material 3 Design System

### Design Token Philosophy

Design tokens are the atomic building blocks of the design system. They ensure visual consistency and make theme changes (light/dark mode) trivial.

### Color Palette Design

**File:** `lib/config/theme/app_colors.dart`

```dart
// Design specification for color tokens:

class AppColors {
  // Brand colors
  static const primary = Color(0xFF0A0F2C);      // Deep navy (existing brand)
  static const primaryLight = Color(0xFF1A2F4C);
  static const primaryDark = Color(0xFF000510);
  
  static const secondary = Color(0xFF4A90E2);    // Blue accent
  static const secondaryLight = Color(0xFF7AB8FF);
  static const secondaryDark = Color(0xFF2868B2);
  
  static const tertiary = Color(0xFF50E3C2);     // Teal accent
  static const tertiaryLight = Color(0xFF80FFD4);
  static const tertiaryDark = Color(0xFF20B392);
  
  // Semantic colors
  static const success = Color(0xFF4CAF50);
  static const warning = Color(0xFFFFA726);
  static const error = Color(0xFFE53935);
  static const info = Color(0xFF42A5F5);
  
  // Surface colors (Light theme)
  static const background = Color(0xFFF8F9FA);
  static const surface = Color(0xFFFFFFFF);
  static const surfaceVariant = Color(0xFFF1F3F5);
  static const surfaceContainerHigh = Color(0xFFE8EAED);
  
  // Text colors
  static const onPrimary = Color(0xFFFFFFFF);
  static const onSecondary = Color(0xFFFFFFFF);
  static const onBackground = Color(0xFF1A1C1E);
  static const onSurface = Color(0xFF1A1C1E);
  static const onSurfaceVariant = Color(0xFF44474A);
  
  // Border colors
  static const outline = Color(0xFFBABEC4);
  static const outlineVariant = Color(0xFFDDE1E6);
  
  // Dark theme colors (future — placeholder)
  // static const darkBackground = Color(0xFF121212);
  // static const darkSurface = Color(0xFF1E1E1E);
  // [Dark theme tokens defined when dark mode is implemented]
}
```

### Typography Design

**File:** `lib/config/theme/app_typography.dart`

```dart
// Material 3 typography scale design:

// Font family: Google Fonts Poppins (primary), System fallback
// All sizes in SP (scale-independent pixels)

class AppTypography {
  // Display styles — large headlines
  static TextStyle displayLarge = 57sp, w400, tight letter-spacing
  static TextStyle displayMedium = 45sp, w400
  static TextStyle displaySmall = 36sp, w400
  
  // Headline styles — section headers
  static TextStyle headlineLarge = 32sp, w600
  static TextStyle headlineMedium = 28sp, w600     // Screen titles
  static TextStyle headlineSmall = 24sp, w600      // Section titles
  
  // Title styles — component titles
  static TextStyle titleLarge = 22sp, w600          // Card titles
  static TextStyle titleMedium = 16sp, w500
  static TextStyle titleSmall = 14sp, w500
  
  // Body styles — content text
  static TextStyle bodyLarge = 16sp, w400           // Primary body
  static TextStyle bodyMedium = 14sp, w400          // Default body
  static TextStyle bodySmall = 12sp, w400
  
  // Label styles — UI labels
  static TextStyle labelLarge = 14sp, w500          // Buttons
  static TextStyle labelMedium = 12sp, w500         // Chips
  static TextStyle labelSmall = 11sp, w500          // Captions
}
```

### Spacing System Design

**File:** `lib/config/theme/app_spacing.dart`

```dart
// 8dp base grid system (Material Design standard)

class AppSpacing {
  static const double none = 0;
  static const double xs = 4.0;    // 0.5 × base
  static const double sm = 8.0;    // 1 × base
  static const double md = 16.0;   // 2 × base (most common)
  static const double lg = 24.0;   // 3 × base
  static const double xl = 32.0;   // 4 × base
  static const double xxl = 48.0;  // 6 × base
  static const double xxxl = 64.0; // 8 × base
  
  // Common padding patterns
  static const EdgeInsets paddingAll = EdgeInsets.all(md);
  static const EdgeInsets paddingHorizontal = EdgeInsets.symmetric(horizontal: md);
  static const EdgeInsets paddingVertical = EdgeInsets.symmetric(vertical: md);
  static const EdgeInsets paddingPage = EdgeInsets.all(lg);
  static const EdgeInsets paddingCard = EdgeInsets.all(md);
}

// Usage guideline:
// - xs: Icon-to-text gaps
// - sm: List item internal spacing
// - md: Default padding (cards, buttons, screens)
// - lg: Screen edges, section spacing
// - xl: Large section breaks
// - xxl+: Hero spacing, onboarding
```

### Border Radius Design

**File:** `lib/config/theme/app_radius.dart`

```dart
// Consistent corner rounding

class AppRadius {
  static const double none = 0;
  static const double sm = 4.0;     // Subtle rounding
  static const double md = 8.0;     // Default for cards/buttons
  static const double lg = 12.0;    // Prominent elements
  static const double xl = 16.0;    // Bottom sheets, dialogs
  static const double full = 999.0; // Circular (pills, avatars)
  
  static BorderRadius get roundedSm => BorderRadius.circular(sm);
  static BorderRadius get roundedMd => BorderRadius.circular(md);
  static BorderRadius get roundedLg => BorderRadius.circular(lg);
  static BorderRadius get roundedXl => BorderRadius.circular(xl);
  static BorderRadius get roundedFull => BorderRadius.circular(full);
  
  // Directional radius for specific corners
  static BorderRadius topOnlyLg = BorderRadius.vertical(top: Radius.circular(lg));
}

// Usage:
// - sm: Chips, small buttons
// - md: Cards, input fields, standard buttons
// - lg: Bottom sheets, large cards
// - xl: Dialogs, modals
// - full: Avatar images, FAB, circular buttons
```

### Shadow/Elevation Design

**File:** `lib/config/theme/app_shadows.dart`

```dart
// Material 3 elevation shadows (approximated via BoxShadow)

class AppShadows {
  // Elevation 1 (subtle — bottom nav, cards at rest)
  static List<BoxShadow> get sm => [
    BoxShadow(
      color: Colors.black.withOpacity(0.05),
      blurRadius: 2,
      offset: const Offset(0, 1),
    ),
  ];
  
  // Elevation 2 (moderate — raised cards, buttons)
  static List<BoxShadow> get md => [
    BoxShadow(
      color: Colors.black.withOpacity(0.08),
      blurRadius: 4,
      offset: const Offset(0, 2),
    ),
  ];
  
  // Elevation 3 (high — dialogs, bottom sheets)
  static List<BoxShadow> get lg => [
    BoxShadow(
      color: Colors.black.withOpacity(0.12),
      blurRadius: 8,
      offset: const Offset(0, 4),
    ),
  ];
  
  // Elevation 4 (floating — FAB, modal sheets)
  static List<BoxShadow> get xl => [
    BoxShadow(
      color: Colors.black.withOpacity(0.16),
      blurRadius: 16,
      offset: const Offset(0, 6),
    ),
  ];
}

// Note: Material 3 uses surface tint instead of shadows
// in some cases. Evaluate tint vs shadow per component.
```

### Theme Composition

**File:** `lib/config/theme/app_theme.dart`

```dart
// Design contract for complete Material 3 ThemeData

class AppTheme {
  static ThemeData get lightTheme {
    // ColorScheme from AppColors
    final colorScheme = ColorScheme.light(
      primary: AppColors.primary,
      secondary: AppColors.secondary,
      tertiary: AppColors.tertiary,
      error: AppColors.error,
      background: AppColors.background,
      surface: AppColors.surface,
      surfaceVariant: AppColors.surfaceVariant,
      onPrimary: AppColors.onPrimary,
      onSecondary: AppColors.onSecondary,
      onBackground: AppColors.onBackground,
      onSurface: AppColors.onSurface,
      outline: AppColors.outline,
    );

    return ThemeData(
      useMaterial3: true,
      colorScheme: colorScheme,
      
      // Typography from AppTypography
      textTheme: TextTheme(
        displayLarge: AppTypography.displayLarge,
        displayMedium: AppTypography.displayMedium,
        headlineMedium: AppTypography.headlineMedium,
        titleLarge: AppTypography.titleLarge,
        bodyLarge: AppTypography.bodyLarge,
        bodyMedium: AppTypography.bodyMedium,
        labelLarge: AppTypography.labelLarge,
      ),
      
      // Component themes
      appBarTheme: AppBarTheme(
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.onPrimary,
        elevation: 0,
        centerTitle: false,
        titleTextStyle: AppTypography.headlineSmall.copyWith(
          color: AppColors.onPrimary,
        ),
      ),
      
      cardTheme: CardTheme(
        color: AppColors.surface,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: AppRadius.roundedMd,
        ),
      ),
      
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: AppColors.onPrimary,
          minimumSize: const Size(0, 48),
          shape: RoundedRectangleBorder(
            borderRadius: AppRadius.roundedMd,
          ),
        ),
      ),
      
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.surfaceVariant,
        border: OutlineInputBorder(
          borderRadius: AppRadius.roundedMd,
          borderSide: BorderSide(color: AppColors.outline),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: AppRadius.roundedMd,
          borderSide: BorderSide(color: AppColors.primary, width: 2),
        ),
      ),
      
      // Additional component themes as needed
      // (FloatingActionButton, BottomNavigationBar, etc.)
    );
  }
  
  // Dark theme (future implementation)
  // static ThemeData get darkTheme { ... }
}
```

## Data Models

### Domain Entity Design Pattern

Domain entities are the core business objects. They are:
- Pure Dart classes (no Flutter or framework dependencies)
- Immutable (all fields final)
- Equality-based (by value, not reference)
- Serialization-agnostic

```dart
// Entity design pattern (pseudocode):

class NoteEntity {
  final String id;
  final String title;
  final String content;
  final String chapterId;
  final DateTime createdAt;
  final DateTime updatedAt;
  final bool isDeleted;
  final SyncStatus syncStatus;
  
  // Constructor, copyWith, equality, hashCode
}

enum SyncStatus {
  local,      // Created locally, not yet synced
  synced,     // In sync with server
  modified,   // Modified locally, needs sync
  conflict,   // Conflict between local and server
}
```

### Data Model Design Pattern

Data models extend entities with serialization:

```dart
// Model design pattern (pseudocode):

class NoteModel extends NoteEntity {
  // Adds:
  // - fromJson(Map<String, dynamic> json) factory
  // - toJson() method
  // - fromHive(NoteLocal hiveObject) factory
  // - toHive() method
  // - fromEntity(NoteEntity entity) factory
  
  // Mapping between layers:
  //   API JSON (NoteModel) → Entity (NoteEntity) → UI
  //   Hive Object (NoteLocal.g.dart) → Model → Entity → UI
}
```

### Hive Integration Models

Existing Hive models from `notesApiServices/` are preserved intact:

| Hive Model | Location | Hive Type ID |
|------------|----------|-------------|
| `SemesterLocal` | `notesApiServices/Semesters/semester_local.dart` | Existing |
| `SubjectLocal` | `notesApiServices/Subjects/subject_local.dart` | Existing |
| `ChapterLocal` | `notesApiServices/Chapters/chapter_local.dart` | Existing |
| `NoteLocal` | `notesApiServices/Notes/note_local.dart` | Existing |
| `ScheduleItemLocal` | `screens/dashboard/schedule/models/` | Existing |

The new architecture wraps these in repository implementations without modifying the generated `.g.dart` files.

### Repository Interface Design Pattern

```dart
// Repository interface design (domain layer):

abstract class NoteRepository {
  // Query
  Future<Result<List<NoteEntity>>> getNotesByChapter(String chapterId);
  Future<Result<NoteEntity>> getNoteById(String id);
  
  // Commands
  Future<Result<NoteEntity>> createNote(CreateNoteParams params);
  Future<Result<NoteEntity>> updateNote(UpdateNoteParams params);
  Future<Result<void>> deleteNote(String id);
  
  // Sync
  Future<Result<void>> syncAll();
  Stream<List<NoteEntity>> watchNotes(String chapterId);
}

// Result type (Either-like pattern):
// Success: Result.success(value)
// Failure: Result.failure(Failure)
// Eliminates exceptions from domain layer
```

### Offline-Ready Data Flow

```
User Action (Create Note)
    │
    ▼
NoteRepository.createNote()
    │
    ├── Save to Hive immediately (NoteLocal with syncStatus: local)
    │       │
    │       ▼
    │   Return Result.success(note) — UI updates instantly
    │
    └── Background: Check connectivity
            │
            ├── Online: POST to API → Update Hive syncStatus to synced
            │
            └── Offline: Queue sync task
                    │
                    ▼
               ConnectivityService detects online
                    │
                    ▼
               SyncManager processes queue
                    │
                    ▼
               API sync → Update Hive syncStatus
```

## Dependency Injection

### DI Strategy

The architecture uses Riverpod as the primary dependency injection container. Services are defined as Riverpod providers at the appropriate scope level.

```
Dependency Resolution Chain:
══════════════════════════════

External Libraries (Dio, Hive, Firebase)
    │
    ▼
Infrastructure Providers (DioProvider, HiveProvider, FirebaseAuthProvider)
    │
    ▼
Data Source Providers (NoteLocalDSProvider, NoteRemoteDSProvider)
    │
    ▼
Repository Providers (NoteRepositoryProvider)
    │
    ▼
Use Case Providers (CreateNoteUseCaseProvider)
    │
    ▼
State Notifier Providers (NotesNotifierProvider)
    │
    ▼
Widget (ConsumerWidget watches provider)
```

### Service Locator Pattern (Optional Alternative)

For services that need to be accessed outside the widget tree (e.g., background sync, notification handlers), a complementary GetIt service locator can be used:

```dart
// lib/config/di/service_locator.dart

// Design contract:
// 1. Register singletons during app initialization
// 2. Factories for per-request instances
// 3. Access via GetIt.instance.get<T>()
// 4. Used only outside widget tree; prefer Riverpod inside tree

// Example registration:
final sl = GetIt.instance;

void setupServiceLocator() {
  // External
  sl.registerLazySingleton<Dio>(() => configureDio());
  sl.registerLazySingleton<HiveInterface>(() => Hive);
  
  // Core
  sl.registerLazySingleton<NetworkInfo>(() => NetworkInfoImpl());
  
  // Data sources
  sl.registerLazySingleton<NoteRemoteDataSource>(
    () => ApiNoteDataSource(dio: sl()),
  );
  
  // Repositories
  sl.registerLazySingleton<NoteRepository>(
    () => NoteRepositoryImpl(
      remoteDS: sl(),
      localDS: sl(),
      networkInfo: sl(),
    ),
  );
}
```

## Asset Management

### Asset Organization

```
assets/
├── images/
│   ├── splash/
│   │   └── logo.png
│   ├── onboarding/
│   │   ├── onboarding_1.png
│   │   ├── onboarding_2.png
│   │   └── onboarding_3.png
│   ├── icons/
│   │   ├── note_icon.png
│   │   └── ai_icon.png
│   └── placeholders/
│       └── empty_state.png
├── fonts/
│   └── (Custom fonts if needed)
└── animations/
    └── loading.json (Lottie)
```

### Asset Constants

**File:** `lib/core/constants/app_assets.dart`

```dart
class AppAssets {
  // Images
  static const String splashLogo = 'assets/images/splash/logo.png';
  static const String onboarding1 = 'assets/images/onboarding/onboarding_1.png';
  static const String noteIcon = 'assets/images/icons/note_icon.png';
  static const String emptyStatePlaceholder = 'assets/images/placeholders/empty_state.png';
  
  // Animations
  static const String loadingAnimation = 'assets/animations/loading.json';
  
  // Fonts (if custom fonts are used)
  // static const String fontPoppins = 'Poppins';
}
```

### pubspec.yaml Asset Configuration

```yaml
flutter:
  uses-material-design: true
  
  assets:
    - assets/images/splash/
    - assets/images/onboarding/
    - assets/images/icons/
    - assets/images/placeholders/
    - assets/animations/
  
  # fonts:
  #   - family: Poppins
  #     fonts:
  #       - asset: assets/fonts/Poppins-Regular.ttf
  #       - asset: assets/fonts/Poppins-Bold.ttf
  #         weight: 700
```

## Localization Architecture

### i18n Readiness

The architecture is prepared for localization but initially only supports English. The structure allows future language additions without refactoring.

**File:** `lib/config/localization/app_localizations.dart`

```dart
// Design for future i18n:

// 1. Use Flutter's built-in localization (flutter_localizations)
// 2. Generate ARB files for translations
// 3. Strings accessed via AppLocalizations.of(context).stringKey
// 4. Initial implementation: English only (en)
// 5. Future: Add ar, es, fr, etc. via ARB files

// Placeholder structure:
class AppLocalizations {
  final Locale locale;
  
  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }
  
  // String getters (future: loaded from ARB)
  String get appTitle => 'StudyFlow AI';
  String get loginTitle => 'Login';
  String get signupTitle => 'Sign Up';
  // ... etc
}
```

**File:** `lib/config/localization/supported_locales.dart`

```dart
class SupportedLocales {
  static const List<Locale> all = [
    Locale('en', 'US'), // English (default)
    // Future additions:
    // Locale('ar', 'SA'), // Arabic
    // Locale('es', 'ES'), // Spanish
  ];
  
  static const Locale defaultLocale = Locale('en', 'US');
}
```

**main.dart integration:**

```dart
MaterialApp(
  localizationsDelegates: [
    AppLocalizations.delegate,
    GlobalMaterialLocalizations.delegate,
    GlobalWidgetsLocalizations.delegate,
  ],
  supportedLocales: SupportedLocales.all,
  locale: SupportedLocales.defaultLocale,
  // ...
)
```

## Error Handling

### Error Handling Strategy

The application uses a layered error handling approach with custom exceptions mapped to user-friendly failures.

### Exception Hierarchy

**File:** `lib/core/errors/exceptions.dart`

```dart
// Base exception
abstract class AppException implements Exception {
  final String message;
  final String? code;
  
  AppException(this.message, [this.code]);
}

// Network exceptions
class ServerException extends AppException {
  ServerException(String message) : super(message, 'SERVER_ERROR');
}

class NetworkException extends AppException {
  NetworkException() : super('No internet connection', 'NETWORK_ERROR');
}

class TimeoutException extends AppException {
  TimeoutException() : super('Request timed out', 'TIMEOUT');
}

// Data exceptions
class CacheException extends AppException {
  CacheException(String message) : super(message, 'CACHE_ERROR');
}

class ParseException extends AppException {
  ParseException(String message) : super(message, 'PARSE_ERROR');
}

// Auth exceptions
class UnauthorizedException extends AppException {
  UnauthorizedException() : super('Unauthorized access', 'UNAUTHORIZED');
}

class ForbiddenException extends AppException {
  ForbiddenException() : super('Access forbidden', 'FORBIDDEN');
}

// Validation exceptions
class ValidationException extends AppException {
  final Map<String, String> errors;
  
  ValidationException(this.errors) 
    : super('Validation failed', 'VALIDATION_ERROR');
}
```

### Failure Classes

**File:** `lib/core/errors/failures.dart`

```dart
// Failures are user-facing error representations

abstract class Failure {
  final String message;
  final String code;
  
  Failure(this.message, this.code);
}

class ServerFailure extends Failure {
  ServerFailure(String message) : super(message, 'SERVER_FAILURE');
}

class NetworkFailure extends Failure {
  NetworkFailure() : super(
    'Unable to connect. Please check your internet connection.',
    'NETWORK_FAILURE',
  );
}

class CacheFailure extends Failure {
  CacheFailure(String message) : super(message, 'CACHE_FAILURE');
}

class ValidationFailure extends Failure {
  final Map<String, String> fieldErrors;
  
  ValidationFailure(this.fieldErrors) : super(
    'Please correct the errors in the form.',
    'VALIDATION_FAILURE',
  );
}
```

### Global Error Handler

**File:** `lib/core/errors/error_handler.dart`

```dart
// Design contract for global error handling:

class ErrorHandler {
  // Map exceptions to failures
  static Failure handleException(Exception exception) {
    if (exception is ServerException) {
      return ServerFailure(exception.message);
    } else if (exception is NetworkException) {
      return NetworkFailure();
    } else if (exception is CacheException) {
      return CacheFailure(exception.message);
    } else if (exception is ValidationException) {
      return ValidationFailure(exception.errors);
    }
    
    // Unknown exception
    return ServerFailure('An unexpected error occurred');
  }
  
  // Show error to user (via SnackBar or Dialog)
  static void showError(BuildContext context, Failure failure) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(failure.message),
        backgroundColor: AppColors.error,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }
  
  // Log errors (integrate with logging service)
  static void logError(Exception exception, StackTrace stackTrace) {
    // Production: Send to Firebase Crashlytics
    // Development: Print to console
    print('Error: $exception');
    print('Stack trace: $stackTrace');
  }
}
```

### Error Flow in Repository

```dart
// Example error handling in repository implementation:

class NoteRepositoryImpl implements NoteRepository {
  @override
  Future<Result<NoteEntity>> createNote(CreateNoteParams params) async {
    try {
      // Save to Hive first (offline-first)
      final localNote = await localDataSource.createNote(params);
      
      // Try to sync to server
      if (await networkInfo.isConnected) {
        try {
          final remoteNote = await remoteDataSource.createNote(params);
          // Update Hive with server ID and syncStatus
          await localDataSource.updateSyncStatus(remoteNote.id, SyncStatus.synced);
          return Result.success(remoteNote);
        } on ServerException catch (e) {
          // Server failed, but local is saved
          return Result.success(localNote); // Return local copy
        }
      }
      
      // Offline — return local note
      return Result.success(localNote);
      
    } on CacheException catch (e) {
      return Result.failure(CacheFailure(e.message));
    } catch (e) {
      return Result.failure(ServerFailure('Failed to create note'));
    }
  }
}
```

### Result Type Pattern

```dart
// lib/core/utils/result.dart

// Either-like pattern for error handling without exceptions

sealed class Result<T> {
  const Result();
  
  factory Result.success(T value) = Success<T>;
  factory Result.failure(Failure failure) = FailureResult<T>;
  
  // Fold pattern for handling both cases
  R fold<R>(
    R Function(Failure failure) onFailure,
    R Function(T value) onSuccess,
  );
  
  // Convenience getters
  bool get isSuccess;
  bool get isFailure;
  T? get valueOrNull;
  Failure? get failureOrNull;
}

class Success<T> extends Result<T> {
  final T value;
  const Success(this.value);
  
  @override
  R fold<R>(
    R Function(Failure failure) onFailure,
    R Function(T value) onSuccess,
  ) => onSuccess(value);
  
  @override
  bool get isSuccess => true;
  @override
  bool get isFailure => false;
  @override
  T? get valueOrNull => value;
  @override
  Failure? get failureOrNull => null;
}

class FailureResult<T> extends Result<T> {
  final Failure failure;
  const FailureResult(this.failure);
  
  @override
  R fold<R>(
    R Function(Failure failure) onFailure,
    R Function(T value) onSuccess,
  ) => onFailure(failure);
  
  @override
  bool get isSuccess => false;
  @override
  bool get isFailure => true;
  @override
  T? get valueOrNull => null;
  @override
  Failure? get failureOrNull => failure;
}
```

## Testing Strategy

This architecture restructure is primarily organizational. Testing will focus on structural validation and build system compatibility.

### Unit Testing Approach

- **Configuration Tests**: Verify theme constants, asset paths, route definitions
- **Extension Tests**: Test custom extensions (String, DateTime, etc.)
- **Validation Tests**: Test validator functions with various inputs
- **Error Mapping Tests**: Verify exception-to-failure conversions

### Integration Testing Approach

- **Build System Test**: `flutter build apk --debug` succeeds
- **Import Resolution Test**: Ensure moved files resolve correctly
- **Theme Application Test**: Material 3 theme applied to sample widget
- **Navigation Test**: Router handles auth state changes

### Widget Testing Approach

- **Reusable Widget Tests**: Each shared widget renders without errors
- **Theme Integration Tests**: Widgets use theme tokens correctly
- **Responsive Layout Tests**: Layouts adapt to different screen sizes

### Testing Structure

```
test/
├── config/
│   ├── theme/
│   │   ├── app_colors_test.dart
│   │   ├── app_typography_test.dart
│   │   └── app_theme_test.dart
│   └── routing/
│       └── app_router_test.dart
├── core/
│   ├── utils/
│   │   ├── validators_test.dart
│   │   └── extensions_test.dart
│   └── errors/
│       └── error_handler_test.dart
├── shared/
│   └── widgets/
│       ├── buttons/
│       │   └── primary_button_test.dart
│       └── cards/
│           └── note_card_test.dart
└── integration/
    ├── build_test.dart
    └── navigation_test.dart
```

### Example Test Cases

**Unit Test: Validators**

```dart
// Test validators with example inputs
test('email validator rejects invalid email', () {
  expect(Validators.email('invalid'), isNotNull);
  expect(Validators.email('test@example.com'), isNull);
});
```

**Widget Test: PrimaryButton**

```dart
// Test button renders and responds to tap
testWidgets('PrimaryButton calls onPressed when tapped', (tester) async {
  var pressed = false;
  
  await tester.pumpWidget(
    MaterialApp(
      home: Scaffold(
        body: PrimaryButton(
          text: 'Test',
          onPressed: () => pressed = true,
        ),
      ),
    ),
  );
  
  await tester.tap(find.text('Test'));
  expect(pressed, isTrue);
});
```

**Integration Test: Build**

```dart
// Verify project compiles
test('Flutter build succeeds', () async {
  final result = await Process.run('flutter', ['build', 'apk', '--debug']);
  expect(result.exitCode, equals(0));
});
```

### No Property-Based Testing

Based on the prework analysis, this architecture restructure involves:
- Structural/organizational changes (directory creation)
- Configuration checks (theme values, asset paths)
- Build system compatibility (compile succeeds)

These are not suitable for property-based testing because:
1. Most requirements are smoke tests (directory exists or doesn't)
2. Theme/config values are concrete examples, not universal properties
3. Build success is a binary integration check

Therefore, the testing strategy uses **example-based unit tests** for configurations, **widget tests** for UI components, and **integration tests** for build verification.

## Migration Strategy

### Phase-Based Migration

The migration from legacy to new architecture occurs gradually:

| Phase | Scope | Status |
|-------|-------|--------|
| Phase 0 | Create folder structure, theme system, routing setup | **Initial Setup** |
| Phase 1 | Migrate Splash & Onboarding features | Low risk |
| Phase 2 | Migrate Authentication feature | Medium risk |
| Phase 3 | Migrate Dashboard & Semesters features | High risk |
| Phase 4 | Migrate Notes, Subjects, Chapters features | High risk |
| Phase 5 | Migrate Schedules, Grades, Profile features | Medium risk |
| Phase 6 | Implement AI Assistant feature (future) | Future |

### Feature Migration Pattern

For each feature being migrated:

1. **Create Feature Module Structure**
   - `features/{feature_name}/domain/`
   - `features/{feature_name}/presentation/`
   - `features/{feature_name}/data/`

2. **Migrate Domain Layer**
   - Define entities (pure Dart classes)
   - Define repository interfaces
   - Create use cases

3. **Migrate Data Layer**
   - Create models (JSON + Hive serialization)
   - Wrap existing Hive services as data sources
   - Implement repository (offline-first with sync)

4. **Migrate Presentation Layer**
   - Move screens from `legacy/screens/` to `features/{name}/presentation/screens/`
   - Convert stateful widgets to Riverpod consumers
   - Extract reusable widgets to `shared/widgets/`
   - Create state notifiers

5. **Update Routing**
   - Add feature routes to `app_router.dart`
   - Update navigation calls to use GoRouter context extensions

6. **Test & Verify**
   - Feature works offline
   - Sync works when online
   - No regressions in legacy features

7. **Deprecate Legacy Code**
   - Mark legacy feature folder for deletion (future)

### Coexistence Strategy

During migration, legacy and new architecture coexist:

```
lib/
├── features/              # New architecture
│   └── authentication/    # Migrated feature
│       ├── domain/
│       ├── presentation/
│       └── data/
│
└── legacy/               # Preserved legacy code
    └── screens/
        ├── auth/         # ← Coexists until fully migrated
        ├── dashboard/    # ← Still in use
        └── explore/      # ← Still in use
```

**Navigation Bridge:**

```dart
// app_router.dart handles both old and new:

GoRoute(
  path: '/auth/login',
  builder: (context, state) => LoginScreen(),  // New architecture
),

GoRoute(
  path: '/dashboard',
  builder: (context, state) => LegacyDashboardScreen(),  // Legacy
),
```

**Import Bridge:**

```dart
// Legacy code can import new shared widgets:
import 'package:untitled/shared/widgets/buttons/primary_button.dart';

// New code doesn't import legacy
```

## Future Enhancements

### Dark Mode Support

When implementing dark mode:

1. Define dark color palette in `AppColors`
2. Create `AppTheme.darkTheme` getter
3. Use `ThemeMode` provider to switch themes
4. Test all screens in dark mode
5. Ensure sufficient contrast ratios (WCAG AA)

### AI Assistant Integration

The architecture includes a placeholder `features/ai_assistant/` module. Future AI integration:

- **Presentation**: Chat UI, voice input, suggestions panel
- **Domain**: AI conversation entity, prompt repository
- **Data**: Integration with AI backend (OpenAI, Gemini, etc.)
- State management via Riverpod stream provider for real-time responses

### Multi-Platform Support

Current design focuses on mobile. For web/desktop:

- Use `ResponsiveContainer` with breakpoints
- Adapt navigation (drawer for desktop, bottom bar for mobile)
- Platform-specific file pickers and storage
- Conditional imports for platform-specific code

### Performance Optimization

- Lazy loading for feature modules (deferred imports)
- Image caching with `cached_network_image`
- Pagination for large lists
- Virtual scrolling for note content
- Background isolates for heavy computations (Hive sync)

## Accessibility Considerations

### WCAG Compliance Guidelines

The architecture supports accessibility through:

1. **Semantic Widgets**: Use Semantics widget for screen readers
2. **Sufficient Contrast**: All text meets WCAG AA (4.5:1 for normal, 3:1 for large)
3. **Tap Targets**: Minimum 48×48 dp (Material Design spec)
4. **Focus Management**: Keyboard navigation support
5. **Labels**: All interactive elements have semantic labels
6. **Error Identification**: Form errors clearly announced

### Theme Accessibility

```dart
// AppColors designed for WCAG AA compliance:
// - AppColors.onBackground on background: 16:1 (AAA)
// - AppColors.onPrimary on primary: 12:1 (AAA)
// - AppColors.error on background: 5.2:1 (AA)

// Typography designed for readability:
// - Minimum body text: 14sp (bodyMedium)
// - Line height: 1.5x font size
// - No all-caps for body text
```

### Accessible Widget Patterns

```dart
// Example: Accessible button
Semantics(
  label: 'Save note',
  button: true,
  enabled: !isLoading,
  child: PrimaryButton(
    text: 'Save',
    onPressed: isLoading ? null : _saveNote,
  ),
)

// Example: Accessible form field
CustomTextField(
  label: 'Email',
  controller: emailController,
  validator: Validators.email,
  semanticsLabel: 'Email address input field',
)
```

## Security Considerations

### Data Security

1. **Sensitive Data**: Never log authentication tokens, passwords, or personal data
2. **Hive Encryption**: Use `HiveAesCipher` for encrypted boxes (future)
3. **Secure Storage**: Store auth tokens in Flutter Secure Storage (not Hive)
4. **SSL Pinning**: Implement certificate pinning for API calls (production)

### Authentication Security

```dart
// Design principles:
// 1. Firebase Auth handles password hashing
// 2. Tokens stored securely (FlutterSecureStorage)
// 3. Auth state managed by StreamProvider
// 4. Auto-logout on token expiry
// 5. Biometric authentication option (future)
```

### API Security

```dart
// Dio interceptor for auth (design):
class AuthInterceptor extends Interceptor {
  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) async {
    // Add Firebase ID token to all requests
    final token = await FirebaseAuth.instance.currentUser?.getIdToken();
    if (token != null) {
      options.headers['Authorization'] = 'Bearer $token';
    }
    handler.next(options);
  }
  
  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    if (err.response?.statusCode == 401) {
      // Token expired — trigger logout
      FirebaseAuth.instance.signOut();
    }
    handler.next(err);
  }
}
```

## Build Configuration

### Development vs Production

```dart
// lib/config/environment/flavor_config.dart

enum Flavor { development, staging, production }

class FlavorConfig {
  final Flavor flavor;
  final String apiBaseUrl;
  final bool enableLogging;
  final bool enableAnalytics;
  
  FlavorConfig({
    required this.flavor,
    required this.apiBaseUrl,
    required this.enableLogging,
    required this.enableAnalytics,
  });
  
  static FlavorConfig? _instance;
  static FlavorConfig get instance => _instance!;
  
  static void initialize(Flavor flavor) {
    switch (flavor) {
      case Flavor.development:
        _instance = FlavorConfig(
          flavor: flavor,
          apiBaseUrl: 'http://192.168.1.10:5000/api',
          enableLogging: true,
          enableAnalytics: false,
        );
      case Flavor.staging:
        _instance = FlavorConfig(
          flavor: flavor,
          apiBaseUrl: 'https://staging-api.studyflow.com/api',
          enableLogging: true,
          enableAnalytics: true,
        );
      case Flavor.production:
        _instance = FlavorConfig(
          flavor: flavor,
          apiBaseUrl: 'https://api.studyflow.com/api',
          enableLogging: false,
          enableAnalytics: true,
        );
    }
  }
}
```

### Environment-Specific Entry Points

```dart
// main_dev.dart
void main() {
  FlavorConfig.initialize(Flavor.development);
  runApp(const StudyFlowApp());
}

// main_prod.dart
void main() {
  FlavorConfig.initialize(Flavor.production);
  runApp(const StudyFlowApp());
}
```

### Build Commands

```bash
# Development build
flutter run --target lib/main_dev.dart

# Production build
flutter build apk --target lib/main_prod.dart --release

# Staging build
flutter build apk --target lib/main_staging.dart --profile
```

## Logging and Debugging

### Logging Strategy

**File:** `lib/core/utils/logger.dart`

```dart
// Design for structured logging

class Logger {
  static void debug(String message, [dynamic data]) {
    if (FlavorConfig.instance.enableLogging) {
      print('[DEBUG] $message ${data ?? ''}');
    }
  }
  
  static void info(String message, [dynamic data]) {
    if (FlavorConfig.instance.enableLogging) {
      print('[INFO] $message ${data ?? ''}');
    }
  }
  
  static void warning(String message, [dynamic data]) {
    print('[WARNING] $message ${data ?? ''}');
  }
  
  static void error(String message, [dynamic error, StackTrace? stackTrace]) {
    print('[ERROR] $message');
    if (error != null) print('Error: $error');
    if (stackTrace != null) print('Stack trace: $stackTrace');
    
    // Production: Send to Crashlytics
    // FirebaseCrashlytics.instance.recordError(error, stackTrace);
  }
}
```

### Debug Tools

```dart
// Development-only debug overlays

// Show current route
if (FlavorConfig.instance.flavor == Flavor.development) {
  // Display current route name in debug banner
}

// Hive inspector (development)
HiveService.printHiveData(); // Already in use

// Network logging
DioLogger interceptor (logs all API calls in dev mode)
```

## Performance Monitoring

### Metrics to Track

1. **App Startup Time**: Time from launch to first frame
2. **Screen Navigation Time**: Time to transition between screens
3. **API Response Time**: Average response time per endpoint
4. **Hive Operation Time**: Time to read/write local data
5. **Sync Duration**: Time to sync all data when going online
6. **Memory Usage**: Monitor for memory leaks
7. **Frame Rate**: Maintain 60 FPS during scrolling

### Monitoring Implementation (Future)

```dart
// Firebase Performance Monitoring integration:

// Track custom traces
final trace = FirebasePerformance.instance.newTrace('load_notes');
await trace.start();
// ... operation
await trace.stop();

// Track network requests (automatic with Dio interceptor)

// Track screen rendering
class PerformanceObserver extends NavigatorObserver {
  @override
  void didPush(Route route, Route? previousRoute) {
    // Track screen load time
  }
}
```

## Documentation Structure

The project will include comprehensive documentation:

### 1. Architecture Documentation

**File:** `docs/architecture.md`

Contents:
- Overview of Feature-First Clean Architecture
- Explanation of each layer (domain, presentation, data)
- Dependency flow diagrams
- Code organization principles
- Best practices for adding new features

### 2. Theme System Documentation

**File:** `docs/theme_system.md`

Contents:
- Material 3 design token usage
- Color palette reference with hex values
- Typography scale with use cases
- Spacing system guidelines
- Component theming examples
- How to add dark mode support

### 3. Migration Guide

**File:** `docs/migration_guide.md`

Contents:
- Step-by-step feature migration process
- Code examples for each layer
- Common pitfalls and solutions
- Testing checklist per feature
- Rollback procedures

### 4. Contributing Guidelines

**File:** `docs/contributing.md`

Contents:
- Code style guidelines (follow Flutter style guide)
- Naming conventions for files, classes, variables
- Git workflow (feature branches, pull requests)
- Code review checklist
- Testing requirements before submitting PR

### 5. API Integration Guide

**File:** `docs/api_integration.md`

Contents:
- Backend API endpoint reference
- Authentication flow
- Request/response formats
- Error codes and handling
- Rate limiting considerations

## Dependencies

### Required Dependencies (Already in pubspec.yaml)

```yaml
dependencies:
  flutter:
    sdk: flutter
  
  # State Management
  flutter_riverpod: ^2.5.1  # To be added
  
  # Routing
  go_router: ^14.0.0        # To be added
  
  # Local Storage
  hive: ^2.2.3              # ✓ Already present
  hive_flutter: ^1.1.0      # ✓ Already present
  
  # Networking
  dio: ^5.9.0               # ✓ Already present (dev_dependencies → move to dependencies)
  connectivity_plus: ^7.0.0 # ✓ Already present
  
  # Firebase
  firebase_core: ^4.2.1     # ✓ Already present
  firebase_auth: ^6.1.2     # ✓ Already present
  
  # Utilities
  uuid: ^4.5.2              # ✓ Already present
  
  # UI
  google_fonts: ^6.3.2      # ✓ Present in dev_dependencies
  
  # Other
  timezone: ^0.10.1         # ✓ Already present
  flutter_local_notifications: ^19.5.0  # ✓ Already present

dev_dependencies:
  # Code Generation
  build_runner: ^2.4.13     # ✓ Already present
  hive_generator: ^2.0.1    # ✓ Already present
  
  # Serialization
  freezed: ^2.5.0           # To be added (optional but recommended)
  json_serializable: ^6.8.0 # To be added (optional)
  
  # Testing
  flutter_test:
    sdk: flutter
  mockito: ^5.4.4           # To be added
```

### Dependency Management Strategy

1. **Pin Major Versions**: Avoid breaking changes (`^` operator)
2. **Regular Updates**: Check for security updates monthly
3. **Minimize Dependencies**: Only add when necessary
4. **Evaluate Alternatives**: Compare packages before adding
5. **Check Maintenance**: Ensure package is actively maintained

## Summary

### Architecture at a Glance

```
StudyFlow AI — Feature-First Clean Architecture

┌─────────────────────────────────────────────────────┐
│                   MaterialApp                        │
│          (GoRouter + Riverpod + Material 3)          │
└─────────────────────────────────────────────────────┘
                         │
         ┌───────────────┼───────────────┐
         │               │               │
    ┌────▼────┐    ┌──────▼──────┐  ┌───▼────┐
    │ Config  │    │    Core     │  │ Shared │
    │---------│    │-------------|  │--------|
    │ Router  │    │ Constants   │  │Widgets │
    │ Theme   │    │ Errors      │  │ Exts   │
    │ DI      │    │ Network     │  │ Mixins │
    │ i18n    │    │ Storage     │  └────────┘
    │ Env     │    │ Utils       │
    └────────┘    └─────────────┘
         │
    ┌────▼──────────────────────────────────────┐
    │                 Features                   │
    │  ┌──────────┐ ┌──────────┐ ┌──────────┐  │
    │  │auth      │ │semesters │ │  notes   │  │
    │  │--------- │ │--------- │ │----------│  │
    │  │domain   ─┼─┤ domain  ─┼─┤ domain   │  │
    │  │   entity │ │  entity  │ │  entity  │  │
    │  │   usecase│ │  usecase │ │  usecase │  │
    │  │   repo.i │ │  repo.i  │ │  repo.i  │  │
    │  │          │ │          │ │          │  │
    │  │presenta- │ │presenta- │ │presenta- │  │
    │  │  tion    │ │  tion    │ │  tion    │  │
    │  │   screen │ │  screen  │ │  screen  │  │
    │  │   widget │ │  widget  │ │  widget  │  │
    │  │  provider│ │ provider │ │ provider │  │
    │  │          │ │          │ │          │  │
    │  │data     │ │  data    │ │  data    │  │
    │  │  model   │ │  model   │ │  model   │  │
    │  │  datasrc │ │  datasrc │ │  datasrc │  │
    │  │  repo.impl│ │ repo.impl│ │ repo.impl│  │
    │  └──────────┘ └──────────┘ └──────────┘  │
    └────────────────────────────────────────────┘
         │
    ┌────▼──────────────────────────────────────┐
    │                 Legacy                     │
    │  (Preserved existing code during migration)│
    └────────────────────────────────────────────┘
         │
    ┌────▼──────────────────────────────────────┐
    │           External (Placeholder)           │
    │  Firebase Auth │ Backend API │ Supabase    │
    └────────────────────────────────────────────┘
```

### Design Principles Checklist

| Principle | How Addressed |
|-----------|--------------|
| Single Responsibility | Each file has one clear purpose |
| Open/Closed | Feature modules are independently extendable |
| Dependency Inversion | Domain depends on interfaces, not implementations |
| DRY | Shared widgets/extensions eliminate duplication |
| Separation of Concerns | UI / Logic / Data cleanly separated per feature |
| Testability | All layers independently testable |
| Scalability | Adding features doesn't touch existing code |
| Offline-First | Hive-first, API secondary in repositories |
| Maintainability | Clear folder structure with documented responsibilities |

## Correctness Properties

These properties define the invariants that the restructured architecture must always satisfy. They are verifiable through a combination of static analysis, widget tests, and integration checks.

### Property 1: Architectural Layer Independence

**Validates: Requirements 1.6, 1.7, 1.8**

The domain layer MUST NOT import from the presentation or data layers. Any file under `features/{name}/domain/` must have zero imports from `features/{name}/presentation/` or `features/{name}/data/`.

### Property 2: No Hardcoded Design Values in Widgets

**Validates: Requirements 4.1, 4.2, 4.3, 4.4, 4.5**

All widgets in `shared/widgets/` and `features/{name}/presentation/` MUST reference design tokens (`AppColors`, `AppSpacing`, `AppRadius`, `AppShadows`, `AppTypography`) rather than hardcoded literal values (e.g., `Color(0xFF...)`, `EdgeInsets.all(16)`, `BorderRadius.circular(8)`).

### Property 3: Theme Completeness

**Validates: Requirements 4.6, 4.7, 4.8**

`AppTheme.lightTheme` MUST produce a `ThemeData` with `useMaterial3: true`, a fully specified `ColorScheme`, and a `TextTheme` covering at minimum `displayLarge`, `headlineMedium`, `titleLarge`, `bodyMedium`, and `labelSmall`. No required field in the color scheme may be null.

### Property 4: Existing Code Preservation

**Validates: Requirements 6.1, 6.2, 6.3, 6.4, 6.5, 6.6, 6.7**

After the restructure, all files that existed under `lib/screens/`, `lib/notesApiServices/`, `lib/clippers/`, and `lib/dialogs/` MUST still exist at their original paths. No existing file may be deleted or moved during the initial restructure phase.

### Property 5: Build Integrity

**Validates: Requirements 7.1, 7.2, 7.3, 7.4, 7.5**

After all structural changes are applied, `flutter build apk --debug` MUST exit with code 0. No new compilation error or unresolved import may be introduced by the restructure.

### Property 6: Route Coverage

**Validates: Requirements 2.3**

Every route path defined in `RoutePaths` MUST have a corresponding `GoRoute` entry in `app_router.dart`. Undefined paths must not appear in `RoutePaths`, and every `GoRoute` path must reference a `RoutePaths` constant (no magic strings).

### Property 7: Offline-First Write Safety

**Validates: Requirements 1.6, 1.8**

When `NoteRepository.createNote()` is called, data MUST be persisted to Hive before any network call is attempted. If the network call fails or the device is offline, `Result.success` MUST still be returned with the locally persisted entity — never `Result.failure` for a pure network error on a write operation.

### Property 8: Error Propagation Completeness

**Validates: Requirements 1.2**

Every `AppException` subtype MUST have a corresponding `Failure` subtype, and `ErrorHandler.handleException()` MUST map every known exception to its failure — no exception may fall through to the generic `ServerFailure('An unexpected error occurred')` branch when its type is known.

### Property 9: Asset Path Validity

**Validates: Requirements 8.5, 8.6**

Every constant defined in `AppAssets` MUST correspond to an actual file registered under the `assets:` section of `pubspec.yaml`. No phantom asset path constant may exist, and no registered asset path may be missing from `AppAssets`.

### Property 10: Feature Module Structural Completeness

**Validates: Requirements 5.1, 5.2, 5.3, 5.4, 5.5**

For each of the 14 feature modules (`splash`, `onboarding`, `authentication`, `dashboard`, `semesters`, `subjects`, `notes`, `assignments`, `quizzes`, `schedules`, `grades`, `profile`, `settings`, `ai_assistant`), the following subdirectories MUST exist: `domain/entities/`, `domain/repositories/`, `presentation/screens/`, `presentation/widgets/`, `presentation/providers/` (or `bloc/`), `data/models/`, `data/datasources/`, `data/repositories/`. Each empty directory MUST contain a `.gitkeep` file.
