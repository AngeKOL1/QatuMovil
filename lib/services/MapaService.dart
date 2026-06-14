import 'package:dio/dio.dart';
import '../core/core.dart';
import '../models/models.dart';

class MapaService {
  final _client = DioClient.instance;

  Future<ApiResponse<PaginaResponse<VendedorMapaDTO>>> getVendedores({
    String? categoria,
    int pagina = 0,
    int tamanio = 100, // más grande para el mapa
  }) async {
    try {
      final response = await _client.dio.get(
        ApiConstants.mapaVendedores,
        queryParameters: {
          if (categoria != null) 'categoria': categoria,
          'pagina': pagina,
          'tamanio': tamanio,
        },
      );
      return ApiResponse.success(
        PaginaResponse.fromJson(response.data, VendedorMapaDTO.fromJson),
      );
    } on DioException catch (e) {
      return ApiResponse.failure(_client.handleError(e).message);
    }
  }

  Future<ApiResponse<VendedorPerfilDTO>> getVendedorPerfil(int id) async {
    try {
      final response = await _client.dio.get('/vendedores/$id/perfil');
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
