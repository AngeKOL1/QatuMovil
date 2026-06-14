import 'package:flutter/material.dart';
import '../../../core/core.dart';
import '../../../models/models.dart';
import '../../services/Service.dart';
import 'producto_form_screen.dart';

class CatalogoScreen extends StatefulWidget {
  const CatalogoScreen({super.key});

  @override
  State<CatalogoScreen> createState() => _CatalogoScreenState();
}

class _CatalogoScreenState extends State<CatalogoScreen> {
  final _productoService = ProductoService();
  final _scrollCtrl = ScrollController();
  final List<ProductoDTO> _productos = [];

  int _paginaActual = 0;
  bool _cargando = false;
  bool _esUltima = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _cargarProductos();
    _scrollCtrl.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollCtrl.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollCtrl.position.pixels >=
        _scrollCtrl.position.maxScrollExtent * 0.9) {
      _cargarMas();
    }
  }

  Future<void> _cargarProductos({bool reset = false}) async {
    if (_cargando) return;
    if (reset) {
      _paginaActual = 0;
      _productos.clear();
      _esUltima = false;
    }
    setState(() {
      _cargando = true;
      _error = null;
    });

    final resp = await _productoService.getMisProductos(pagina: _paginaActual);

    if (!mounted) return;
    setState(() {
      _cargando = false;
      if (resp.success && resp.data != null) {
        _productos.addAll(resp.data!.contenido);
        _esUltima = resp.data!.esUltima;
      } else {
        _error = resp.error;
      }
    });
  }

  Future<void> _cargarMas() async {
    if (_esUltima || _cargando) return;
    _paginaActual++;
    await _cargarProductos();
  }

  Future<void> _eliminarProducto(ProductoDTO producto) async {
    final confirmar = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Eliminar producto'),
        content: Text('¿Eliminar "${producto.nombre}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text('Eliminar', style: TextStyle(color: AppColors.error)),
          ),
        ],
      ),
    );

    if (confirmar != true) return;

    final resp = await _productoService.eliminarProducto(producto.id);
    if (resp.success) {
      _cargarProductos(reset: true);
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Producto eliminado')));
      }
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(resp.error ?? 'Error al eliminar'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }

  Future<void> _irAFormulario({ProductoDTO? producto}) async {
    final resultado = await Navigator.push<bool>(
      context,
      MaterialPageRoute(builder: (_) => ProductoFormScreen(producto: producto)),
    );
    // Si volvió con true significa que se creó/editó un producto
    if (resultado == true) {
      _cargarProductos(reset: true);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Mi catálogo'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
      ),
      body: _error != null && _productos.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(_error!, style: TextStyle(color: AppColors.error)),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () => _cargarProductos(reset: true),
                    child: const Text('Reintentar'),
                  ),
                ],
              ),
            )
          : RefreshIndicator(
              onRefresh: () => _cargarProductos(reset: true),
              child: _productos.isEmpty && !_cargando
                  ? ListView(
                      children: [
                        SizedBox(
                          height: MediaQuery.of(context).size.height * 0.6,
                          child: Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.inventory_2_outlined,
                                  size: 64,
                                  color: AppColors.textSecondary,
                                ),
                                const SizedBox(height: 16),
                                Text(
                                  'Aún no tienes productos',
                                  style: TextStyle(
                                    color: AppColors.textSecondary,
                                    fontSize: 16,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  'Agrega tu primer producto con el botón +',
                                  style: TextStyle(
                                    color: AppColors.textSecondary,
                                    fontSize: 13,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    )
                  : ListView.builder(
                      controller: _scrollCtrl,
                      padding: const EdgeInsets.all(16),
                      itemCount: _productos.length + (_cargando ? 1 : 0),
                      itemBuilder: (_, i) {
                        if (i == _productos.length) {
                          return const Padding(
                            padding: EdgeInsets.all(16),
                            child: Center(
                              child: CircularProgressIndicator(strokeWidth: 2),
                            ),
                          );
                        }
                        return _productoTile(_productos[i]);
                      },
                    ),
            ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        onPressed: () => _irAFormulario(),
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _productoTile(ProductoDTO pr) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.divider),
      ),
      child: Row(
        children: [
          // Foto
          if (pr.fotoUrl != null)
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Image.network(
                pr.fotoUrl!,
                width: 56,
                height: 56,
                fit: BoxFit.cover,
              ),
            )
          else
            Container(
              width: 56,
              height: 56,
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

          // Info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  pr.nombre,
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 15,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'S/ ${pr.precio.toStringAsFixed(2)}',
                  style: TextStyle(
                    color: AppColors.primary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                if (!pr.activo)
                  Container(
                    margin: const EdgeInsets.only(top: 4),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 6,
                      vertical: 2,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.error.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      'Inactivo',
                      style: TextStyle(color: AppColors.error, fontSize: 11),
                    ),
                  ),
              ],
            ),
          ),

          // Acciones
          IconButton(
            icon: Icon(Icons.edit_outlined, color: AppColors.primary),
            onPressed: () => _irAFormulario(producto: pr),
            tooltip: 'Editar',
          ),
          IconButton(
            icon: Icon(Icons.delete_outline, color: AppColors.error),
            onPressed: () => _eliminarProducto(pr),
            tooltip: 'Eliminar',
          ),
        ],
      ),
    );
  }
}
