import 'package:dio/dio.dart';
import '../core/core.dart';
import '../models/models.dart';

class ProductoService {
  final _client = DioClient.instance;
  final _storage = SecureStorageService();

  // Listar MIS productos (necesita id del vendedor)
  Future<ApiResponse<PaginaResponse<ProductoDTO>>> getMisProductos({
    int pagina = 0,
    int tamanio = 10,
  }) async {
    try {
      final userId = await _storage.getUserId();
      if (userId == null) {
        return ApiResponse.failure('No hay sesión activa');
      }
      final response = await _client.dio.get(
        '${ApiConstants.productosVendedor}/$userId/productos',
        queryParameters: {'pagina': pagina, 'tamanio': tamanio},
      );
      return ApiResponse.success(
        PaginaResponse.fromJson(response.data, ProductoDTO.fromJson),
      );
    } on DioException catch (e) {
      return ApiResponse.failure(_client.handleError(e).message);
    } catch (e) {
      return ApiResponse.failure('Error inesperado: $e');
    }
  }

  // Listar productos de OTRO vendedor (público)
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
    } catch (e) {
      return ApiResponse.failure('Error inesperado: $e');
    }
  }

  // Crear producto (JWT maneja el vendedor)
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
    } catch (e) {
      return ApiResponse.failure('Error inesperado: $e');
    }
  }

  // Actualizar producto (JWT maneja el vendedor)
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
    } catch (e) {
      return ApiResponse.failure('Error inesperado: $e');
    }
  }

  // Eliminar producto (JWT maneja el vendedor)
  Future<ApiResponse<void>> eliminarProducto(int id) async {
    try {
      await _client.dio.delete('${ApiConstants.misProductos}/$id');
      return ApiResponse.success(null);
    } on DioException catch (e) {
      return ApiResponse.failure(_client.handleError(e).message);
    } catch (e) {
      return ApiResponse.failure('Error inesperado: $e');
    }
  }
}
