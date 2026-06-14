import 'package:dio/dio.dart';
import '../core/core.dart';
import '../models/models.dart';

class ReporteService {
  final _client = DioClient.instance;

  Future<ApiResponse<ReporteResponse>> crearReporte(
    ReporteRequest request,
  ) async {
    try {
      final response = await _client.dio.post(
        ApiConstants.misReportes,
        data: request.toJson(),
      );
      return ApiResponse.success(ReporteResponse.fromJson(response.data));
    } on DioException catch (e) {
      return ApiResponse.failure(_client.handleError(e).message);
    }
  }

  Future<ApiResponse<PaginaResponse<ReporteResponse>>> getMisReportes({
    int pagina = 0,
    int tamanio = 10,
  }) async {
    try {
      final response = await _client.dio.get(
        ApiConstants.misReportes,
        queryParameters: {'pagina': pagina, 'tamanio': tamanio},
      );
      return ApiResponse.success(
        PaginaResponse.fromJson(response.data, ReporteResponse.fromJson),
      );
    } on DioException catch (e) {
      return ApiResponse.failure(_client.handleError(e).message);
    }
  }
}
