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
  final String asunto;
  final String descripcion;
  final String estado;
  final String fechaEnvio;

  ReporteResponse({
    required this.id,
    required this.asunto,
    required this.descripcion,
    required this.estado,
    required this.fechaEnvio,
  });

  factory ReporteResponse.fromJson(Map<String, dynamic> json) =>
      ReporteResponse(
        id: json['id'],
        asunto: json['asunto'],
        descripcion: json['descripcion'],
        estado: json['estado'],
        fechaEnvio: json['fechaEnvio'],
      );
}
