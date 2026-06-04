import 'package:flutter/material.dart';
import '../../../core/core.dart';
import '../../../models/models.dart';
import '../../../services/Service.dart';
import '../login/login_screen.dart';

class RegisterVendedorScreen extends StatefulWidget {
  const RegisterVendedorScreen({super.key});

  @override
  State<RegisterVendedorScreen> createState() => _RegisterVendedorScreenState();
}

class _RegisterVendedorScreenState extends State<RegisterVendedorScreen> {
  final _formKey = GlobalKey<FormState>();
  final _authService = AuthService();
  bool _loading = false;
  String? _error;

  final _nombreCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _passCtrl = TextEditingController();
  final _dniCtrl = TextEditingController();
  final _telefonoCtrl = TextEditingController();
  final _descCtrl = TextEditingController();

  String _movilidad = 'FIJO';
  String _categoria = 'COMIDA';
  TimeOfDay _horarioInicio = const TimeOfDay(hour: 7, minute: 0);
  TimeOfDay _horarioFin = const TimeOfDay(hour: 18, minute: 0);

  static const _movilidades = ['FIJO', 'CARRITO', 'CAMIONETA'];
  static const _categorias = [
    'COMIDA',
    'ROPA',
    'ELECTRONICA',
    'SERVICIOS',
    'OTROS',
  ];

  String _formatTime(TimeOfDay t) =>
      '${t.hour.toString().padLeft(2, '0')}:${t.minute.toString().padLeft(2, '0')}';

  Future<void> _selectTime(bool isInicio) async {
    final picked = await showTimePicker(
      context: context,
      initialTime: isInicio ? _horarioInicio : _horarioFin,
    );
    if (picked != null) {
      setState(() {
        if (isInicio) {
          _horarioInicio = picked;
        } else {
          _horarioFin = picked;
        }
      });
    }
  }

  @override
  void dispose() {
    for (final c in [
      _nombreCtrl,
      _emailCtrl,
      _passCtrl,
      _dniCtrl,
      _telefonoCtrl,
      _descCtrl,
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

    final resp = await _authService.registerVendedor(
      VendedorRegisterRequest(
        nombre: _nombreCtrl.text.trim(),
        email: _emailCtrl.text.trim(),
        password: _passCtrl.text,
        dni: _dniCtrl.text.trim(),
        telefono: _telefonoCtrl.text.trim(),
        descripcion: _descCtrl.text.trim(),
        tipoMovilidad: _movilidad,
        horarioInicio: _formatTime(_horarioInicio),
        horarioFin: _formatTime(_horarioFin),
        nombreCategoria: _categoria,
      ),
    );

    if (!mounted) return;
    setState(() => _loading = false);

    if (resp.success) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('¡Cuenta creada! Inicia sesión')),
      );
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (_) => const LoginScreen()),
        (_) => false,
      );
    } else {
      setState(() => _error = resp.error);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Registro de vendedor'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _sectionTitle('Datos personales'),
              _field(_nombreCtrl, 'Nombre del negocio', Icons.store_outlined),
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
                _dniCtrl,
                'DNI (8 dígitos)',
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
              const SizedBox(height: 16),
              _sectionTitle('Información del negocio'),
              _field(
                _descCtrl,
                'Descripción breve',
                Icons.description_outlined,
                maxLines: 2,
                required: false,
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: _dropdown(
                      'Movilidad',
                      _movilidades,
                      _movilidad,
                      (v) => setState(() => _movilidad = v!),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _dropdown(
                      'Categoría',
                      _categorias,
                      _categoria,
                      (v) => setState(() => _categoria = v!),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              _sectionTitle('Horario de atención'),
              Row(
                children: [
                  Expanded(
                    child: _timeButton(
                      'Inicio',
                      _horarioInicio,
                      () => _selectTime(true),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _timeButton(
                      'Fin',
                      _horarioFin,
                      () => _selectTime(false),
                    ),
                  ),
                ],
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
                  backgroundColor: AppColors.primary,
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
                        'Crear cuenta de vendedor',
                        style: TextStyle(fontSize: 16),
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _sectionTitle(String title) => Padding(
    padding: const EdgeInsets.only(bottom: 12),
    child: Text(
      title,
      style: TextStyle(
        fontWeight: FontWeight.w600,
        color: AppColors.primary,
        fontSize: 14,
      ),
    ),
  );

  Widget _field(
    TextEditingController ctrl,
    String label,
    IconData icon, {
    TextInputType type = TextInputType.text,
    bool obscure = false,
    int maxLines = 1,
    bool required = true,
    String? Function(String?)? validator,
  }) => Padding(
    padding: const EdgeInsets.only(bottom: 12),
    child: TextFormField(
      controller: ctrl,
      keyboardType: type,
      obscureText: obscure,
      maxLines: maxLines,
      decoration: InputDecoration(labelText: label, prefixIcon: Icon(icon)),
      validator:
          validator ??
          (required
              ? (v) => (v == null || v.isEmpty) ? 'Campo requerido' : null
              : null),
    ),
  );

  Widget _dropdown(
    String label,
    List<String> items,
    String value,
    ValueChanged<String?> onChanged,
  ) => DropdownButtonFormField<String>(
    value: value,
    decoration: InputDecoration(labelText: label),
    items: items
        .map((i) => DropdownMenuItem(value: i, child: Text(i)))
        .toList(),
    onChanged: onChanged,
  );

  Widget _timeButton(String label, TimeOfDay time, VoidCallback onTap) =>
      InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
          decoration: BoxDecoration(
            border: Border.all(color: AppColors.divider),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            children: [
              Icon(Icons.access_time, size: 18, color: AppColors.primary),
              const SizedBox(width: 8),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: TextStyle(
                      fontSize: 11,
                      color: AppColors.textSecondary,
                    ),
                  ),
                  Text(
                    _formatTime(time),
                    style: const TextStyle(fontWeight: FontWeight.w600),
                  ),
                ],
              ),
            ],
          ),
        ),
      );
}
