class ReporteRequest {
  final String asunto;
  final String descripcion;

  ReporteRequest({required this.asunto, required this.descripcion});

  Map<String, dynamic> toJson() => {
    'asunto': asunto,
    'descripcion': descripcion,
  };
}

class ReporteResponse {
  final int id;
  final int vendedorId;
  final String vendedorNombre;
  final String asunto;
  final String descripcion;
  final String estado;
  final String createdAt;

  ReporteResponse({
    required this.id,
    required this.vendedorId,
    required this.vendedorNombre,
    required this.asunto,
    required this.descripcion,
    required this.estado,
    required this.createdAt,
  });

  factory ReporteResponse.fromJson(Map<String, dynamic> json) =>
      ReporteResponse(
        id: json['id'],
        vendedorId: json['vendedorId'],
        vendedorNombre: json['vendedorNombre'],
        asunto: json['asunto'],
        descripcion: json['descripcion'],
        estado: json['estado'],
        createdAt: json['createdAt'],
      );
}
