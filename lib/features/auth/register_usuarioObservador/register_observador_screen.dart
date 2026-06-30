import 'package:flutter/material.dart';
import 'package:qatu_movil/features/mapa/mapa_screen.dart';
import '../../../core/core.dart';
import '../../../models/models.dart';
import '../../../services/Service.dart';
import '../login/login_screen.dart';

class RegisterObservadorScreen extends StatefulWidget {
  const RegisterObservadorScreen({super.key});

  @override
  State<RegisterObservadorScreen> createState() =>
      _RegisterObservadorScreenState();
}

class _RegisterObservadorScreenState extends State<RegisterObservadorScreen> {
  final _formKey = GlobalKey<FormState>();
  final _authService = AuthService();
  bool _loading = false;
  String? _error;

  final _nombreCtrl = TextEditingController();
  final _apellidosCtrl = TextEditingController();
  final _dniCtrl = TextEditingController();
  final _telefonoCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _passCtrl = TextEditingController();
  final _confirmPassCtrl = TextEditingController();

  @override
  void dispose() {
    for (final c in [
      _nombreCtrl,
      _apellidosCtrl,
      _dniCtrl,
      _telefonoCtrl,
      _emailCtrl,
      _passCtrl,
      _confirmPassCtrl,
    ]) {
      c.dispose();
    }
    super.dispose();
  }

  Future<void> _register() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() {
      _loading = true;
      _error = null;
    });

    final resp = await _authService.registerObservador(
      ObservadorRegisterRequest(
        nombre: _nombreCtrl.text.trim(),
        dni: _dniCtrl.text.trim(),
        telefono: _telefonoCtrl.text.trim(),
        email: _emailCtrl.text.trim(),
        password: _passCtrl.text,
        confirmPassword: _confirmPassCtrl.text,
      ),
    );

    if (!mounted) return;
    setState(() => _loading = false);

    if (resp.success) {
      final loginResp = await _authService.login(
        LoginRequest(email: _emailCtrl.text.trim(), password: _passCtrl.text),
      );

      if (!mounted) return;

      if (loginResp.success) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('¡Bienvenido a Qatu!'),
            backgroundColor: Color(0xFF10B981),
          ),
        );
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (_) => MapaScreen(key: UniqueKey())),
          (_) => false,
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Cuenta creada. Inicia sesión')),
        );
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (_) => const LoginScreen()),
          (_) => false,
        );
      }
    } else {
      setState(() => _error = resp.error ?? 'Error al crear la cuenta');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Registro de explorador'),
        backgroundColor: AppColors.secondary,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                'Explora el Mercado San José en tiempo real',
                style: TextStyle(fontSize: 15, color: AppColors.textSecondary),
              ),
              const SizedBox(height: 20),
              _field(_nombreCtrl, 'Nombre', Icons.person_outline),
              _field(_apellidosCtrl, 'Apellidos', Icons.person_outline),
              _field(
                _dniCtrl,
                'DNI',
                Icons.badge_outlined,
                type: TextInputType.number,
                validator: (v) => v?.length != 8 ? 'DNI de 8 dígitos' : null,
              ),
              _field(
                _telefonoCtrl,
                'Teléfono',
                Icons.phone_outlined,
                type: TextInputType.phone,
              ),
              _field(
                _emailCtrl,
                'Correo',
                Icons.email_outlined,
                type: TextInputType.emailAddress,
              ),
              _field(
                _passCtrl,
                'Contraseña',
                Icons.lock_outline,
                obscure: true,
                validator: (v) =>
                    (v?.length ?? 0) < 6 ? 'Mínimo 6 caracteres' : null,
              ),
              _field(
                _confirmPassCtrl,
                'Confirmar contraseña',
                Icons.lock_outline,
                obscure: true,
                validator: (v) =>
                    v != _passCtrl.text ? 'Las contraseñas no coinciden' : null,
              ),
              if (_error != null) ...[
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppColors.error.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    _error!,
                    style: TextStyle(color: AppColors.error),
                  ),
                ),
              ],
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: _loading ? null : _register,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.secondary,
                  foregroundColor: Colors.white,
                  minimumSize: const Size.fromHeight(48),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: _loading
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : const Text(
                        'Explorar el mercado',
                        style: TextStyle(fontSize: 16),
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _field(
    TextEditingController ctrl,
    String label,
    IconData icon, {
    TextInputType type = TextInputType.text,
    bool obscure = false,
    String? Function(String?)? validator,
  }) => Padding(
    padding: const EdgeInsets.only(bottom: 12),
    child: TextFormField(
      controller: ctrl,
      keyboardType: type,
      obscureText: obscure,
      decoration: InputDecoration(labelText: label, prefixIcon: Icon(icon)),
      validator:
          validator ??
          (v) => (v == null || v.isEmpty) ? 'Campo requerido' : null,
    ),
  );
}
