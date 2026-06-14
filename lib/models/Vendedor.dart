import 'package:qatu_movil/models/Producto.dart';

class VendedorRegisterRequest {
  final String nombre;
  final String email;
  final String password;
  final String dni;
  final String telefono;
  final String? descripcion;
  final String tipoMovilidad;
  final String horarioInicio; // "07:00:00"
  final String horarioFin; // "18:00:00"
  final String nombreCategoria;

  VendedorRegisterRequest({
    required this.nombre,
    required this.email,
    required this.password,
    required this.dni,
    required this.telefono,
    this.descripcion,
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
    if (descripcion != null) 'descripcion': descripcion,
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
  final double? lat;
  final double? lng;

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
    this.lat,
    this.lng,
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
        lat: json['lat'] != null ? (json['lat'] as num).toDouble() : null,
        lng: json['lng'] != null ? (json['lng'] as num).toDouble() : null,
      );
}
