# Implementation Plan: Flutter Architecture Restructure — Phase 1: Flutter Project Foundation

## Overview

This plan establishes the Flutter project foundation by adding required packages, creating the directory structure, implementing the Material 3 design system, setting up routing and environment configuration, creating shared widgets, scaffolding all 14 feature modules, bridging legacy code, and updating `main.dart` — all without touching the backend, deleting existing code, or implementing any business logic.

## Tasks

- [x] 1. Update pubspec.yaml with required frontend packages
  - Add `go_router: ^14.0.0` to `dependencies`
  - Add `flutter_riverpod: ^2.5.1` to `dependencies`
  - Move `google_fonts: ^6.3.2` from `dev_dependencies` to `dependencies`
  - Move `dio: ^5.9.0` from `dev_dependencies` to `dependencies`
  - Add asset directory declarations under `flutter.assets:` for `assets/images/splash/`, `assets/images/onboarding/`, `assets/images/icons/`, `assets/images/placeholders/`, `assets/animations/`
  - Do NOT remove any existing dependency
  - _Requirements: 7.1, 7.4, 8.5_

- [x] 2. Create asset directory structure
  - [x] 2.1 Create asset directories with .gitkeep files
    - Create `frontend/assets/images/splash/.gitkeep`
    - Create `frontend/assets/images/onboarding/.gitkeep`
    - Create `frontend/assets/images/icons/.gitkeep`
    - Create `frontend/assets/images/placeholders/.gitkeep`
    - Create `frontend/assets/fonts/.gitkeep`
    - Create `frontend/assets/animations/.gitkeep`
    - _Requirements: 8.1, 8.2, 8.3, 8.4_

- [x] 3. Create core infrastructure files
  - [x] 3.1 Create core/constants/ files
    - Create `lib/core/constants/app_constants.dart` with placeholder class `AppConstants` (app name, version constants)
    - Create `lib/core/constants/api_endpoints.dart` with placeholder class `ApiEndpoints` (base path, semesters, subjects, chapters, notes, users endpoint strings)
    - Create `lib/core/constants/app_assets.dart` with class `AppAssets` defining all asset path constants matching the registered pubspec.yaml paths (splashLogo, onboarding1/2/3, noteIcon, emptyStatePlaceholder, loadingAnimation)
    - _Requirements: 1.1, 8.6_
  - [x] 3.2 Create core/errors/ files
    - Create `lib/core/errors/exceptions.dart` with abstract `AppException` and subclasses: `ServerException`, `NetworkException`, `TimeoutException`, `CacheException`, `ParseException`, `UnauthorizedException`, `ForbiddenException`, `ValidationException`
    - Create `lib/core/errors/failures.dart` with abstract `Failure` and subclasses: `ServerFailure`, `NetworkFailure`, `CacheFailure`, `ValidationFailure`
    - Create `lib/core/errors/error_handler.dart` with class `ErrorHandler` mapping every `AppException` subtype to its corresponding `Failure` — every known exception type must have an explicit branch (no fall-through for known types)
    - _Requirements: 1.2_
  - [x] 3.3 Create core/network/ files
    - Create `lib/core/network/network_info.dart` with abstract `NetworkInfo` interface and stub `NetworkInfoImpl` (returns `true` for `isConnected` — full implementation deferred)
    - Create `lib/core/network/api_response.dart` with generic `ApiResponse<T>` wrapper class (data, message, statusCode fields)
    - Create `lib/core/network/dio_client.dart` with a `DioClient` class stub (placeholder — do NOT implement actual Dio configuration yet to avoid breaking existing code)
    - Create `lib/core/network/api_interceptor.dart` with an `AuthInterceptor` stub class extending `Interceptor`
    - _Requirements: 1.3_
  - [x] 3.4 Create core/storage/ files
    - Create `lib/core/storage/storage_keys.dart` with class `StorageKeys` defining box name constants used across the app
    - Create `lib/core/storage/box_manager.dart` with stub `BoxManager` class (placeholder — existing Hive setup in main.dart is preserved)
    - Create `lib/core/storage/hive_service.dart` as stub class (do NOT conflict with existing `notesApiServices` HiveService classes)
    - _Requirements: 1.4_
  - [x] 3.5 Create core/utils/ files
    - Create `lib/core/utils/logger.dart` with class `Logger` having static methods `debug`, `info`, `warning`, `error` (uses `print` in debug mode only via `kDebugMode`)
    - Create `lib/core/utils/validators.dart` with class `Validators` having static methods: `email(String?)`, `password(String?)`, `required(String?, String)`, each returning `String?` (null = valid)
    - Create `lib/core/utils/date_formatter.dart` with class `DateFormatter` having static helpers for formatting `DateTime` to display strings
    - Create `lib/core/utils/result.dart` with sealed class `Result<T>` containing `Success<T>` and `FailureResult<T>` subclasses with `fold`, `isSuccess`, `isFailure`, `valueOrNull`, `failureOrNull`
    - Create `lib/core/utils/extensions/string_extensions.dart` with extension `StringX on String` (capitalize, isValidEmail helpers)
    - Create `lib/core/utils/extensions/date_extensions.dart` with extension `DateTimeX on DateTime` (toDisplayString, isToday helpers)
    - Create `lib/core/utils/extensions/context_extensions.dart` with extension `BuildContextX on BuildContext` (theme, colorScheme, textTheme shorthand getters)
    - _Requirements: 1.5_

