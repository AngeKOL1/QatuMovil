class SugerenciaResponse {
  final int id;
  final int vendedorId;
  final String nombreVendedor;
  final int zonaId;
  final String nombreZona;
  final String tipoZona;
  final String estado; // ENVIADA | ACEPTADA | IGNORADA
  final String fechaEnvio;
  final String? fechaRespuesta;

  SugerenciaResponse({
    required this.id,
    required this.vendedorId,
    required this.nombreVendedor,
    required this.zonaId,
    required this.nombreZona,
    required this.tipoZona,
    required this.estado,
    required this.fechaEnvio,
    this.fechaRespuesta,
  });

  factory SugerenciaResponse.fromJson(Map<String, dynamic> json) =>
      SugerenciaResponse(
        id: json['id'],
        vendedorId: json['vendedorId'],
        nombreVendedor: json['nombreVendedor'],
        zonaId: json['zonaId'],
        nombreZona: json['nombreZona'],
        tipoZona: json['tipoZona'],
        estado: json['estado'],
        fechaEnvio: json['fechaEnvio'],
        fechaRespuesta: json['fechaRespuesta'],
      );
}
