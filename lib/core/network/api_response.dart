class ApiResponse<T> {
  final T? data;
  final String? error;
  final bool success;

  ApiResponse.success(this.data) : success = true, error = null;

  ApiResponse.failure(this.error) : success = false, data = null;

  bool get hasData => success && data != null;
}