- [x] 4. Create config/theme/ files (Material 3 design system)
  - [x] 4.1 Create AppColors
    - Create `lib/config/theme/app_colors.dart` with class `AppColors` containing all color constants: primary (`0xFF0A0F2C`), primaryLight, primaryDark, secondary, secondaryLight, secondaryDark, tertiary, tertiaryLight, tertiaryDark, success, warning, error, info, background, surface, surfaceVariant, surfaceContainerHigh, onPrimary, onSecondary, onBackground, onSurface, onSurfaceVariant, outline, outlineVariant
    - All values MUST match the hex codes specified in the design document
    - _Requirements: 4.1_
  - [x] 4.2 Create AppTypography
    - Create `lib/config/theme/app_typography.dart` with class `AppTypography` using `GoogleFonts.poppins(...)` for all styles
    - Define all Material 3 text styles: `displayLarge` (57sp, w400), `displayMedium` (45sp, w400), `displaySmall` (36sp, w400), `headlineLarge` (32sp, w600), `headlineMedium` (28sp, w600), `headlineSmall` (24sp, w600), `titleLarge` (22sp, w600), `titleMedium` (16sp, w500), `titleSmall` (14sp, w500), `bodyLarge` (16sp, w400), `bodyMedium` (14sp, w400), `bodySmall` (12sp, w400), `labelLarge` (14sp, w500), `labelMedium` (12sp, w500), `labelSmall` (11sp, w500)
    - _Requirements: 4.2_
  - [x] 4.3 Create AppSpacing
    - Create `lib/config/theme/app_spacing.dart` with class `AppSpacing` defining: `none = 0`, `xs = 4.0`, `sm = 8.0`, `md = 16.0`, `lg = 24.0`, `xl = 32.0`, `xxl = 48.0`, `xxxl = 64.0`
    - Also define `EdgeInsets` constants: `paddingAll`, `paddingHorizontal`, `paddingVertical`, `paddingPage`, `paddingCard`
    - _Requirements: 4.3_
  - [x] 4.4 Create AppRadius
    - Create `lib/config/theme/app_radius.dart` with class `AppRadius` defining: `none = 0`, `sm = 4.0`, `md = 8.0`, `lg = 12.0`, `xl = 16.0`, `full = 999.0`
    - Include `BorderRadius` getters: `roundedSm`, `roundedMd`, `roundedLg`, `roundedXl`, `roundedFull`, `topOnlyLg`
    - _Requirements: 4.4_
  - [x] 4.5 Create AppShadows
    - Create `lib/config/theme/app_shadows.dart` with class `AppShadows` defining `List<BoxShadow>` getters: `sm` (opacity 0.05, blur 2, offset Offset(0,1)), `md` (opacity 0.08, blur 4, offset Offset(0,2)), `lg` (opacity 0.12, blur 8, offset Offset(0,4)), `xl` (opacity 0.16, blur 16, offset Offset(0,6))
    - _Requirements: 4.5_
  - [x] 4.6 Create AppTheme
    - Create `lib/config/theme/app_theme.dart` with class `AppTheme` containing a static getter `lightTheme` returning a fully configured `ThemeData`
    - Set `useMaterial3: true`
    - Build `ColorScheme.light(...)` using `AppColors` values — no field may be null
    - Set `textTheme` using `AppTypography` covering at minimum: `displayLarge`, `headlineMedium`, `titleLarge`, `bodyMedium`, `labelLarge`
    - Configure component themes: `AppBarTheme`, `CardTheme`, `ElevatedButtonThemeData`, `InputDecorationTheme` as specified in the design
    - Import `AppColors`, `AppTypography`, `AppRadius` — use only those tokens, no hardcoded literal values
    - _Requirements: 4.6, 4.7, 4.8_

