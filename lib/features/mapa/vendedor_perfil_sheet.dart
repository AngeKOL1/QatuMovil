import 'package:flutter/material.dart';
import '../../../core/core.dart';
import '../../../models/models.dart';
import '../../../services/Service.dart';

class VendedorPerfilSheet extends StatefulWidget {
  final int vendedorId;
  const VendedorPerfilSheet({super.key, required this.vendedorId});

  @override
  State<VendedorPerfilSheet> createState() => _VendedorPerfilSheetState();
}

class _VendedorPerfilSheetState extends State<VendedorPerfilSheet> {
  final _mapaService = MapaService();
  VendedorPerfilDTO? _perfil;
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _cargarPerfil();
  }

  Future<void> _cargarPerfil() async {
    final resp = await _mapaService.getVendedorPerfil(widget.vendedorId);
    setState(() {
      _loading = false;
      _perfil = resp.data;
      _error = resp.error;
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
        child: _loading
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

    return ListView(
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
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 3,
                        ),
                        decoration: BoxDecoration(
                          color: color.withOpacity(0.12),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          p.categoria,
                          style: TextStyle(
                            color: color,
                            fontWeight: FontWeight.w600,
                            fontSize: 11,
                          ),
                        ),
                      ),
                      const SizedBox(width: 6),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 3,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.divider,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          p.movilidad,
                          style: TextStyle(
                            color: AppColors.textSecondary,
                            fontSize: 11,
                          ),
                        ),
                      ),
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

        // Catálogo
        if (p.productos.isNotEmpty) ...[
          const SizedBox(height: 20),
          const Text(
            'Catálogo',
            style: TextStyle(fontWeight: FontWeight.w600, fontSize: 15),
          ),
          const SizedBox(height: 10),
          ...p.productos
              .where((pr) => pr.activo)
              .map((pr) => _productoTile(pr)),
        ] else ...[
          const SizedBox(height: 20),
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
                Text(
                  'Este vendedor no tiene productos publicados',
                  style: TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }

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
