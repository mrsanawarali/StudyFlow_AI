/// Generic wrapper for API responses.
class ApiResponse<T> {
  final T? data;
  final String? message;
  final int? statusCode;
  final bool success;

  const ApiResponse({
    this.data,
    this.message,
    this.statusCode,
    this.success = true,
  });

  factory ApiResponse.success(T data, {String? message, int statusCode = 200}) {
    return ApiResponse<T>(
      data: data,
      message: message,
      statusCode: statusCode,
      success: true,
    );
  }

  factory ApiResponse.error(String message, {int? statusCode}) {
    return ApiResponse<T>(
      message: message,
      statusCode: statusCode,
      success: false,
    );
  }
}
