import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class SecureStorageService {
  static const _storage = FlutterSecureStorage(
    aOptions: AndroidOptions(encryptedSharedPreferences: true),
  );

  static const _keyToken = 'jwt_token';
  static const _keyUserId = 'user_id';
  static const _keyUserName = 'user_name';
  static const _keyUserEmail = 'user_email';
  static const _keyUserRol = 'user_rol';

  // Token JWT
  Future<void> saveToken(String token) =>
      _storage.write(key: _keyToken, value: token);

  Future<String?> getToken() => _storage.read(key: _keyToken);

  Future<void> deleteToken() => _storage.delete(key: _keyToken);

  // Datos de sesión
  Future<void> saveSession({
    required int id,
    required String nombre,
    required String email,
    required String rol,
  }) async {
    await Future.wait([
      _storage.write(key: _keyUserId, value: id.toString()),
      _storage.write(key: _keyUserName, value: nombre),
      _storage.write(key: _keyUserEmail, value: email),
      _storage.write(key: _keyUserRol, value: rol),
    ]);
  }

  Future<Map<String, String?>> getSession() async {
    final results = await Future.wait([
      _storage.read(key: _keyUserId),
      _storage.read(key: _keyUserName),
      _storage.read(key: _keyUserEmail),
      _storage.read(key: _keyUserRol),
    ]);
    return {
      'id': results[0],
      'nombre': results[1],
      'email': results[2],
      'rol': results[3],
    };
  }

  Future<String?> getRol() => _storage.read(key: _keyUserRol);

  Future<String?> getUserId() => _storage.read(key: _keyUserId);

  // Limpiar todo al cerrar sesión
  Future<void> clearAll() => _storage.deleteAll();

  Future<bool> hasSession() async {
    final token = await getToken();
    return token != null && token.isNotEmpty;
  }
}
