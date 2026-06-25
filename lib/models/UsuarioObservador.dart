class ObservadorRegisterRequest {
  final String nombre;
  final String dni;
  final String email;
  final String telefono;
  final String password;
  final String confirmPassword; // ← faltaba

  ObservadorRegisterRequest({
    required this.nombre,
    required this.dni,
    required this.email,
    required this.telefono,
    required this.password,
    required this.confirmPassword,
  });

  Map<String, dynamic> toJson() => {
    'nombre': nombre,
    'dni': dni,
    'email': email,
    'telefono': telefono,
    'password': password,
    'confirmPassword': confirmPassword,
  };
}

class ObservadorPerfilDTO {
  final int id;
  final String nombre;
  final String dni;
  final String email;
  final String telefono;
  final String fechaRegistro;

  ObservadorPerfilDTO({
    required this.id,
    required this.nombre,
    required this.dni,
    required this.email,
    required this.telefono,
    required this.fechaRegistro,
  });

  factory ObservadorPerfilDTO.fromJson(Map<String, dynamic> json) =>
      ObservadorPerfilDTO(
        id: json['id'],
        nombre: json['nombre'],
        dni: json['dni'],
        email: json['email'],
        telefono: json['telefono'],
        fechaRegistro: json['fechaRegistro'],
      );
}
