/// Legacy code bridge for StudyFlow AI.
///
/// This barrel file re-exports the existing screens and services so that
/// new architecture code can import from a single location during the
/// gradual migration.
///
/// ## Migration Path
///
/// **Phase 1 (current):** All existing screens remain in `lib/screens/` and
/// `lib/notesApiServices/`. New architecture scaffolding lives in
/// `lib/features/`, `lib/shared/`, `lib/core/`, and `lib/config/`.
///
/// **Phase 2–6 (future):** Migrate one feature at a time:
/// 1. Create domain entities and repository interface in
///    `lib/features/{name}/domain/`
/// 2. Implement repository in `lib/features/{name}/data/`
/// 3. Move the screen to `lib/features/{name}/presentation/screens/`
///    and convert to a Riverpod ConsumerWidget
/// 4. Add the new route to `lib/config/routing/app_router.dart`
/// 5. Delete the legacy screen and remove its export from this file
library;
///
/// Once all features are migrated, this file and `lib/legacy/` can be deleted.

// ── Screens ───────────────────────────────────────────────────────────────
export '../screens/splash/splash_screen.dart';
export '../screens/auth/login_screen.dart';
export '../screens/auth/signup_screen.dart';
export '../screens/dashboard/dashboard_screen.dart';
export '../screens/dashboard/dashboard_home.dart';
export '../screens/dashboard/profile_screen.dart';
export '../screens/explore/explore_screen.dart';
