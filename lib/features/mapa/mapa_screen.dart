import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import '../../../core/core.dart';
import '../../../models/models.dart';
import '../../services/Service.dart';
import '../auth/login/login_screen.dart';
import '../observador/observador_perfil_screen.dart';
import 'vendedor_perfil_sheet.dart';
import 'widgets/ruta_layer.dart';
import 'widgets/sugerencia_banner.dart';
import '../../shared/widgets/logout_dialog.dart';

const _cajamarcaLat = -7.1617;
const _cajamarcaLng = -78.5127;

class MapaScreen extends StatefulWidget {
  final double? rutaDestinoLat;
  final double? rutaDestinoLng;

  MapaScreen({super.key, this.rutaDestinoLat, this.rutaDestinoLng});

  @override
  State<MapaScreen> createState() => _MapaScreenState();
}

class _MapaScreenState extends State<MapaScreen> {
  final _mapaService = MapaService();
  final _wsService = WebSocketService();
  final _authService = AuthService();
  final _sugerenciaService = SugerenciaService();
  final _ubicacionService = UbicacionService();

  late TextEditingController _searchCtrl;
  late MapController _mapCtrl;
  String _busqueda = '';

  Map<int, VendedorMapaDTO> _vendedores = {};
  List<HeatmapPunto> _heatmapPuntos = [];
  List<ZonaResponse> _zonas = [];

  bool _loadingVendedores = true;
  bool _mostrarHeatmap = false;
  bool _mostrarZonas = false;
  String? _categoriaFiltro;
  String? _userRol;

  // Estado de ruta sugerida
  LatLng? _rutaDestino;
  LatLng? _rutaOrigen;
  bool _mostrarBannerRuta = false;
  bool _respondiendo = false;
  String _mensajeRuta = 'Te sugerimos moverte a una zona menos congestionada';

  Timer? _refreshTimer;

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
    _searchCtrl = TextEditingController();
    _mapCtrl = MapController();
    _cargarRol();
    _cargarVendedores();
    _cargarHeatmap();
    _cargarZonas();
    _conectarWebSocket();
    _configurarFcm();
    _iniciarAutoRefresh();

