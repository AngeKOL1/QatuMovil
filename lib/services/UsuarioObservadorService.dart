import 'package:dio/dio.dart';
import 'package:qatu_movil/models/usuarioObservador.dart';
import '../core/core.dart';

class ObservadorService {
  final _client = DioClient.instance;

  Future<ApiResponse<ObservadorPerfilDTO>> getMiPerfil() async {
    try {
      final response = await _client.dio.get('/observadores/mi-perfil');
      return ApiResponse.success(ObservadorPerfilDTO.fromJson(response.data));
    } on DioException catch (e) {
      return ApiResponse.failure(_client.handleError(e).message);
    } catch (e) {
      return ApiResponse.failure('Error inesperado: $e');
    }
  }
}
