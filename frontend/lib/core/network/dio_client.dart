import 'package:dio/dio.dart';

/// Placeholder Dio client for StudyFlow AI.
/// Full configuration (base URL, interceptors, timeouts) is Phase 2.
/// Do NOT use this client in production code until fully configured.
class DioClient {
  DioClient._();

  static Dio? _instance;

  /// Returns a bare [Dio] instance.
  /// Replace with a fully configured instance in Phase 2.
  static Dio get instance {
    _instance ??= Dio();
    return _instance!;
  }
}
