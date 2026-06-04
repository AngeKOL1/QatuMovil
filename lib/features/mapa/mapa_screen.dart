import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import '../../../core/core.dart';
import '../../../models/models.dart';
import '../../../services/Service.dart';
import '../auth/login/login_screen.dart';
import 'vendedor_perfil_sheet.dart';

const _mercadoLat = -7.1638;
const _mercadoLng = -78.5001;

class MapaScreen extends StatefulWidget {
  const MapaScreen({super.key});

  @override
  State<MapaScreen> createState() => _MapaScreenState();
}

class _MapaScreenState extends State<MapaScreen> {
  final _mapaService = MapaService();
  final _wsService = WebSocketService();
  final _authService = AuthService();
  final _mapCtrl = MapController();

  Map<int, VendedorMapaDTO> _vendedores = {};
  bool _loadingVendedores = true;
  String? _categoriaFiltro;

  static const _categorias = [
    'COMIDA',
    'ROPA',
    'ELECTRONICA',
    'SERVICIOS',
    'OTROS',
  ];

  @override
  void initState() {
    super.initState();
    _cargarVendedores();
    _conectarWebSocket();
  }

  @override
  void dispose() {
    _wsService.disconnect();
    super.dispose();
  }

  Future<void> _cargarVendedores() async {
    setState(() => _loadingVendedores = true);
    final resp = await _mapaService.getVendedores(categoria: _categoriaFiltro);
    if (resp.success && resp.data != null) {
      setState(() {
        _vendedores = {for (var v in resp.data!) v.id: v};
        _loadingVendedores = false;
      });
    } else {
      setState(() => _loadingVendedores = false);
    }
  }

  void _conectarWebSocket() {
    _wsService.onUbicacionActualizada = (evento) {
      setState(() {
        if (!evento.visible) {
          _vendedores.remove(evento.vendedorId);
        } else {
          final existing = _vendedores[evento.vendedorId];
          if (existing != null) {
            _vendedores[evento.vendedorId] = existing.copyWith(
              lat: evento.lat,
              lng: evento.lng,
              visible: evento.visible,
            );
          } else {
            _vendedores[evento.vendedorId] = VendedorMapaDTO(
              id: evento.vendedorId,
              nombreNegocio: evento.nombreNegocio,
              categoria: evento.categoria,
              movilidad: 'CARRITO',
              lat: evento.lat,
              lng: evento.lng,
              visible: evento.visible,
            );
          }
        }
      });
    };
    _wsService.connect();
  }

  void _abrirPerfil(int vendedorId) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => VendedorPerfilSheet(vendedorId: vendedorId),
    );
  }

  Future<void> _logout() async {
    await _authService.logout();
    if (mounted) {
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (_) => const LoginScreen()),
        (_) => false,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final vendedoresVisible = _vendedores.values
        .where((v) => v.visible)
        .toList();

    return Scaffold(
      body: Stack(
        children: [
          // Mapa principal
          FlutterMap(
            mapController: _mapCtrl,
            options: const MapOptions(
              initialCenter: LatLng(_mercadoLat, _mercadoLng),
              initialZoom: 16.5,
              minZoom: 13,
              maxZoom: 19,
            ),
            children: [
              TileLayer(
                urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                userAgentPackageName: 'com.qatu.app',
              ),
              MarkerLayer(
                markers: vendedoresVisible.map((v) => _buildMarker(v)).toList(),
              ),
            ],
          ),

          // Barra superior
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: SafeArea(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(12, 8, 12, 0),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 10,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: const [
                          BoxShadow(color: Colors.black12, blurRadius: 8),
                        ],
                      ),
                      child: Row(
                        children: [
                          Icon(
                            Icons.storefront_rounded,
                            color: AppColors.primary,
                            size: 20,
                          ),
                          const SizedBox(width: 6),
                          Text(
                            'Qatu',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: AppColors.primary,
                              fontSize: 16,
                            ),
                          ),
                          if (_wsService.isConnected)
                            Container(
                              margin: const EdgeInsets.only(left: 8),
                              width: 8,
                              height: 8,
                              decoration: const BoxDecoration(
                                color: Color(0xFF16A34A),
                                shape: BoxShape.circle,
                              ),
                            ),
                        ],
                      ),
                    ),
                    const Spacer(),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 10,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: const [
                          BoxShadow(color: Colors.black12, blurRadius: 8),
                        ],
                      ),
                      child: Text(
                        '${vendedoresVisible.length} activos',
                        style: TextStyle(
                          color: AppColors.primary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: const [
                          BoxShadow(color: Colors.black12, blurRadius: 8),
                        ],
                      ),
                      child: IconButton(
                        icon: const Icon(Icons.logout_rounded),
                        color: AppColors.textSecondary,
                        onPressed: _logout,
                        tooltip: 'Cerrar sesión',
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          // Filtros de categoría
          Positioned(
            bottom: 24,
            left: 0,
            right: 0,
            child: SizedBox(
              height: 44,
              child: ListView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 12),
                children: [
                  _filterChip('Todos', null),
                  ..._categorias.map((c) => _filterChip(c, c)),
                ],
              ),
            ),
          ),

          if (_loadingVendedores)
            const Center(child: CircularProgressIndicator()),
        ],
      ),
      floatingActionButton: FloatingActionButton.small(
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        onPressed: () =>
            _mapCtrl.move(const LatLng(_mercadoLat, _mercadoLng), 16.5),
        child: const Icon(Icons.my_location_rounded),
      ),
    );
  }

  Marker _buildMarker(VendedorMapaDTO v) {
    final color = AppColors.forCategoria(v.categoria);
    return Marker(
      point: LatLng(v.lat, v.lng),
      width: 44,
      height: 54,
      child: GestureDetector(
        onTap: () => _abrirPerfil(v.id),
        child: Column(
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: color,
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white, width: 2),
                boxShadow: [
                  BoxShadow(
                    color: color.withOpacity(0.4),
                    blurRadius: 6,
                    spreadRadius: 1,
                  ),
                ],
              ),
              child: Icon(
                _iconForCategoria(v.categoria),
                color: Colors.white,
                size: 18,
              ),
            ),
            Container(width: 2, height: 10, color: color.withOpacity(0.8)),
          ],
        ),
      ),
    );
  }

  Widget _filterChip(String label, String? value) {
    final selected = _categoriaFiltro == value;
    return GestureDetector(
      onTap: () {
        setState(() => _categoriaFiltro = value);
        _cargarVendedores();
      },
      child: Container(
        margin: const EdgeInsets.only(right: 8),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: selected ? AppColors.primary : Colors.white,
          borderRadius: BorderRadius.circular(22),
          boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 6)],
        ),
        child: Text(
          label,
          style: TextStyle(
            color: selected ? Colors.white : AppColors.textPrimary,
            fontWeight: selected ? FontWeight.w600 : FontWeight.normal,
            fontSize: 13,
          ),
        ),
      ),
    );
  }

  IconData _iconForCategoria(String cat) {
    switch (cat) {
      case 'COMIDA':
        return Icons.restaurant_rounded;
      case 'ROPA':
        return Icons.checkroom_rounded;
      case 'ELECTRONICA':
        return Icons.devices_rounded;
      case 'SERVICIOS':
        return Icons.build_rounded;
      default:
        return Icons.sell_rounded;
    }
  }
}
