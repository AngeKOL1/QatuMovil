class ApiConstants {
  // Dispositivo físico → IP de tu PC en la red local
  static const String baseUrl = 'http://192.168.100.27:6060/api';
  static const String wsUrl = 'ws://192.168.100.27:6060/ws/mapa-native';

  // Timeouts en milisegundos
  static const int connectTimeout = 15000;
  static const int receiveTimeout = 15000;

  // Auth
  static const String login = '/auth/login';
  static const String registerVendedor = '/auth/register/vendedor';
  static const String registerObservador = '/auth/register/observador';

  // Vendedor
  static const String miUbicacion = '/vendedores/mi-ubicacion';
  static const String miEstado = '/vendedores/mi-estado';
  static const String miFcmToken = '/vendedores/mi-fcm-token';
  // Productos
  static const String productosVendedor = '/productos'; // GET /{id}/productos
  static const String misProductos =
      '/productos/mis-productos'; // POST, PUT, DELETE
  static const String misReportes = '/reportes/mis-reportes';

  // Sugerencias
  static const String misSugerencias = '/sugerencias/mis-sugerencias';

  // Mapa
  static const String mapaVendedores = '/mapa/vendedores';
  static const String mapaHeatmap = '/mapa/heatmap';
  static const String mapaZonas = '/mapa/zonas';

  // WebSocket topics
  static const String wsUbicaciones = '/topic/mapa/ubicaciones';
  static const String wsCongestion = '/topic/mapa/congestion';
  static const String wsZonas = '/topic/mapa/zonas';
}
