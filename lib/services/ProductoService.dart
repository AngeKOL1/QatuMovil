import 'package:dio/dio.dart';
import '../core/core.dart';
import '../models/models.dart';

class ProductoService {
  final _client = DioClient.instance;

  Future<ApiResponse<List<ProductoDTO>>> getMisProductos() async {
    try {
      final response = await _client.dio.get(ApiConstants.misProductos);
      final productos = (response.data as List<dynamic>)
          .map((p) => ProductoDTO.fromJson(p))
          .toList();
      return ApiResponse.success(productos);
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
}
