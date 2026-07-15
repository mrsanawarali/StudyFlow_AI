/// Dependency injection service locator placeholder for StudyFlow AI.
///
/// Phase 1: Empty stub — Riverpod providers are the primary DI mechanism.
/// Phase 2: Register singletons (Dio, repositories, use cases) here for
/// access outside the widget tree (e.g. background sync, notification handlers).
///
/// Future implementation uses GetIt:
/// ```dart
/// import 'package:get_it/get_it.dart';
/// final sl = GetIt.instance;
///
/// void setupServiceLocator() {
///   sl.registerLazySingleton<Dio>(() => DioClient.instance);
///   // ... register repositories, use cases
/// }
/// ```
void setupServiceLocator() {
  // Phase 2: Register services here.
}
