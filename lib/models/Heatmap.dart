// ── Heatmap ──────────────────────────────────────────────────

class HeatmapPunto {
  final double lat;
  final double lng;
  final int vendedoresCount;
  final String nivel; // ROJO | AMARILLO | VERDE

  HeatmapPunto({
    required this.lat,
    required this.lng,
    required this.vendedoresCount,
    required this.nivel,
  });

  factory HeatmapPunto.fromJson(Map<String, dynamic> json) => HeatmapPunto(
    lat: (json['lat'] as num).toDouble(),
    lng: (json['lng'] as num).toDouble(),
    vendedoresCount: json['vendedoresCount'],
    nivel: json['nivel'],
  );
}

class HeatmapResponse {
  final List<HeatmapPunto> puntos;
  final int umbralRojo;
  final int umbralAmarillo;
  final String calculadoEn;

  HeatmapResponse({
    required this.puntos,
    required this.umbralRojo,
    required this.umbralAmarillo,
    required this.calculadoEn,
  });

  factory HeatmapResponse.fromJson(Map<String, dynamic> json) =>
      HeatmapResponse(
        puntos: (json['puntos'] as List<dynamic>)
            .map((p) => HeatmapPunto.fromJson(p))
            .toList(),
        umbralRojo: json['umbralRojo'],
        umbralAmarillo: json['umbralAmarillo'],
        calculadoEn: json['calculadoEn'],
      );
}
