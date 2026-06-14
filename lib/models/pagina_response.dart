class PaginaResponse<T> {
  final List<T> contenido;
  final int paginaActual;
  final int totalPaginas;
  final int totalElementos;
  final int tamanioPagina;
  final bool esUltima;
  final bool esPrimera;

  PaginaResponse({
    required this.contenido,
    required this.paginaActual,
    required this.totalPaginas,
    required this.totalElementos,
    required this.tamanioPagina,
    required this.esUltima,
    required this.esPrimera,
  });

  factory PaginaResponse.fromJson(
    Map<String, dynamic> json,
    T Function(Map<String, dynamic>) fromJsonT,
  ) {
    return PaginaResponse(
      contenido: (json['contenido'] as List)
          .map((e) => fromJsonT(e as Map<String, dynamic>))
          .toList(),
      paginaActual: json['paginaActual'],
      totalPaginas: json['totalPaginas'],
      totalElementos: json['totalElementos'],
      tamanioPagina: json['tamanioPagina'],
      esUltima: json['esUltima'],
      esPrimera: json['esPrimera'],
    );
  }
}
