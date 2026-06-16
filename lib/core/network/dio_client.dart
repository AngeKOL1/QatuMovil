import 'package:dio/dio.dart';
import '../constants/api_constants.dart';
import '../storage/secure_storage.dart';
import '../errors/exceptions.dart';

class DioClient {
  static DioClient? _instance;
  late final Dio _dio;
  final SecureStorageService _storage = SecureStorageService();

  DioClient._() {
    _dio = Dio(
      BaseOptions(
        baseUrl: ApiConstants.baseUrl,
        connectTimeout: const Duration(
          milliseconds: ApiConstants.connectTimeout,
        ),
        receiveTimeout: const Duration(
          milliseconds: ApiConstants.receiveTimeout,
        ),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      ),
    );
    _setupInterceptors();
  }

  static DioClient get instance {
    _instance ??= DioClient._();
    return _instance!;
  }

  Dio get dio => _dio;

  void _setupInterceptors() {
    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          // Inyecta JWT automáticamente en cada request
          final token = await _storage.getToken();
          if (token != null) {
            options.headers['Authorization'] = 'Bearer $token';
          }
          return handler.next(options);
        },
        onResponse: (response, handler) {
          return handler.next(response);
        },
        onError: (DioException e, handler) async {
          if (e.response?.statusCode == 401) {
            // Token expirado → limpiar sesión
            await _storage.clearAll();
            return handler.reject(
              DioException(
                requestOptions: e.requestOptions,
                error: UnauthorizedException(),
                type: DioExceptionType.badResponse,
              ),
            );
          }
          return handler.next(e);
        },
      ),
    );

    // Logger solo en debug
    _dio.interceptors.add(
      LogInterceptor(
        requestBody: true,
        responseBody: true,
        error: true,
        logPrint: (o) => debugPrint('[DIO] $o'),
      ),
    );
  }

  // Convierte errores Dio en excepciones de la app
  AppException handleError(DioException e) {
    if (e.error is AppException) return e.error as AppException;
    switch (e.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.receiveTimeout:
      case DioExceptionType.sendTimeout:
        return NetworkException();

      case DioExceptionType.badResponse:
        final status = e.response?.statusCode;
        final body = e.response?.data;

        String msg = 'Error $status';

        if (body is Map<String, dynamic>) {
          // Si tiene errores por campo, construir mensaje legible
          if (body['campos'] != null && body['campos'] is Map) {
            final campos = body['campos'] as Map<String, dynamic>;
            msg = campos.values.join('\n');
          } else {
            msg =
                body['detail']?.toString() ??
                body['message']?.toString() ??
                body['error']?.toString() ??
                body['title']?.toString() ??
                msg;
          }
        }

        if (status == 401) return UnauthorizedException();
        if (status == 404) return NotFoundException(msg);
        if (status == 400 || status == 422) return ValidationException(msg);

        return ServerException(msg);

      case DioExceptionType.connectionError:
        return NetworkException();
      default:
        return AppException('Error inesperado. Intenta nuevamente.');
    }
  }
}

// Helper para imprimir en debug (reemplaza print)
void debugPrint(String message) {
  // ignore: avoid_print
  print(message);
}
