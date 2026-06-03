class AppException implements Exception {
  final String message;
  final int? statusCode;

  AppException(this.message, {this.statusCode});

  @override
  String toString() => message;
}

class UnauthorizedException extends AppException {
  UnauthorizedException()
    : super('Sesión expirada. Inicia sesión nuevamente.', statusCode: 401);
}

class NotFoundException extends AppException {
  NotFoundException(String message) : super(message, statusCode: 404);
}

class ServerException extends AppException {
  ServerException([String? message])
    : super(
        message ?? 'Error del servidor. Intenta más tarde.',
        statusCode: 500,
      );
}

class NetworkException extends AppException {
  NetworkException() : super('Sin conexión. Verifica tu red.');
}

class ValidationException extends AppException {
  final Map<String, String>? errors;

  ValidationException(String message, {this.errors})
    : super(message, statusCode: 422);
}
