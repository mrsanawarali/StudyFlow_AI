/// Custom exception hierarchy for StudyFlow AI.
/// All exceptions extend [AppException] and carry a message and optional code.
library;

abstract class AppException implements Exception {
  final String message;
  final String? code;

  const AppException(this.message, [this.code]);

  @override
  String toString() => 'AppException($code): $message';
}

/// Thrown when the server returns an error response (4xx / 5xx).
class ServerException extends AppException {
  const ServerException(String message) : super(message, 'SERVER_ERROR');
}

/// Thrown when there is no network connectivity.
class NetworkException extends AppException {
  const NetworkException() : super('No internet connection', 'NETWORK_ERROR');
}

/// Thrown when a network request exceeds its timeout.
class TimeoutException extends AppException {
  const TimeoutException() : super('Request timed out', 'TIMEOUT');
}

/// Thrown when a local cache / Hive operation fails.
class CacheException extends AppException {
  const CacheException(String message) : super(message, 'CACHE_ERROR');
}

/// Thrown when JSON or data parsing fails.
class ParseException extends AppException {
  const ParseException(String message) : super(message, 'PARSE_ERROR');
}

/// Thrown when the user is not authenticated (HTTP 401).
class UnauthorizedException extends AppException {
  const UnauthorizedException()
      : super('Unauthorized access', 'UNAUTHORIZED');
}

/// Thrown when the user does not have permission (HTTP 403).
class ForbiddenException extends AppException {
  const ForbiddenException() : super('Access forbidden', 'FORBIDDEN');
}

/// Thrown when input validation fails.
class ValidationException extends AppException {
  final Map<String, String> errors;

  const ValidationException(this.errors)
      : super('Validation failed', 'VALIDATION_ERROR');
}
