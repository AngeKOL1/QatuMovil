class VendedorMapaDTO {
  final int id;
  final String nombreNegocio;
  final String categoria;
  final String movilidad;
  final double lat;
  final double lng;
  final bool visible;

  VendedorMapaDTO({
    required this.id,
    required this.nombreNegocio,
    required this.categoria,
    required this.movilidad,
    required this.lat,
    required this.lng,
    required this.visible,
  });

  factory VendedorMapaDTO.fromJson(Map<String, dynamic> json) =>
      VendedorMapaDTO(
        id: json['id'],
        nombreNegocio: json['nombreNegocio'],
        categoria: json['categoria'],
        movilidad: json['movilidad'],
        lat: (json['lat'] as num).toDouble(),
        lng: (json['lng'] as num).toDouble(),
        visible: json['visible'],
      );

  // Actualización desde evento WebSocket
  VendedorMapaDTO copyWith({double? lat, double? lng, bool? visible}) =>
      VendedorMapaDTO(
        id: id,
        nombreNegocio: nombreNegocio,
        categoria: categoria,
        movilidad: movilidad,
        lat: lat ?? this.lat,
        lng: lng ?? this.lng,
        visible: visible ?? this.visible,
      );
}