- [x] 5. Create config/routing/ files
  - [x] 5.1 Create route_paths.dart
    - Create `lib/config/routing/route_paths.dart` with class `RoutePaths` containing all route path constants: `splash`, `onboarding`, `login`, `signup`, `home`, `explore`, `schedule`, `profile`, `semesterDetail`, `subjectDetail`, `noteDetail`, `chapterDetail`, `gradeCalculator`, `settings`, `aiAssistant`
    - _Requirements: 2.3_
  - [x] 5.2 Create app_router.dart placeholder
    - Create `lib/config/routing/app_router.dart` as a placeholder file
    - Define a `createRouter()` function returning a `GoRouter` with only the root `/` route pointing at the existing `SplashScreen` from legacy code
    - Import `RoutePaths` — use only `RoutePaths` constants, no magic string paths
    - Keep the existing `MaterialApp` routes in `main.dart` intact — this file is a scaffold for future wiring
    - _Requirements: 2.3_
  - [x] 5.3 Create route_guards.dart placeholder
    - Create `lib/config/routing/route_guards.dart` with a placeholder `AuthGuard` class documenting the redirect contract (check Firebase Auth, redirect unauthenticated to login, redirect authenticated away from auth routes) — no active logic yet
    - _Requirements: 2.3_

- [x] 6. Create config/environment/ files
  - [x] 6.1 Create app_config.dart
    - Create `lib/config/environment/app_config.dart`
    - Expose the same `baseUrl` API as the existing `lib/config.dart` (read the existing file first and replicate the value exactly)
    - Keep `lib/config.dart` unchanged — `app_config.dart` is additive
    - _Requirements: 2.1, 2.5_
  - [x] 6.2 Create flavor_config.dart
    - Create `lib/config/environment/flavor_config.dart` with enum `Flavor { development, staging, production }` and class `FlavorConfig` with singleton `initialize(Flavor)` method and fields: `flavor`, `apiBaseUrl`, `enableLogging`, `enableAnalytics`
    - Initialize with development defaults (using the same base URL from `AppConfig`)
    - _Requirements: 2.1_

- [x] 7. Create config/di/ placeholder files
  - Create `lib/config/di/service_locator.dart` with empty stub `setupServiceLocator()` function (no GetIt dependency added — just a placeholder for future DI wiring)
  - Create `lib/config/di/provider_container.dart` with a comment block describing the provider hierarchy pattern from the design document
  - _Requirements: 2.4_

