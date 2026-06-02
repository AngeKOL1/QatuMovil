class LoginRequest {
  final String email;
  final String password;

  LoginRequest({required this.email, required this.password});

  Map<String, dynamic> toJson() => {'email': email, 'password': password};
}

class LoginResponse {
  final String token;
  final int id;
  final String nombre;
  final String email;
  final String rol;

  LoginResponse({
    required this.token,
    required this.id,
    required this.nombre,
    required this.email,
    required this.rol,
  });

  factory LoginResponse.fromJson(Map<String, dynamic> json) => LoginResponse(
    token: json['token'],
    id: json['id'],
    nombre: json['nombre'],
    email: json['email'],
    rol: json['rol'],
  );
}
