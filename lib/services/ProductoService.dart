import 'package:dio/dio.dart';
import '../core/core.dart';
import '../models/models.dart';

class ProductoService {
  final _client = DioClient.instance;

  Future<ApiResponse<PaginaResponse<ProductoDTO>>> getMisProductos({
    int pagina = 0,
    int tamanio = 10,
  }) async {
    try {
      final response = await _client.dio.get(
        ApiConstants.misProductos,
        queryParameters: {'pagina': pagina, 'tamanio': tamanio},
      );
      return ApiResponse.success(
        PaginaResponse.fromJson(response.data, ProductoDTO.fromJson),
      );
    } on DioException catch (e) {
      return ApiResponse.failure(_client.handleError(e).message);
    }
  }

  Future<ApiResponse<ProductoDTO>> crearProducto(
    ProductoRequest request,
  ) async {
    try {
      final response = await _client.dio.post(
        ApiConstants.misProductos,
        data: request.toJson(),
      );
      return ApiResponse.success(ProductoDTO.fromJson(response.data));
    } on DioException catch (e) {
      return ApiResponse.failure(_client.handleError(e).message);
    }
  }

  Future<ApiResponse<ProductoDTO>> actualizarProducto(
    int id,
    ProductoRequest request,
  ) async {
    try {
      final response = await _client.dio.put(
        '${ApiConstants.misProductos}/$id',
        data: request.toJson(),
      );
      return ApiResponse.success(ProductoDTO.fromJson(response.data));
    } on DioException catch (e) {
      return ApiResponse.failure(_client.handleError(e).message);
    }
  }

  Future<ApiResponse<void>> eliminarProducto(int id) async {
    try {
      await _client.dio.delete('${ApiConstants.misProductos}/$id');
      return ApiResponse.success(null);
    } on DioException catch (e) {
      return ApiResponse.failure(_client.handleError(e).message);
    }
  }

  Future<ApiResponse<PaginaResponse<ProductoDTO>>> getProductosVendedor(
    int vendedorId, {
    int pagina = 0,
    int tamanio = 10,
  }) async {
    try {
      final response = await _client.dio.get(
        '${ApiConstants.productosVendedor}/$vendedorId/productos',
        queryParameters: {'pagina': pagina, 'tamanio': tamanio},
      );
      return ApiResponse.success(
        PaginaResponse.fromJson(response.data, ProductoDTO.fromJson),
      );
    } on DioException catch (e) {
      return ApiResponse.failure(_client.handleError(e).message);
    }
  }
}
