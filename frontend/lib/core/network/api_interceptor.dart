import 'package:dio/dio.dart';

/// Placeholder auth interceptor for StudyFlow AI.
/// Full implementation (add Firebase ID token, handle 401) is Phase 2.
class AuthInterceptor extends Interceptor {
  const AuthInterceptor();

  @override
  void onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) {
    // Phase 2: attach Firebase ID token here.
    handler.next(options);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    // Phase 2: handle 401 logout here.
    handler.next(err);
  }
}
