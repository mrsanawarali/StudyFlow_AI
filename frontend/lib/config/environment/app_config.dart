/// Environment configuration for StudyFlow AI.
///
/// This file mirrors the existing [lib/config.dart] and is the new canonical
/// location for the API base URL. The original [lib/config.dart] is preserved
/// and must NOT be deleted during Phase 1.
///
/// Phase 2 migration: update imports from `config.dart` to
/// `config/environment/app_config.dart` across the codebase.
class AppConfig {
  AppConfig._();

  /// Base URL for the StudyFlow AI backend API.
  /// Update this value when the server IP changes during development.
  static const String baseUrl = 'http://192.168.1.10:5000/api';
}
