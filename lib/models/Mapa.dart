class VendedorMapaDTO {
  final int id;
  final String nombreNegocio;
  final String categoria;
  final String movilidad;
  final double? lat; // ← nullable
  final double? lng; // ← nullable
  final bool visible;

  VendedorMapaDTO({
    required this.id,
    required this.nombreNegocio,
    required this.categoria,
    required this.movilidad,
    this.lat,
    this.lng,
    required this.visible,
  });

  factory VendedorMapaDTO.fromJson(Map<String, dynamic> json) =>
      VendedorMapaDTO(
        id: json['id'],
        nombreNegocio: json['nombreNegocio'],
        categoria: json['categoria'],
        movilidad: json['movilidad'],
        lat: json['lat'] != null ? (json['lat'] as num).toDouble() : null,
        lng: json['lng'] != null ? (json['lng'] as num).toDouble() : null,
        visible: json['visible'],
      );

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
