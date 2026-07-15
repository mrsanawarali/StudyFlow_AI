/// Global Riverpod provider hierarchy documentation for StudyFlow AI.
///
/// Provider resolution chain:
///
/// ```
/// External Libraries (Dio, Hive, Firebase)
///     │
///     ▼
/// Infrastructure Providers   [config/di/]
///   dioProvider
///   hiveProvider
///   connectivityProvider
///     │
///     ▼
/// Data Source Providers       [features/{name}/data/datasources/]
///   noteLocalDataSourceProvider
///   noteRemoteDataSourceProvider
///     │
///     ▼
/// Repository Providers        [features/{name}/data/repositories/]
///   noteRepositoryProvider
///     │
///     ▼
/// Use Case Providers          [features/{name}/domain/usecases/]
///   createNoteUseCaseProvider
///     │
///     ▼
/// State Notifier Providers    [features/{name}/presentation/providers/]
///   notesNotifierProvider
///     │
///     ▼
/// Widget (ConsumerWidget)     [features/{name}/presentation/screens/]
/// ```
///
/// Phase 1: Providers are co-located with their feature modules.
/// Global infrastructure providers will be added here in Phase 2.
library;
