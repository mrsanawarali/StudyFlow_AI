/// App-wide constant values for StudyFlow AI.
class AppConstants {
  AppConstants._();

  static const String appName = 'StudyFlow AI';
  static const String appVersion = '1.0.0';
  static const int appBuildNumber = 1;

  /// Pagination
  static const int defaultPageSize = 20;

  /// Animation durations
  static const Duration shortAnimation = Duration(milliseconds: 200);
  static const Duration mediumAnimation = Duration(milliseconds: 400);
  static const Duration longAnimation = Duration(milliseconds: 600);

  /// Timeouts
  static const Duration apiTimeout = Duration(seconds: 30);
  static const Duration connectTimeout = Duration(seconds: 15);
}
