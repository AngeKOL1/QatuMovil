import 'package:flutter/material.dart';
import 'package:qatu_movil/models/usuarioObservador.dart';
import '../../../core/core.dart';
import '../../services/Service.dart';
import '../../shared/widgets/logout_dialog.dart';
import '../auth/login/login_screen.dart';

class ObservadorPerfilScreen extends StatefulWidget {
  const ObservadorPerfilScreen({super.key});

  @override
  State<ObservadorPerfilScreen> createState() => _ObservadorPerfilScreenState();
}

class _ObservadorPerfilScreenState extends State<ObservadorPerfilScreen> {
  final _observadorService = ObservadorService();
  final _authService = AuthService();

  ObservadorPerfilDTO? _perfil;
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _cargarPerfil();
  }

  Future<void> _cargarPerfil() async {
    setState(() {
      _loading = true;
      _error = null;
    });

    final resp = await _observadorService.getMiPerfil();

    if (!mounted) return;
    setState(() {
      _loading = false;
      _perfil = resp.data;
      if (!resp.success) _error = resp.error;
    });
  }

  Future<void> _logout() async {
    final confirmar = await mostrarLogoutDialog(context);
    if (!confirmar) return;

    await _authService.logout();
    if (!mounted) return;
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => const LoginScreen()),
      (_) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Mi perfil'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(_error!, style: TextStyle(color: AppColors.error)),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: _cargarPerfil,
                    child: const Text('Reintentar'),
                  ),
                ],
              ),
            )
          : RefreshIndicator(
              onRefresh: _cargarPerfil,
              child: ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  // Avatar y nombre
                  Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: AppColors.divider),
                    ),
                    child: Column(
                      children: [
                        CircleAvatar(
                          radius: 40,
                          backgroundColor: AppColors.secondary.withOpacity(
                            0.15,
                          ),
                          child: Icon(
                            Icons.person_rounded,
                            color: AppColors.secondary,
                            size: 44,
                          ),
                        ),
                        const SizedBox(height: 14),
                        Text(
                          _perfil!.nombre,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 20,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.secondary.withOpacity(0.12),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            'Explorador',
                            style: TextStyle(
                              color: AppColors.secondary,
                              fontWeight: FontWeight.w600,
                              fontSize: 12,
                            ),
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          'Miembro desde ${_formatFecha(_perfil!.fechaRegistro)}',
                          style: TextStyle(
                            color: AppColors.textSecondary,
                            fontSize: 13,
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 16),

                  // Datos personales
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: AppColors.divider),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Datos personales',
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                            color: AppColors.primary,
                            fontSize: 15,
                          ),
                        ),
                        const SizedBox(height: 14),
                        _infoRow(
                          Icons.email_outlined,
                          'Correo',
                          _perfil!.email,
                        ),
                        _divider(),
                        _infoRow(Icons.badge_outlined, 'DNI', _perfil!.dni),
                        _divider(),
                        _infoRow(
                          Icons.phone_outlined,
                          'Teléfono',
                          _perfil!.telefono,
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 24),

                  // Botón cerrar sesión
                  OutlinedButton.icon(
                    icon: const Icon(Icons.logout_rounded),
                    label: const Text('Cerrar sesión'),
                    onPressed: _logout,
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.error,
                      side: BorderSide(color: AppColors.error),
                      minimumSize: const Size.fromHeight(48),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ],
              ),
            ),
    );
  }

  Widget _infoRow(IconData icon, String label, String value) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 10),
    child: Row(
      children: [
        Icon(icon, size: 20, color: AppColors.textSecondary),
        const SizedBox(width: 12),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: TextStyle(color: AppColors.textSecondary, fontSize: 12),
            ),
            const SizedBox(height: 2),
            Text(
              value,
              style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w500),
            ),
          ],
        ),
      ],
    ),
  );

  Widget _divider() => Divider(color: AppColors.divider, height: 1);

  String _formatFecha(String fecha) {
    try {
      final dt = DateTime.parse(fecha);
      final meses = [
        'enero',
        'febrero',
        'marzo',
        'abril',
        'mayo',
        'junio',
        'julio',
        'agosto',
        'septiembre',
        'octubre',
        'noviembre',
        'diciembre',
      ];
      return '${meses[dt.month - 1]} ${dt.year}';
    } catch (_) {
      return fecha;
    }
  }
}
