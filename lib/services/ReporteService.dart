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

  Future<ApiResponse<List<ReporteResponse>>> getMisReportes() async {
    try {
      final response = await _client.dio.get(ApiConstants.misReportes);
      final reportes = (response.data as List<dynamic>)
          .map((r) => ReporteResponse.fromJson(r))
          .toList();
      return ApiResponse.success(reportes);
    } on DioException catch (e) {
      return ApiResponse.failure(_client.handleError(e).message);
    }
  }
}
