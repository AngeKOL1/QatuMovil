import 'package:qatu_movil/models/Producto.dart';

class VendedorRegisterRequest {
  final String nombre;
  final String email;
  final String password;
  final String dni;
  final String telefono;
  final String descripcion;
  final String tipoMovilidad; // FIJO | CARRITO | CAMIONETA
  final String horarioInicio; // "07:00"
  final String horarioFin;
  final String
  nombreCategoria; // COMIDA | ROPA | ELECTRONICA | SERVICIOS | OTROS

  VendedorRegisterRequest({
    required this.nombre,
    required this.email,
    required this.password,
    required this.dni,
    required this.telefono,
    required this.descripcion,
    required this.tipoMovilidad,
    required this.horarioInicio,
    required this.horarioFin,
    required this.nombreCategoria,
  });

  Map<String, dynamic> toJson() => {
    'nombre': nombre,
    'email': email,
    'password': password,
    'dni': dni,
    'telefono': telefono,
    'descripcion': descripcion,
    'tipoMovilidad': tipoMovilidad,
    'horarioInicio': horarioInicio,
    'horarioFin': horarioFin,
    'nombreCategoria': nombreCategoria,
  };
}

class VendedorPerfilDTO {
  final int id;
  final String nombre;
  final String nombreNegocio;
  final String? descripcion;
  final String? fotoPerfilUrl;
  final String categoria;
  final String movilidad;
  final String horarioInicio;
  final String horarioFin;
  final bool visible;
  final double lat;
  final double lng;
  final List<ProductoDTO> productos;

  VendedorPerfilDTO({
    required this.id,
    required this.nombre,
    required this.nombreNegocio,
    this.descripcion,
    this.fotoPerfilUrl,
    required this.categoria,
    required this.movilidad,
    required this.horarioInicio,
    required this.horarioFin,
    required this.visible,
    required this.lat,
    required this.lng,
    required this.productos,
  });

  factory VendedorPerfilDTO.fromJson(Map<String, dynamic> json) =>
      VendedorPerfilDTO(
        id: json['id'],
        nombre: json['nombre'],
        nombreNegocio: json['nombreNegocio'],
        descripcion: json['descripcion'],
        fotoPerfilUrl: json['fotoPerfilUrl'],
        categoria: json['categoria'],
        movilidad: json['movilidad'],
        horarioInicio: json['horarioInicio'],
        horarioFin: json['horarioFin'],
        visible: json['visible'],
        lat: (json['lat'] as num).toDouble(),
        lng: (json['lng'] as num).toDouble(),
        productos: (json['productos'] as List<dynamic>)
            .map((p) => ProductoDTO.fromJson(p))
            .toList(),
      );
}
