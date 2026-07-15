import '../errors/failures.dart';

/// A discriminated union type for operation results.
/// Use [Result.success] for success values and [Result.failure] for errors.
///
/// Example:
/// ```dart
/// Future<Result<Note>> createNote(params) async {
///   try {
///     final note = await repo.create(params);
///     return Result.success(note);
///   } on CacheException catch (e) {
///     return Result.failure(CacheFailure(e.message));
///   }
/// }
///
/// result.fold(
///   (failure) => showError(failure.message),
///   (note) => navigateToNote(note),
/// );
/// ```
sealed class Result<T> {
  const Result();

  factory Result.success(T value) = _Success<T>;
  factory Result.failure(Failure failure) = _Failure<T>;

  /// Folds the result into a single value [R].
  R fold<R>(
    R Function(Failure failure) onFailure,
    R Function(T value) onSuccess,
  );

  bool get isSuccess;
  bool get isFailure;
  T? get valueOrNull;
  Failure? get failureOrNull;
}

final class _Success<T> extends Result<T> {
  final T value;
  const _Success(this.value);

  @override
  R fold<R>(
    R Function(Failure failure) onFailure,
    R Function(T value) onSuccess,
  ) =>
      onSuccess(value);

  @override
  bool get isSuccess => true;
  @override
  bool get isFailure => false;
  @override
  T? get valueOrNull => value;
  @override
  Failure? get failureOrNull => null;
}

final class _Failure<T> extends Result<T> {
  final Failure failure;
  const _Failure(this.failure);

  @override
  R fold<R>(
    R Function(Failure failure) onFailure,
    R Function(T value) onSuccess,
  ) =>
      onFailure(failure);

  @override
  bool get isSuccess => false;
  @override
  bool get isFailure => true;
  @override
  T? get valueOrNull => null;
  @override
  Failure? get failureOrNull => failure;
}
