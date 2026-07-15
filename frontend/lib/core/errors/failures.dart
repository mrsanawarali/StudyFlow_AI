/// User-facing failure representations for StudyFlow AI.
/// Failures are mapped from [AppException] subtypes by [ErrorHandler].
library;

abstract class Failure {
  final String message;
  final String code;

  const Failure(this.message, this.code);

  @override
  String toString() => 'Failure($code): $message';
}

/// A failure originating from a server error.
class ServerFailure extends Failure {
  const ServerFailure(String message) : super(message, 'SERVER_FAILURE');
}

/// A failure caused by missing network connectivity.
class NetworkFailure extends Failure {
  const NetworkFailure()
      : super(
          'Unable to connect. Please check your internet connection.',
          'NETWORK_FAILURE',
        );
}

/// A failure originating from a local cache error.
class CacheFailure extends Failure {
  const CacheFailure(String message) : super(message, 'CACHE_FAILURE');
}

/// A failure caused by input validation errors.
class ValidationFailure extends Failure {
  final Map<String, String> fieldErrors;

  const ValidationFailure(this.fieldErrors)
      : super(
          'Please correct the errors in the form.',
          'VALIDATION_FAILURE',
        );
}

/// A failure caused by an unauthorised request.
class AuthFailure extends Failure {
  const AuthFailure(String message) : super(message, 'AUTH_FAILURE');
}
