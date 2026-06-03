import 'package:dio/dio.dart';
import '../core/core.dart';
import '../models/models.dart';

class MapaService {
  final _client = DioClient.instance;

  Future<ApiResponse<List<VendedorMapaDTO>>> getVendedores({
    String? categoria,
  }) async {
    try {
      final response = await _client.dio.get(
        ApiConstants.mapaVendedores,
        queryParameters: categoria != null ? {'categoria': categoria} : null,
      );
      final vendedores = (response.data as List<dynamic>)
          .map((v) => VendedorMapaDTO.fromJson(v))
          .toList();
      return ApiResponse.success(vendedores);
    } on DioException catch (e) {
      return ApiResponse.failure(_client.handleError(e).message);
    }
  }

  Future<ApiResponse<VendedorPerfilDTO>> getVendedorPerfil(int id) async {
    try {
      final response = await _client.dio.get('/vendedores/$id');
      return ApiResponse.success(VendedorPerfilDTO.fromJson(response.data));
    } on DioException catch (e) {
      return ApiResponse.failure(_client.handleError(e).message);
    }
  }

  Future<ApiResponse<HeatmapResponse>> getHeatmap() async {
    try {
      final response = await _client.dio.get(ApiConstants.mapaHeatmap);
      return ApiResponse.success(HeatmapResponse.fromJson(response.data));
    } on DioException catch (e) {
      return ApiResponse.failure(_client.handleError(e).message);
    }
  }

  Future<ApiResponse<List<ZonaResponse>>> getZonas({String? tipo}) async {
    try {
      final response = await _client.dio.get(
        ApiConstants.mapaZonas,
        queryParameters: tipo != null ? {'tipo': tipo} : null,
      );
      final zonas = (response.data as List<dynamic>)
          .map((z) => ZonaResponse.fromJson(z))
          .toList();
      return ApiResponse.success(zonas);
    } on DioException catch (e) {
      return ApiResponse.failure(_client.handleError(e).message);
    }
  }
}
