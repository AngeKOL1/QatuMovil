import 'dart:convert';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import '../core.dart';

typedef RutaSugeridaCallback =
    void Function(double latDestino, double lngDestino);
typedef SugerenciaCallback = void Function();

class FcmHandler {
  static final FcmHandler _instance = FcmHandler._();
  static FcmHandler get instance => _instance;

  FcmHandler._();

  final _localNotifications = FlutterLocalNotificationsPlugin();
  final _storage = SecureStorageService();

  // Callbacks que el mapa asigna
  RutaSugeridaCallback? onRutaSugerida;
  SugerenciaCallback? onSugerenciaReasignacion;

  Future<void> initialize() async {
    // Notificaciones locales
    const androidSettings = AndroidInitializationSettings(
      '@mipmap/ic_launcher',
    );
    const initSettings = InitializationSettings(android: androidSettings);

    await _localNotifications.initialize(
      initSettings,
      onDidReceiveNotificationResponse: _onNotificationTapped,
    );

    const channel = AndroidNotificationChannel(
      'qatu_channel',
      'Qatu Notificaciones',
      description: 'Notificaciones de congestión y rutas sugeridas',
      importance: Importance.high,
    );

    final androidPlugin = _localNotifications
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >();

    if (androidPlugin != null) {
      await androidPlugin.createNotificationChannel(channel);
    }

    // Permisos FCM
    await FirebaseMessaging.instance.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );

    // Listeners
    FirebaseMessaging.onMessage.listen(_handleForegroundMessage);
    FirebaseMessaging.onMessageOpenedApp.listen(_handleMessageOpenedApp);

    final initialMessage = await FirebaseMessaging.instance.getInitialMessage();
    if (initialMessage != null) {
      _handleMessageOpenedApp(initialMessage);
    }

    // Token FCM
    final token = await FirebaseMessaging.instance.getToken();
    if (token != null) {
      print('🔑 FCM TOKEN: $token'); // ← agregar
      await _registrarToken(token);
    }
    FirebaseMessaging.instance.onTokenRefresh.listen(_registrarToken);
  }

  Future<void> _registrarToken(String token) async {
    try {
      final hasSession = await _storage.hasSession();
      final rol = await _storage.getRol();
      if (hasSession && rol == 'VENDEDOR') {
        await DioClient.instance.dio.patch(
          ApiConstants.miFcmToken,
          data: {'fcmToken': token},
        );
      }
    } catch (_) {}
  }

  void _handleForegroundMessage(RemoteMessage message) {
    final tipo = message.data['tipo'];

    if (tipo == 'RUTA_SUGERIDA') {
      final lat = double.tryParse(message.data['latDestino'] ?? '');
      final lng = double.tryParse(message.data['lngDestino'] ?? '');
      if (lat != null && lng != null) {
        onRutaSugerida?.call(lat, lng);
      }
    }

    if (tipo == 'SUGERENCIA_REASIGNACION') {
      onSugerenciaReasignacion?.call();
    }

    // Mostrar notificación local
    _mostrarNotificacion(message);
  }

  void _handleMessageOpenedApp(RemoteMessage message) {
    _procesarData(message.data);
  }

  void _onNotificationTapped(NotificationResponse response) {
    if (response.payload == null) return;
    try {
      final data = jsonDecode(response.payload!) as Map<String, dynamic>;
      _procesarData(data);
    } catch (_) {}
  }

  void _procesarData(Map<String, dynamic> data) {
    final tipo = data['tipo'];

    if (tipo == 'RUTA_SUGERIDA') {
      final lat = double.tryParse(data['latDestino'] ?? '');
      final lng = double.tryParse(data['lngDestino'] ?? '');
      if (lat != null && lng != null) {
        onRutaSugerida?.call(lat, lng);
      }
    }

    if (tipo == 'SUGERENCIA_REASIGNACION') {
      onSugerenciaReasignacion?.call();
    }
  }

  Future<void> _mostrarNotificacion(RemoteMessage message) async {
    const androidDetails = AndroidNotificationDetails(
      'qatu_channel',
      'Qatu Notificaciones',
      channelDescription: 'Notificaciones de congestión y rutas sugeridas',
      importance: Importance.high,
      priority: Priority.high,
    );

    await _localNotifications.show(
      DateTime.now().millisecondsSinceEpoch ~/ 1000,
      message.notification?.title ?? 'Qatu',
      message.notification?.body ?? '',
      const NotificationDetails(android: androidDetails),
      payload: jsonEncode(message.data),
    );
  }
}
