import 'package:go_router/go_router.dart';
import 'route_paths.dart';

/// Authentication redirect guard for GoRouter.
///
/// Phase 1: Placeholder — no active redirect logic.
/// Phase 2: Check [FirebaseAuth.instance.currentUser] and redirect
/// unauthenticated users to [RoutePaths.login].
///
/// Redirect contract:
/// - If user is NOT authenticated AND route is NOT an auth route
///   → redirect to [RoutePaths.login]
/// - If user IS authenticated AND route IS an auth route
///   → redirect to [RoutePaths.home]
/// - Otherwise → no redirect (return null)
class AuthGuard {
  const AuthGuard();

  /// Returns a [GoRouterRedirect] function for use in [GoRouter.redirect].
  ///
  /// Phase 2 implementation:
  /// ```dart
  /// GoRouterRedirect get redirect => (context, state) {
  ///   final isAuthenticated = FirebaseAuth.instance.currentUser != null;
  ///   final isAuthRoute = state.matchedLocation.startsWith('/auth');
  ///   if (!isAuthenticated && !isAuthRoute) return RoutePaths.login;
  ///   if (isAuthenticated && isAuthRoute) return RoutePaths.home;
  ///   return null;
  /// };
  /// ```
  GoRouterRedirect get redirect => (context, state) => null;
}
