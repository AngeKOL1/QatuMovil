import 'package:flutter/material.dart';
import '../../../core/core.dart';
import '../../../models/models.dart';
import '../../services/Service.dart';

class VendedorPerfilSheet extends StatefulWidget {
  final int vendedorId;
  const VendedorPerfilSheet({super.key, required this.vendedorId});

  @override
  State<VendedorPerfilSheet> createState() => _VendedorPerfilSheetState();
}

class _VendedorPerfilSheetState extends State<VendedorPerfilSheet> {
  final _mapaService = MapaService();
  final _productoService = ProductoService();

  VendedorPerfilDTO? _perfil;
  final List<ProductoDTO> _productos = [];
  bool _loadingPerfil = true;
  bool _loadingProductos = true;
  bool _cargandoMas = false;
  bool _esUltima = false;
  int _paginaActual = 0;
  String? _error;

  @override
  void initState() {
    super.initState();
    _cargarPerfil();
    _cargarProductos();
  }

  Future<void> _cargarPerfil() async {
    final resp = await _mapaService.getVendedorPerfil(widget.vendedorId);
    setState(() {
      _loadingPerfil = false;
      _perfil = resp.data;
      if (!resp.success) _error = resp.error;
    });
  }

  Future<void> _cargarProductos() async {
    final resp = await _productoService.getProductosVendedor(
      widget.vendedorId,
      pagina: 0,
    );
    setState(() {
      _loadingProductos = false;
      if (resp.success && resp.data != null) {
        _productos.addAll(resp.data!.contenido);
        _esUltima = resp.data!.esUltima;
      }
    });
  }

  Future<void> _cargarMasProductos() async {
    if (_cargandoMas || _esUltima) return;
    setState(() => _cargandoMas = true);
    _paginaActual++;

    final resp = await _productoService.getProductosVendedor(
      widget.vendedorId,
      pagina: _paginaActual,
    );

    setState(() {
      _cargandoMas = false;
      if (resp.success && resp.data != null) {
        _productos.addAll(resp.data!.contenido);
        _esUltima = resp.data!.esUltima;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.5,
      minChildSize: 0.3,
      maxChildSize: 0.9,
      builder: (_, scrollCtrl) => Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: _loadingPerfil
            ? const Center(child: CircularProgressIndicator())
            : _error != null
            ? Center(
                child: Text(_error!, style: TextStyle(color: AppColors.error)),
              )
            : _buildContent(scrollCtrl),
      ),
    );
  }

  Widget _buildContent(ScrollController ctrl) {
    final p = _perfil!;
    final color = AppColors.forCategoria(p.categoria);
    final productosActivos = _productos.where((pr) => pr.activo).toList();

    return NotificationListener<ScrollNotification>(
      onNotification: (notification) {
        if (notification is ScrollEndNotification &&
            ctrl.position.pixels >= ctrl.position.maxScrollExtent * 0.9) {
          _cargarMasProductos();
        }
        return false;
      },
      child: ListView(
        controller: ctrl,
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 32),
        children: [
          // Handle
          Center(
            child: Container(
              width: 40,
              height: 4,
              margin: const EdgeInsets.only(bottom: 16),
              decoration: BoxDecoration(
                color: AppColors.divider,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),

          // Header
          Row(
            children: [
              CircleAvatar(
                radius: 28,
                backgroundColor: color.withOpacity(0.15),
                backgroundImage: p.fotoPerfilUrl != null
                    ? NetworkImage(p.fotoPerfilUrl!)
                    : null,
                child: p.fotoPerfilUrl == null
                    ? Icon(Icons.store, color: color, size: 28)
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
                        fontSize: 17,
                      ),
                    ),
                    Text(
                      p.nombre,
                      style: TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 13,
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
                  ],
                ),
              ),
              Column(
                children: [
                  Container(
                    width: 12,
                    height: 12,
                    decoration: BoxDecoration(
                      color: p.visible ? AppColors.servicios : Colors.grey,
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    p.visible ? 'Activo' : 'Inactivo',
                    style: TextStyle(
                      fontSize: 11,
                      color: p.visible ? AppColors.servicios : Colors.grey,
                    ),
                  ),
                ],
              ),
            ],
          ),

          if (p.descripcion != null) ...[
            const SizedBox(height: 12),
            Text(
              p.descripcion!,
              style: TextStyle(color: AppColors.textSecondary, height: 1.5),
            ),
          ],

          const SizedBox(height: 12),
          Row(
            children: [
              Icon(Icons.access_time, size: 14, color: AppColors.textSecondary),
              const SizedBox(width: 4),
              Text(
                '${p.horarioInicio} – ${p.horarioFin}',
                style: TextStyle(color: AppColors.textSecondary, fontSize: 13),
              ),
            ],
          ),

          // Productos
          const SizedBox(height: 20),
          if (_loadingProductos)
            const Center(child: CircularProgressIndicator(strokeWidth: 2))
          else if (productosActivos.isNotEmpty) ...[
            const Text(
              'Catálogo',
              style: TextStyle(fontWeight: FontWeight.w600, fontSize: 15),
            ),
            const SizedBox(height: 10),
            ...productosActivos.map((pr) => _productoTile(pr)),
            if (_cargandoMas)
              const Padding(
                padding: EdgeInsets.all(16),
                child: Center(child: CircularProgressIndicator(strokeWidth: 2)),
              ),
            if (!_esUltima && !_cargandoMas)
              TextButton(
                onPressed: _cargarMasProductos,
                child: Text(
                  'Cargar más productos',
                  style: TextStyle(color: AppColors.primary),
                ),
              ),
          ] else
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.background,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.inventory_2_outlined,
                    color: AppColors.textSecondary,
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      'Este vendedor no tiene productos publicados',
                      style: TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 13,
                      ),
                    ),
                  ),
                ],
              ),
            ),
        ],
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

  Widget _productoTile(ProductoDTO pr) => Container(
    margin: const EdgeInsets.only(bottom: 8),
    padding: const EdgeInsets.all(12),
    decoration: BoxDecoration(
      color: AppColors.background,
      borderRadius: BorderRadius.circular(10),
      border: Border.all(color: AppColors.divider),
    ),
    child: Row(
      children: [
        if (pr.fotoUrl != null)
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: Image.network(
              pr.fotoUrl!,
              width: 52,
              height: 52,
              fit: BoxFit.cover,
            ),
          )
        else
          Container(
            width: 52,
            height: 52,
            decoration: BoxDecoration(
              color: AppColors.divider,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              Icons.fastfood_outlined,
              color: AppColors.textSecondary,
            ),
          ),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            pr.nombre,
            style: const TextStyle(fontWeight: FontWeight.w500),
          ),
        ),
        Text(
          'S/ ${pr.precio.toStringAsFixed(2)}',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: AppColors.primary,
            fontSize: 15,
          ),
        ),
      ],
    ),
  );
}
