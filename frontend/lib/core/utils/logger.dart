import 'package:flutter/foundation.dart';

/// Lightweight logger for StudyFlow AI.
/// In debug mode, prints tagged messages to the console.
/// Production: replace print calls with a logging service (e.g. Crashlytics).
class Logger {
  Logger._();

  static void debug(String message, [dynamic data]) {
    if (kDebugMode) {
      debugPrint('[DEBUG] $message${data != null ? ' | $data' : ''}');
    }
  }

  static void info(String message, [dynamic data]) {
    if (kDebugMode) {
      debugPrint('[INFO] $message${data != null ? ' | $data' : ''}');
    }
  }

  static void warning(String message, [dynamic data]) {
    debugPrint('[WARNING] $message${data != null ? ' | $data' : ''}');
  }

  static void error(
    String message, [
    dynamic error,
    StackTrace? stackTrace,
  ]) {
    debugPrint('[ERROR] $message');
    if (error != null) debugPrint('  Error: $error');
    if (stackTrace != null) debugPrint('  Stack: $stackTrace');
  }
}