    if (widget.rutaDestinoLat != null && widget.rutaDestinoLng != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _mostrarRutaSugerida(widget.rutaDestinoLat!, widget.rutaDestinoLng!);
      });
    }
  }

  void _iniciarAutoRefresh() {
    _refreshTimer = Timer.periodic(
      const Duration(seconds: 30),
      (_) => _cargarVendedores(),
    );
  }

  @override
  void dispose() {
    _refreshTimer?.cancel(); // ← agregar
    _wsService.onUbicacionActualizada = null;
    _wsService.onCongestionDetectada = null;
    _wsService.disconnect();
    FcmHandler.instance.onRutaSugerida = null;
    FcmHandler.instance.onSugerenciaReasignacion = null;
    _searchCtrl.dispose();
    _mapCtrl.dispose();
    super.dispose();
  }

  void _configurarFcm() {
    FcmHandler.instance.onRutaSugerida = (lat, lng) {
      if (!mounted) return;
      _mostrarRutaSugerida(lat, lng);
    };

    FcmHandler.instance.onSugerenciaReasignacion = () {
      if (!mounted) return;
      setState(() {
        _mostrarBannerRuta = true;
        _rutaDestino = null;
        _rutaOrigen = null;
        _mensajeRuta = 'Hay una zona disponible cerca. Revisa tus sugerencias.';
      });
    };
  }

  Future<void> _mostrarRutaSugerida(double lat, double lng) async {
    // Obtener ubicación actual del vendedor
    final pos = await _ubicacionService.obtenerPosicion();

    if (!mounted) return;
    setState(() {
      _rutaDestino = LatLng(lat, lng);
      _rutaOrigen = pos != null
          ? LatLng(pos.latitude, pos.longitude)
          : const LatLng(_cajamarcaLat, _cajamarcaLng);
      _mostrarBannerRuta = true;
      _mensajeRuta = 'Te sugerimos moverte a una zona menos congestionada';
    });

    // Centrar el mapa para mostrar la ruta
    if (_rutaOrigen != null && _rutaDestino != null) {
      final midLat = (_rutaOrigen!.latitude + _rutaDestino!.latitude) / 2;
      final midLng = (_rutaOrigen!.longitude + _rutaDestino!.longitude) / 2;
      _mapCtrl.move(LatLng(midLat, midLng), 15.0);
    }
  }

  Future<void> _aceptarRuta() async {
    setState(() => _respondiendo = true);

    // Buscar la sugerencia pendiente más reciente
    final resp = await _sugerenciaService.getMisSugerencias(
      pagina: 0,
      tamanio: 1,
    );

    if (!mounted) return;

    if (resp.success && resp.data != null && resp.data!.contenido.isNotEmpty) {
      final sugerencia = resp.data!.contenido.first;
      if (sugerencia.estado == 'ENVIADA') {
        await _sugerenciaService.responderSugerencia(sugerencia.id, 'ACEPTADA');
      }
    }

    if (!mounted) return;
    setState(() {
      _respondiendo = false;
      // Mantener la ruta como guía
      _mostrarBannerRuta = false;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Ruta aceptada — sigue la línea azul'),
        backgroundColor: Color(0xFF10B981),
      ),
    );
  }

  Future<void> _ignorarRuta() async {
    setState(() => _respondiendo = true);

    final resp = await _sugerenciaService.getMisSugerencias(
      pagina: 0,
      tamanio: 1,
    );

    if (!mounted) return;

    if (resp.success && resp.data != null && resp.data!.contenido.isNotEmpty) {
      final sugerencia = resp.data!.contenido.first;
      if (sugerencia.estado == 'ENVIADA') {
        await _sugerenciaService.responderSugerencia(sugerencia.id, 'IGNORADA');
      }
    }

    if (!mounted) return;
    setState(() {
      _respondiendo = false;
      _mostrarBannerRuta = false;
      _rutaDestino = null;
      _rutaOrigen = null;
    });
  }

  Future<void> _cargarRol() async {
    final storage = SecureStorageService();
    final rol = await storage.getRol();
    if (mounted) setState(() => _userRol = rol);
  }

  Future<void> _cargarVendedores() async {
    if (!mounted) return;
    setState(() => _loadingVendedores = true);

    final resp = await _mapaService.getVendedores(categoria: _categoriaFiltro);

    if (!mounted) return;
    if (resp.success && resp.data != null) {
      setState(() {
        _vendedores = {for (var v in resp.data!.contenido) v.id: v};
        _loadingVendedores = false;
      });
    } else {
      setState(() => _loadingVendedores = false);
    }
  }

  Future<void> _cargarHeatmap() async {
    final resp = await _mapaService.getHeatmap();
    if (!mounted) return;
    if (resp.success && resp.data != null) {
      setState(() => _heatmapPuntos = resp.data!.puntos);
    }
  }

  Future<void> _cargarZonas() async {
    final resp = await _mapaService.getZonas();
    if (!mounted) return;
    if (resp.success && resp.data != null) {
      setState(() => _zonas = resp.data!);
    }
  }

  void _conectarWebSocket() {
    _wsService.onUbicacionActualizada = (evento) {
      if (!mounted) return;
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
    final confirmar = await mostrarLogoutDialog(context);
    if (!confirmar) return;

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
    final vendedoresVisible = _vendedores.values.where((v) {
      if (!v.visible) return false;
      if (v.lat == null || v.lng == null) return false; // ← agregar
      if (_busqueda.isEmpty) return true;
      return v.nombreNegocio.toLowerCase().contains(_busqueda.toLowerCase());
    }).toList();

    return Scaffold(
      body: Stack(
        children: [
          // Mapa principal
          FlutterMap(
            mapController: _mapCtrl,
            options: const MapOptions(
              initialCenter: LatLng(_cajamarcaLat, _cajamarcaLng),
              initialZoom: 15.0,
              minZoom: 11,
              maxZoom: 19,
            ),
            children: [
              TileLayer(
                urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                userAgentPackageName: 'com.qatu.app',
              ),

              // Capa de zonas
              if (_mostrarZonas && _zonas.isNotEmpty)
                PolygonLayer(
                  polygons: _zonas
                      .where((z) => z.activa)
                      .map((z) => _buildZonaPolygon(z))
                      .toList(),
                ),

              // Capa de heatmap
              if (_mostrarHeatmap && _heatmapPuntos.isNotEmpty)
                CircleLayer(
                  circles: _heatmapPuntos
                      .map((p) => _buildHeatmapCircle(p))
                      .toList(),
                ),

              // Capa de ruta sugerida
              if (_rutaOrigen != null && _rutaDestino != null)
                RutaLayer(origen: _rutaOrigen!, destino: _rutaDestino!),

              // Marcadores de vendedores
              MarkerLayer(
                markers: [
                  ...vendedoresVisible.map((v) => _buildMarker(v)),
                  // Marcador de destino de ruta
                  if (_rutaDestino != null) DestinoMarker.build(_rutaDestino!),
                ],
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
                      child: _userRol == 'USUARIO_OBSERVADOR'
                          ? IconButton(
                              icon: const Icon(Icons.person_rounded),
                              color: AppColors.secondary,
                              onPressed: () => Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) =>
                                      const ObservadorPerfilScreen(),
                                ),
                              ),
                              tooltip: 'Mi perfil',
                            )
                          : IconButton(
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

          // Barra de búsqueda
          Positioned(
            top: 0,
            left: 12,
            right: 12,
            child: SafeArea(
              child: Padding(
                padding: const EdgeInsets.only(top: 56),
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: const [
                      BoxShadow(color: Colors.black12, blurRadius: 8),
                    ],
                  ),
                  child: TextField(
                    controller: _searchCtrl,
                    onChanged: (value) => setState(() => _busqueda = value),
                    decoration: InputDecoration(
                      hintText: '"Jugos", "Frutas", "Ropa"...',
                      hintStyle: TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 14,
                      ),
                      prefixIcon: Icon(
                        Icons.search_rounded,
                        color: AppColors.textSecondary,
                      ),
                      suffixIcon: _busqueda.isNotEmpty
                          ? IconButton(
                              icon: Icon(
                                Icons.close_rounded,
                                color: AppColors.textSecondary,
                              ),
                              onPressed: () {
                                _searchCtrl.clear();
                                setState(() => _busqueda = '');
                              },
                            )
                          : null,
                      border: InputBorder.none,
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 14,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),

          // Botones de capas
          Positioned(
            top: 0,
            right: 12,
            child: SafeArea(
              child: Padding(
                padding: const EdgeInsets.only(top: 112),
                child: Column(
                  children: [
                    _layerButton(
                      icon: Icons.thermostat_rounded,
                      label: 'Calor',
                      activo: _mostrarHeatmap,
                      color: AppColors.heatRojo,
                      onTap: () {
                        setState(() => _mostrarHeatmap = !_mostrarHeatmap);
                        if (_mostrarHeatmap) _cargarHeatmap();
                      },
                    ),
                    const SizedBox(height: 8),
                    _layerButton(
                      icon: Icons.layers_rounded,
                      label: 'Zonas',
                      activo: _mostrarZonas,
                      color: AppColors.zonaReasignacion,
                      onTap: () {
                        setState(() => _mostrarZonas = !_mostrarZonas);
                        if (_mostrarZonas) _cargarZonas();
                      },
                    ),
                  ],
                ),
              ),
            ),
          ),

          // Leyenda del heatmap
          if (_mostrarHeatmap)
            Positioned(
              top: 0,
              left: 12,
              child: SafeArea(
                child: Padding(
                  padding: const EdgeInsets.only(top: 112),
                  child: Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(10),
                      boxShadow: const [
                        BoxShadow(color: Colors.black12, blurRadius: 6),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Congestión',
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 12,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        const SizedBox(height: 6),
                        _legendItem(AppColors.heatRojo, 'Alta'),
                        _legendItem(AppColors.heatAmarillo, 'Media'),
                        _legendItem(AppColors.heatVerde, 'Baja'),
                      ],
                    ),
                  ),
                ),
              ),
            ),

          // Leyenda de zonas
          if (_mostrarZonas && !_mostrarHeatmap)
            Positioned(
              top: 0,
              left: 12,
              child: SafeArea(
                child: Padding(
                  padding: const EdgeInsets.only(top: 112),
                  child: Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(10),
                      boxShadow: const [
                        BoxShadow(color: Colors.black12, blurRadius: 6),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Zonas',
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 12,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        const SizedBox(height: 6),
                        _legendItem(AppColors.zonaRestringida, 'Restringida'),
                        _legendItem(AppColors.zonaReasignacion, 'Reasignación'),
                      ],
                    ),
                  ),
                ),
              ),
            ),

          // Filtros de categoría
          Positioned(
            bottom: _mostrarBannerRuta ? 200 : 24,
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

          // Banner de sugerencia de ruta
          if (_mostrarBannerRuta)
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: SugerenciaBanner(
                mensaje: _mensajeRuta,
                cargando: _respondiendo,
                onAceptar: _aceptarRuta,
                onIgnorar: _ignorarRuta,
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
            _mapCtrl.move(const LatLng(_cajamarcaLat, _cajamarcaLng), 15.0),
        child: const Icon(Icons.my_location_rounded),
      ),
    );
  }

  // ── Builders ──────────────────────────────────────────────

  CircleMarker _buildHeatmapCircle(HeatmapPunto p) {
    Color color;
    double radius;

    switch (p.nivel) {
      case 'ROJO':
        color = AppColors.heatRojo.withOpacity(0.35);
        radius = 60;
        break;
      case 'AMARILLO':
        color = AppColors.heatAmarillo.withOpacity(0.3);
        radius = 45;
        break;
      default:
        color = AppColors.heatVerde.withOpacity(0.25);
        radius = 30;
    }

    return CircleMarker(
      point: LatLng(p.lat, p.lng),
      radius: radius,
      color: color,
      borderColor: color.withOpacity(0.6),
      borderStrokeWidth: 1,
      useRadiusInMeter: true,
    );
  }

  Polygon _buildZonaPolygon(ZonaResponse z) {
    final esRestringida = z.tipoZona == 'RESTRINGIDA';
    final color = esRestringida
        ? AppColors.zonaRestringida
        : AppColors.zonaReasignacion;

    final puntos = z.coordenadas.map((c) => LatLng(c[1], c[0])).toList();

    return Polygon(
      points: puntos,
      color: color.withOpacity(0.15),
      borderColor: color.withOpacity(0.7),
      borderStrokeWidth: 2,
      isFilled: true,
      label: z.nombre,
      labelStyle: TextStyle(
        color: color,
        fontWeight: FontWeight.w600,
        fontSize: 12,
      ),
    );
  }

  Marker _buildMarker(VendedorMapaDTO v) {
    final color = AppColors.forCategoria(v.categoria);
    return Marker(
      point: LatLng(v.lat!, v.lng!),
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

  // ── Widgets auxiliares ─────────────────────────────────────

  Widget _layerButton({
    required IconData icon,
    required String label,
    required bool activo,
    required Color color,
    required VoidCallback onTap,
  }) => GestureDetector(
    onTap: onTap,
    child: Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: activo ? color : Colors.white,
        borderRadius: BorderRadius.circular(10),
        boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 6)],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: 16,
            color: activo ? Colors.white : AppColors.textSecondary,
          ),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: activo ? Colors.white : AppColors.textSecondary,
            ),
          ),
        ],
      ),
    ),
  );

  Widget _legendItem(Color color, String label) => Padding(
    padding: const EdgeInsets.only(bottom: 3),
    child: Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 10,
          height: 10,
          decoration: BoxDecoration(
            color: color.withOpacity(0.5),
            shape: BoxShape.circle,
            border: Border.all(color: color, width: 1),
          ),
        ),
        const SizedBox(width: 6),
        Text(
          label,
          style: TextStyle(fontSize: 11, color: AppColors.textSecondary),
        ),
      ],
    ),
  );

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
