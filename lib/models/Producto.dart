class ProductoDTO {
  final int id;
  final String nombre;
  final double precio;
  final String? descripcion;
  final String? fotoUrl;
  final bool activo;
  final int vendedorId;
  final String nombreVendedor;
  final String fechaCreacion;

  ProductoDTO({
    required this.id,
    required this.nombre,
    required this.precio,
    this.descripcion,
    this.fotoUrl,
    required this.activo,
    required this.vendedorId,
    required this.nombreVendedor,
    required this.fechaCreacion,
  });

  factory ProductoDTO.fromJson(Map<String, dynamic> json) => ProductoDTO(
    id: json['id'],
    nombre: json['nombre'],
    precio: (json['precio'] as num).toDouble(),
    descripcion: json['descripcion'],
    fotoUrl: json['fotoUrl'],
    activo: json['activo'],
    vendedorId: json['vendedorId'],
    nombreVendedor: json['nombreVendedor'],
    fechaCreacion: json['fechaCreacion'],
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