- [x] 8. Create shared widget files
  - [x] 8.1 Create button widgets
    - Create `lib/shared/widgets/buttons/primary_button.dart` with `PrimaryButton` StatelessWidget: accepts `text`, `onPressed` (nullable), `isLoading` (default false), optional `width`; minimum height 48dp; uses `AppColors`, `AppSpacing`, `AppRadius`, `AppTypography` — no hardcoded literal design values
    - Create `lib/shared/widgets/buttons/secondary_button.dart` with `SecondaryButton` StatelessWidget: outlined style, same parameter contract as `PrimaryButton`
    - Create `lib/shared/widgets/buttons/icon_button_custom.dart` with `IconButtonCustom` StatelessWidget: accepts `icon`, `onPressed`, optional `size`, `color`
    - _Requirements: 3.1_
  - [x] 8.2 Create input widget
    - Create `lib/shared/widgets/inputs/app_text_field.dart` with `AppTextField` StatelessWidget: accepts `controller`, `label`, optional `hint`, `validator`, `prefixIcon`, `suffixIcon`, `obscureText` (default false), `maxLines` (default 1), `enabled` (default true), `onChanged`; shows validation errors; uses only theme tokens for colors/spacing/radius
    - Create `lib/shared/widgets/inputs/search_bar_custom.dart` with `SearchBarCustom` StatelessWidget: search icon, clear button, `onChanged` callback
    - _Requirements: 3.1_
  - [x] 8.3 Create card widget
    - Create `lib/shared/widgets/cards/app_card.dart` with `AppCard` StatelessWidget: accepts `child`, optional `onTap`, `padding`; uses `AppRadius.roundedMd`, `AppShadows.sm` — no hardcoded values
    - _Requirements: 3.1_
  - [x] 8.4 Create state widgets
    - Create `lib/shared/widgets/loading_widget.dart` with `LoadingWidget` StatelessWidget (centered `CircularProgressIndicator` using `AppColors.primary`)
    - Create `lib/shared/widgets/empty_state.dart` with `EmptyState` StatelessWidget: accepts `message`, optional `icon`, `onAction`, `actionLabel`
    - Create `lib/shared/widgets/error_state.dart` with `ErrorState` StatelessWidget: accepts `message`, optional `onRetry`
    - _Requirements: 3.1_
  - [x] 8.5 Create layout widgets
    - Create `lib/shared/widgets/layouts/app_scaffold.dart` with `AppScaffold` StatelessWidget matching the design contract: `title`, `body`, optional `actions`, `floatingActionButton`, `bottomNavigationBar`, `showBackButton`, `resizeToAvoidBottomInset`
    - Create `lib/shared/widgets/layouts/responsive_container.dart` with `ResponsiveContainer` StatelessWidget: max-width constraint, adaptive horizontal padding
    - _Requirements: 3.1_
  - [x] 8.6 Create shared mixins
    - Create `lib/shared/mixins/validation_mixin.dart` with mixin `ValidationMixin` providing field validation helpers (delegates to `Validators`)
    - Create `lib/shared/mixins/loading_state_mixin.dart` with mixin `LoadingStateMixin` for managing `isLoading` bool state in `StatefulWidget`
    - _Requirements: 3.4_

- [x] 9. Checkpoint — Verify theme and shared widgets compile
  - Ensure all theme files, core infrastructure files, and shared widgets compile without errors. Run `flutter analyze` in the `frontend/` directory and fix any reported issues before proceeding.

- [x] 10. Create all 14 empty feature module structures
  - [x] 10.1 Create feature scaffold for splash, onboarding, authentication, dashboard
    - For each feature in [splash, onboarding, authentication, dashboard]: create the full Clean Architecture subdirectory tree with `.gitkeep` files in every leaf folder
    - Required subdirs per feature: `domain/entities/`, `domain/repositories/`, `domain/usecases/`, `presentation/screens/`, `presentation/widgets/`, `presentation/providers/`, `data/models/`, `data/datasources/`, `data/repositories/`
    - _Requirements: 5.1, 5.2, 5.3, 5.4, 5.5_
  - [x] 10.2 Create feature scaffold for semesters, subjects, notes, assignments
    - Same structure as 10.1 for features: semesters, subjects, notes, assignments
    - _Requirements: 5.1, 5.2, 5.3, 5.4, 5.5_
  - [x] 10.3 Create feature scaffold for quizzes, schedules, grades, profile, settings, ai_assistant
    - Same structure as 10.1 for remaining features: quizzes, schedules, grades, profile, settings, ai_assistant
    - _Requirements: 5.1, 5.2, 5.3, 5.4, 5.5_

