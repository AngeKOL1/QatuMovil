import 'dart:async';
import 'package:flutter/material.dart';
import '../../../core/core.dart';
import '../../../models/models.dart';
import '../../services/Service.dart';
import '../auth/login/login_screen.dart';
import '../mapa/mapa_screen.dart';
import '../sugerencias/sugerencias_screen.dart';
import '../reportes/resportes_screen.dart';
import '../../shared/widgets/logout_dialog.dart';

class VendedorHomeScreen extends StatefulWidget {
  const VendedorHomeScreen({super.key});

  @override
  State<VendedorHomeScreen> createState() => _VendedorHomeScreenState();
}

class _VendedorHomeScreenState extends State<VendedorHomeScreen> {
  final _vendedorService = VendedorService();
  final _ubicacionService = UbicacionService();
  final _authService = AuthService();

  VendedorPerfilDTO? _perfil;
  bool _loading = true;
  bool _toggling = false;
  String? _error;

  StreamSubscription? _gpsSubscription;

  @override
  void initState() {
    super.initState();
    _cargarPerfil();
  }

  @override
  void dispose() {
    _gpsSubscription?.cancel();
    super.dispose();
  }

  Future<void> _cargarPerfil() async {
    setState(() {
      _loading = true;
      _error = null;
    });

    final resp = await _vendedorService.getMiPerfil();

    if (!mounted) return;
    setState(() {
      _loading = false;
      _perfil = resp.data;
      if (!resp.success) _error = resp.error;
    });

    // Si el vendedor ya estaba activo, activar GPS
    if (_perfil != null && _perfil!.visible) {
      _iniciarTracking();
    }
  }

