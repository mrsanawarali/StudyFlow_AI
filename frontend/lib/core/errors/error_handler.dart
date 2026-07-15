import 'package:flutter/material.dart';
import 'exceptions.dart';
import 'failures.dart';

/// Maps [AppException] subtypes to user-facing [Failure] objects
/// and provides helpers for displaying errors in the UI.
class ErrorHandler {
  ErrorHandler._();

  /// Converts a known [AppException] to the corresponding [Failure].
  /// Every known exception type has an explicit branch.
  static Failure handleException(AppException exception) {
    if (exception is NetworkException) {
      return const NetworkFailure();
    } else if (exception is TimeoutException) {
      return const NetworkFailure(); // timeout is a network-class failure
    } else if (exception is UnauthorizedException) {
      return AuthFailure(exception.message);
    } else if (exception is ForbiddenException) {
      return AuthFailure(exception.message);
    } else if (exception is ValidationException) {
      return ValidationFailure(exception.errors);
    } else if (exception is CacheException) {
      return CacheFailure(exception.message);
    } else if (exception is ParseException) {
      return ServerFailure('Data parsing failed: ${exception.message}');
    } else if (exception is ServerException) {
      return ServerFailure(exception.message);
    }
    // Fallback — should never be reached for known types above.
    return ServerFailure('An unexpected error occurred: ${exception.message}');
  }

  /// Shows a floating [SnackBar] with the failure message.
  static void showError(BuildContext context, Failure failure) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(failure.message),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  /// Logs an error to the console (production: wire up to Crashlytics).
  static void logError(Object error, StackTrace stackTrace) {
    // ignore: avoid_print
    debugPrint('[ErrorHandler] $error\n$stackTrace');
  }
}
