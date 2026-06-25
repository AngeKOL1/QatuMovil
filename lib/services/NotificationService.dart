import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:qatu_movil/services/Service.dart';
import '../core/core.dart';

class NotificationService {
  final _messaging = FirebaseMessaging.instance;
  final _ubicacionService = UbicacionService();

  Future<void> initialize() async {
    // Pedir permisos
    final settings = await _messaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );

    if (settings.authorizationStatus == AuthorizationStatus.denied) {
      return;
    }

    // Obtener token FCM y registrarlo en el backend
    final token = await _messaging.getToken();
    if (token != null) {
      await _registrarToken(token);
    }

    // Escuchar cambios de token (se renueva periódicamente)
    _messaging.onTokenRefresh.listen(_registrarToken);

    // Notificaciones en foreground
    FirebaseMessaging.onMessage.listen(_handleForegroundMessage);

    // Cuando el usuario toca una notificación (app en background)
    FirebaseMessaging.onMessageOpenedApp.listen(_handleMessageOpenedApp);

    // Verificar si la app se abrió desde una notificación
    final initialMessage = await _messaging.getInitialMessage();
    if (initialMessage != null) {
      _handleMessageOpenedApp(initialMessage);
    }
  }

  Future<void> _registrarToken(String token) async {
    try {
      final storage = SecureStorageService();
      final hasSession = await storage.hasSession();
      final rol = await storage.getRol();

      // Solo registrar si es vendedor con sesión activa
      if (hasSession && rol == 'VENDEDOR') {
        await _ubicacionService.registrarFcmToken(token);
      }
    } catch (e) {
      // Silenciar errores de registro de token
    }
  }

  void _handleForegroundMessage(RemoteMessage message) {
    // La notificación llegó con la app abierta
    // Firebase la muestra automáticamente si tiene notification payload
  }

  void _handleMessageOpenedApp(RemoteMessage message) {
    // El usuario tocó la notificación
    // Aquí podrías navegar a una pantalla específica según la data
    final data = message.data;
    if (data.containsKey('tipo')) {
      switch (data['tipo']) {
        case 'SUGERENCIA':
          NavigationService.navigatorKey.currentState?.pushNamed(
            '/sugerencias',
          );
          break;
        case 'CONGESTION':
          NavigationService.navigatorKey.currentState?.pushNamed('/mapa');
          break;
      }
    }
  }
}