  Future<void> _toggleEstado() async {
    if (_perfil == null || _toggling) return;
    final nuevoEstado = !_perfil!.visible;

    // Si se va a activar, obtener y publicar ubicación PRIMERO
    if (nuevoEstado) {
      final pos = await _ubicacionService.obtenerPosicion();
      if (pos == null) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'Necesitas activar la ubicación para aparecer en el mapa',
            ),
            backgroundColor: Colors.orange,
          ),
        );
        return;
      }

      setState(() => _toggling = true);

      // Publicar ubicación primero
      final ubicResp = await _ubicacionService.publicarUbicacion(
        pos.latitude,
        pos.longitude,
      );

      if (!ubicResp.success) {
        if (!mounted) return;
        setState(() => _toggling = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(ubicResp.error ?? 'Error al publicar ubicación'),
            backgroundColor: AppColors.error,
          ),
        );
        return;
      }

      // Luego cambiar estado a visible
      final estadoResp = await _ubicacionService.cambiarEstado(true);

      if (!mounted) return;
      setState(() => _toggling = false);

      if (estadoResp.success) {
        setState(() {
          _perfil = VendedorPerfilDTO(
            id: _perfil!.id,
            nombre: _perfil!.nombre,
            nombreNegocio: _perfil!.nombreNegocio,
            descripcion: _perfil!.descripcion,
            fotoPerfilUrl: _perfil!.fotoPerfilUrl,
            categoria: _perfil!.categoria,
            movilidad: _perfil!.movilidad,
            horarioInicio: _perfil!.horarioInicio,
            horarioFin: _perfil!.horarioFin,
            visible: true,
            lat: pos.latitude,
            lng: pos.longitude,
          );
        });
        _iniciarTracking();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Ahora eres visible en el mapa'),
            backgroundColor: Color(0xFF10B981),
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(estadoResp.error ?? 'Error al cambiar estado'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    } else {
      // Desactivar — más simple
      setState(() => _toggling = true);
      final resp = await _ubicacionService.cambiarEstado(false);

      if (!mounted) return;
      setState(() => _toggling = false);

      if (resp.success) {
        _detenerTracking();
        setState(() {
          _perfil = VendedorPerfilDTO(
            id: _perfil!.id,
            nombre: _perfil!.nombre,
            nombreNegocio: _perfil!.nombreNegocio,
            descripcion: _perfil!.descripcion,
            fotoPerfilUrl: _perfil!.fotoPerfilUrl,
            categoria: _perfil!.categoria,
            movilidad: _perfil!.movilidad,
            horarioInicio: _perfil!.horarioInicio,
            horarioFin: _perfil!.horarioFin,
            visible: false,
            lat: _perfil!.lat,
            lng: _perfil!.lng,
          );
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Ya no apareces en el mapa'),
            backgroundColor: Color(0xFF6B7280),
          ),
        );
      }
    }
  }

  Future<void> _publicarUbicacionActual() async {
    final pos = await _ubicacionService.obtenerPosicion();
    if (pos != null) {
      await _ubicacionService.publicarUbicacion(pos.latitude, pos.longitude);
    }
  }

  void _iniciarTracking() {
    _gpsSubscription?.cancel();
    _gpsSubscription = _ubicacionService.streamPosicion().listen((pos) {
      _ubicacionService.publicarUbicacion(pos.latitude, pos.longitude);
    });
  }

  void _detenerTracking() {
    _gpsSubscription?.cancel();
    _gpsSubscription = null;
  }

  Future<void> _logout() async {
    final confirmar = await mostrarLogoutDialog(context);
    if (!confirmar) return;

    _detenerTracking();
    await _authService.logout();
    if (!mounted) return;
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => const LoginScreen()),
      (_) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return Scaffold(
        backgroundColor: AppColors.background,
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    if (_error != null) {
      return Scaffold(
        backgroundColor: AppColors.background,
        body: Center(
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
        ),
      );
    }

    final p = _perfil!;
    final color = AppColors.forCategoria(p.categoria);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        title: Row(
          children: [
            const Icon(Icons.storefront_rounded, size: 22),
            const SizedBox(width: 8),
            const Text('Qatu', style: TextStyle(fontWeight: FontWeight.bold)),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout_rounded),
            onPressed: _logout,
            tooltip: 'Cerrar sesión',
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _cargarPerfil,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // Perfil del vendedor
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.divider),
              ),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 32,
                    backgroundColor: color.withOpacity(0.15),
                    backgroundImage: p.fotoPerfilUrl != null
                        ? NetworkImage(p.fotoPerfilUrl!)
                        : null,
                    child: p.fotoPerfilUrl == null
                        ? Icon(Icons.store, color: color, size: 32)
                        : null,
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          p.nombreNegocio,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 18,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            _chip(p.categoria, color),
                            const SizedBox(width: 6),
                            _chip(p.movilidad, AppColors.textSecondary),
                          ],
                        ),
                        const SizedBox(height: 6),
                        Row(
                          children: [
                            Icon(
                              Icons.access_time,
                              size: 14,
                              color: AppColors.textSecondary,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              '${p.horarioInicio} – ${p.horarioFin}',
                              style: TextStyle(
                                color: AppColors.textSecondary,
                                fontSize: 13,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // Estado en el mapa
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.divider),
              ),
              child: Row(
                children: [
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: p.visible
                          ? AppColors.servicios.withOpacity(0.12)
                          : Colors.grey.withOpacity(0.12),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      p.visible
                          ? Icons.visibility_rounded
                          : Icons.visibility_off_rounded,
                      color: p.visible ? AppColors.servicios : Colors.grey,
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Estado en el mapa',
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 15,
                          ),
                        ),
                        Text(
                          p.visible
                              ? 'Visible para los clientes'
                              : 'No apareces en el mapa',
                          style: TextStyle(
                            color: AppColors.textSecondary,
                            fontSize: 13,
                          ),
                        ),
                      ],
                    ),
                  ),
                  _toggling
                      ? const SizedBox(
                          width: 24,
                          height: 24,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : Switch(
                          value: p.visible,
                          onChanged: (_) => _toggleEstado(),
                          activeColor: AppColors.servicios,
                        ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // Botón ver mapa
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                icon: const Icon(Icons.map_rounded),
                label: const Text('Ver mapa'),
                onPressed: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => MapaScreen(key: UniqueKey()),
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  minimumSize: const Size.fromHeight(48),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),

            const SizedBox(height: 24),

            // Sección Mi negocio
            Text(
              'Mi negocio',
              style: TextStyle(
                fontWeight: FontWeight.w600,
                color: AppColors.primary,
                fontSize: 16,
              ),
            ),
            const SizedBox(height: 12),

            Row(
              children: [
                Expanded(
                  child: _menuCard(
                    icon: Icons.inventory_2_rounded,
                    label: 'Catálogo',
                    color: AppColors.electronica,
                    onTap: () {
                      // TODO: Navigator.push → CatalogoScreen
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Catálogo próximamente')),
                      );
                    },
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _menuCard(
                    icon: Icons.lightbulb_rounded,
                    label: 'Sugerencias',
                    color: AppColors.secondary,
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const SugerenciasScreen(),
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: _menuCard(
                    icon: Icons.description_rounded,
                    label: 'Reportes',
                    color: AppColors.comida,
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const ReportesScreen()),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                const Expanded(child: SizedBox()),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _chip(String text, Color color) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
    decoration: BoxDecoration(
      color: color.withOpacity(0.12),
      borderRadius: BorderRadius.circular(12),
    ),
    child: Text(
      text,
      style: TextStyle(color: color, fontWeight: FontWeight.w600, fontSize: 11),
    ),
  );

  Widget _menuCard({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) => GestureDetector(
    onTap: onTap,
    child: Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.divider),
      ),
      child: Column(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: color.withOpacity(0.12),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(icon, color: color, size: 26),
          ),
          const SizedBox(height: 10),
          Text(
            label,
            style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
          ),
        ],
      ),
    ),
  );
}
