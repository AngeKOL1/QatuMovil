import 'package:dio/dio.dart';
import 'package:geolocator/geolocator.dart';
import '../core/core.dart';

class UbicacionService {
  final _client = DioClient.instance;

  Future<Position?> obtenerPosicion() async {
    final serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) return null;

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) return null;
    }
    if (permission == LocationPermission.deniedForever) return null;

    return await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.high,
    );
  }

  Future<ApiResponse<void>> publicarUbicacion(double lat, double lng) async {
    try {
      await _client.dio.patch(
        ApiConstants.miUbicacion,
        data: {'lat': lat, 'lng': lng},
      );
      return ApiResponse.success(null);
    } on DioException catch (e) {
      return ApiResponse.failure(_client.handleError(e).message);
    }
  }

  Future<ApiResponse<void>> cambiarEstado(bool visible) async {
    try {
      await _client.dio.patch(
        ApiConstants.miEstado,
        data: {'visible': visible},
      );
      return ApiResponse.success(null);
    } on DioException catch (e) {
      return ApiResponse.failure(_client.handleError(e).message);
    }
  }

  Future<ApiResponse<void>> registrarFcmToken(String fcmToken) async {
    try {
      await _client.dio.patch(
        ApiConstants.miFcmToken,
        data: {'fcmToken': fcmToken},
      );
      return ApiResponse.success(null);
    } on DioException catch (e) {
      return ApiResponse.failure(_client.handleError(e).message);
    }
  }

  // Stream para tracking continuo — publica al backend cada vez que
  // el vendedor se mueve más de 10 metros
  Stream<Position> streamPosicion() {
    return Geolocator.getPositionStream(
      locationSettings: const LocationSettings(
        accuracy: LocationAccuracy.high,
        distanceFilter: 10,
      ),
    );
  }
}