- [x] 11. Create legacy bridge (barrel exports)
  - Create `lib/legacy/index.dart` as a barrel export file that re-exports all existing top-level screens and services so new code can import from a single path
  - Export from: `lib/screens/splash/splash_screen.dart`, `lib/screens/auth/login_screen.dart`, `lib/screens/auth/signup_screen.dart`, `lib/screens/dashboard/dashboard_screen.dart`
  - Add a doc comment in the file explaining the migration path (new features go to `lib/features/`, legacy code stays in `lib/screens/` until migrated)
  - Do NOT move, delete, or modify any file under `lib/screens/`, `lib/notesApiServices/`, `lib/clippers/`, or `lib/dialogs/`
  - _Requirements: 6.1, 6.2, 6.3, 6.4, 9.1, 9.2, 9.5_

- [x] 12. Update main.dart to use AppTheme and ProviderScope
  - Wrap the root widget in `ProviderScope` from `flutter_riverpod` (add the import; wrap `ScheduleApp()` call in `runApp`)
  - Update the `ThemeData` in `ScheduleApp.build()` to use `AppTheme.lightTheme` (import `lib/config/theme/app_theme.dart`)
  - Keep ALL existing imports, Hive initialization, Firebase initialization, timezone setup, notification setup, background sync, and routing (`initialRoute`, `routes`) completely unchanged
  - The only permitted changes are: add `ProviderScope` wrapper and swap `ThemeData(...)` literal for `AppTheme.lightTheme`
  - _Requirements: 6.5, 6.7, 7.1, 7.5_

- [x] 13. Create documentation files
  - [x] 13.1 Create docs/architecture.md
    - Create `frontend/docs/architecture.md` documenting: the Feature-First Clean Architecture overview, purpose of each layer (core, config, shared, features), dependency flow, and best practices for adding new features
    - _Requirements: 10.1, 10.4_
  - [x] 13.2 Create docs/theme_system.md
    - Create `frontend/docs/theme_system.md` documenting: Material 3 design token reference (AppColors hex values, AppTypography scale, AppSpacing grid, AppRadius values), usage examples in widgets, and instructions for future dark mode
    - _Requirements: 10.2, 10.5_
  - [x] 13.3 Create docs/migration_guide.md
    - Create `frontend/docs/migration_guide.md` with step-by-step instructions for migrating one feature from `lib/screens/` to `lib/features/`, covering domain → data → presentation layers, routing update, and legacy cleanup
    - _Requirements: 10.3, 10.6_

- [x] 14. Final checkpoint — Full project verification
  - Ensure all tests pass and `flutter analyze` reports no errors in `frontend/`. Confirm `lib/screens/`, `lib/notesApiServices/`, `lib/clippers/`, and `lib/dialogs/` directories are fully intact. Ask the user if any questions arise.

## Notes

- Tasks marked with `*` are optional and can be skipped for a faster MVP
- No task in this plan touches the `backend/` folder
- No existing file under `lib/screens/`, `lib/notesApiServices/`, `lib/clippers/`, or `lib/dialogs/` is modified or deleted
- Firebase, Hive, timezone, and notification initialization in `main.dart` must remain exactly as-is
- `lib/config.dart` is preserved — `app_config.dart` is a new additive file
- `app_router.dart` is a placeholder for future GoRouter wiring; the existing `MaterialApp.routes` are not removed
- Core network files (DioClient, ApiInterceptor) are stubs only — full implementation is Phase 2+
- The design document explicitly states no property-based testing is applicable for this restructure phase

## Task Dependency Graph

```json
{
  "waves": [
    { "id": 0, "tasks": ["2.1"] },
    { "id": 1, "tasks": ["3.1", "3.2", "3.3", "3.4", "3.5"] },
    { "id": 2, "tasks": ["4.1", "4.2", "4.3", "4.4", "4.5"] },
    { "id": 3, "tasks": ["4.6", "5.1", "6.1", "6.2"] },
    { "id": 4, "tasks": ["5.2", "5.3", "8.1", "8.2", "8.3", "8.4", "8.5", "8.6"] },
    { "id": 5, "tasks": ["10.1", "10.2", "10.3", "11", "13.1", "13.2", "13.3"] },
    { "id": 6, "tasks": ["12"] }
  ]
}
```
