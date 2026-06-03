import 'package:dio/dio.dart';
import '../core/core.dart';
import '../models/models.dart';

class SugerenciaService {
  final _client = DioClient.instance;

  Future<ApiResponse<List<SugerenciaResponse>>> getMisSugerencias() async {
    try {
      final response = await _client.dio.get(ApiConstants.misSugerencias);
      final sugerencias = (response.data as List<dynamic>)
          .map((s) => SugerenciaResponse.fromJson(s))
          .toList();
      return ApiResponse.success(sugerencias);
    } on DioException catch (e) {
      return ApiResponse.failure(_client.handleError(e).message);
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
    }
  }
}
