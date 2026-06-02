class ProductoDTO {
  final int id;
  final String nombre;
  final double precio;
  final String? fotoUrl;
  final bool activo;

  ProductoDTO({
    required this.id,
    required this.nombre,
    required this.precio,
    this.fotoUrl,
    required this.activo,
  });

  factory ProductoDTO.fromJson(Map<String, dynamic> json) => ProductoDTO(
    id: json['id'],
    nombre: json['nombre'],
    precio: (json['precio'] as num).toDouble(),
    fotoUrl: json['fotoUrl'],
    activo: json['activo'],
  );
}

class ProductoRequest {
  final String nombre;
  final double precio;
  final String? descripcion;
  final String? fotoUrl;

  ProductoRequest({
    required this.nombre,
    required this.precio,
    this.descripcion,
    this.fotoUrl,
  });

  Map<String, dynamic> toJson() => {
    'nombre': nombre,
    'precio': precio,
    if (descripcion != null) 'descripcion': descripcion,
    if (fotoUrl != null) 'fotoUrl': fotoUrl,
  };
}
