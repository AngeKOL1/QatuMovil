class WsUbicacionEvent {
  final String evento; // UBICACION_ACTUALIZADA | VENDEDOR_INACTIVO
  final int vendedorId;
  final String nombreNegocio;
  final String categoria;
  final double lat;
  final double lng;
  final bool visible;
  final String timestamp;

  WsUbicacionEvent({
    required this.evento,
    required this.vendedorId,
    required this.nombreNegocio,
    required this.categoria,
    required this.lat,
    required this.lng,
    required this.visible,
    required this.timestamp,
  });

  factory WsUbicacionEvent.fromJson(Map<String, dynamic> json) =>
      WsUbicacionEvent(
        evento: json['evento'],
        vendedorId: json['vendedorId'],
        nombreNegocio: json['nombreNegocio'],
        categoria: json['categoria'],
        lat: (json['lat'] as num).toDouble(),
        lng: (json['lng'] as num).toDouble(),
        visible: json['visible'],
        timestamp: json['timestamp'],
      );
}
