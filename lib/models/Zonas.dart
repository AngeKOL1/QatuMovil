class ZonaResponse {
  final int id;
  final String nombre;
  final String tipoZona; // RESTRINGIDA | REASIGNACION
  final int? capacidadMaxima;
  final bool activa;
  final List<List<double>> coordenadas; // [[lng, lat], ...]

  ZonaResponse({
    required this.id,
    required this.nombre,
    required this.tipoZona,
    this.capacidadMaxima,
    required this.activa,
    required this.coordenadas,
  });

  factory ZonaResponse.fromJson(Map<String, dynamic> json) => ZonaResponse(
    id: json['id'],
    nombre: json['nombre'],
    tipoZona: json['tipoZona'],
    capacidadMaxima: json['capacidadMaxima'],
    activa: json['activa'],
    coordenadas: (json['coordenadas'] as List<dynamic>)
        .map(
          (c) =>
              (c as List<dynamic>).map((v) => (v as num).toDouble()).toList(),
        )
        .toList(),
  );
}
