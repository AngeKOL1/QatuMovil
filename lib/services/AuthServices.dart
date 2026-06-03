import 'package:dio/dio.dart';
import '../core/core.dart';
import '../models/models.dart';

class AuthService {
  final _client = DioClient.instance;
  final _storage = SecureStorageService();

  Future<ApiResponse<LoginResponse>> login(LoginRequest request) async {
    try {
      final response = await _client.dio.post(
        ApiConstants.login,
        data: request.toJson(),
      );
      final loginResp = LoginResponse.fromJson(response.data);
      await _storage.saveToken(loginResp.token);
      await _storage.saveSession(
        id: loginResp.id,
        nombre: loginResp.nombre,
        email: loginResp.email,
        rol: loginResp.rol,
      );
      return ApiResponse.success(loginResp);
    } on DioException catch (e) {
      return ApiResponse.failure(_client.handleError(e).message);
    }
  }

  Future<ApiResponse<void>> registerVendedor(
    VendedorRegisterRequest request,
  ) async {
    try {
      await _client.dio.post(
        ApiConstants.registerVendedor,
        data: request.toJson(),
      );
      return ApiResponse.success(null);
    } on DioException catch (e) {
      return ApiResponse.failure(_client.handleError(e).message);
    }
  }

  Future<ApiResponse<void>> registerObservador(
    ObservadorRegisterRequest request,
  ) async {
    try {
      await _client.dio.post(
        ApiConstants.registerObservador,
        data: request.toJson(),
      );
      return ApiResponse.success(null);
    } on DioException catch (e) {
      return ApiResponse.failure(_client.handleError(e).message);
    }
  }

  Future<void> logout() async {
    await _storage.clearAll();
  }

  Future<bool> isLoggedIn() => _storage.hasSession();
  Future<String?> getRol() => _storage.getRol();
  Future<String?> getUserId() => _storage.getUserId();
}
