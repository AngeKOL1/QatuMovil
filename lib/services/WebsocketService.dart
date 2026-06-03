import 'dart:convert';
import 'package:stomp_dart_client/stomp_dart_client.dart';
import '../core/core.dart';
import '../models/models.dart';

typedef UbicacionCallback = void Function(WsUbicacionEvent evento);
typedef CongestionCallback = void Function(Map<String, dynamic> evento);

class WebSocketService {
  StompClient? _client;
  bool _connected = false;
  final _storage = SecureStorageService();

  UbicacionCallback? onUbicacionActualizada;
  CongestionCallback? onCongestionDetectada;

  Future<void> connect() async {
    if (_connected) return;

    final token = await _storage.getToken();

    _client = StompClient(
      config: StompConfig.sockJS(
        url: ApiConstants.wsUrl,
        onConnect: _onConnected,
        onDisconnect: _onDisconnected,
        onWebSocketError: (error) => print('[WS] Error: $error'),
        stompConnectHeaders: token != null
            ? {'Authorization': 'Bearer $token'}
            : {},
        webSocketConnectHeaders: token != null
            ? {'Authorization': 'Bearer $token'}
            : {},
      ),
    );
    _client!.activate();
  }

  void _onConnected(StompFrame frame) {
    _connected = true;

    _client!.subscribe(
      destination: ApiConstants.wsUbicaciones,
      callback: (frame) {
        if (frame.body == null) return;
        try {
          final json = jsonDecode(frame.body!);
          final evento = WsUbicacionEvent.fromJson(json);
          onUbicacionActualizada?.call(evento);
        } catch (e) {
          print('[WS] Error parseando ubicación: $e');
        }
      },
    );

    _client!.subscribe(
      destination: ApiConstants.wsCongestion,
      callback: (frame) {
        if (frame.body == null) return;
        try {
          final json = jsonDecode(frame.body!);
          onCongestionDetectada?.call(json);
        } catch (e) {
          print('[WS] Error parseando congestión: $e');
        }
      },
    );
  }

  void _onDisconnected(StompFrame frame) {
    _connected = false;
  }

  bool get isConnected => _connected;

  void disconnect() {
    _client?.deactivate();
    _connected = false;
  }
}
