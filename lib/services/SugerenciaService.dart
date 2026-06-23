import 'package:dio/dio.dart';
import '../core/core.dart';
import '../models/models.dart';

class SugerenciaService {
  final _client = DioClient.instance;

  Future<ApiResponse<PaginaResponse<SugerenciaResponse>>> getMisSugerencias({
    int pagina = 0,
    int tamanio = 10,
  }) async {
    try {
      final response = await _client.dio.get(
        ApiConstants.misSugerencias,
        queryParameters: {'pagina': pagina, 'tamanio': tamanio},
      );
      return ApiResponse.success(
        PaginaResponse.fromJson(response.data, SugerenciaResponse.fromJson),
      );
    } on DioException catch (e) {
      return ApiResponse.failure(_client.handleError(e).message);
    } catch (e) {
      return ApiResponse.failure('Error inseperado: $e');
    }
  }

  // accion: 'ACEPTADA' | 'IGNORADA'
  Future<ApiResponse<void>> responderSugerencia(int id, String accion) async {
    try {
      await _client.dio.patch(
        '/sugerencias/$id/respuesta',
        data: {'accion': accion},
      );
      return ApiResponse.success(null);
    } on DioException catch (e) {
      return ApiResponse.failure(_client.handleError(e).message);
    } catch (e) {
      return ApiResponse.failure('Error inseperado: $e');
    }
  }
}
