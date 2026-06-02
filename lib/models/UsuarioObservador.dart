class ObservadorRegisterRequest {
  final String nombre;
  final String apellidos;
  final String dni;
  final String telefono;
  final String email;
  final String password;

  ObservadorRegisterRequest({
    required this.nombre,
    required this.apellidos,
    required this.dni,
    required this.telefono,
    required this.email,
    required this.password,
  });

  Map<String, dynamic> toJson() => {
    'nombre': nombre,
    'apellidos': apellidos,
    'dni': dni,
    'telefono': telefono,
    'email': email,
    'password': password,
  };
}
