import 'package:dio/dio.dart';
import '../core/core.dart';
import '../models/models.dart';

class VendedorService {
  final _client = DioClient.instance;
  final _storage = SecureStorageService();

  Future<ApiResponse<VendedorPerfilDTO>> getMiPerfil() async {
    try {
      final userId = await _storage.getUserId();
      if (userId == null) {
        return ApiResponse.failure('No hay sesión activa');
      }
      final response = await _client.dio.get('/vendedores/$userId/perfil');
      return ApiResponse.success(VendedorPerfilDTO.fromJson(response.data));
    } on DioException catch (e) {
      return ApiResponse.failure(_client.handleError(e).message);
    }
  }
}
