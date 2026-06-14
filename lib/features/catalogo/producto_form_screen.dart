import 'package:flutter/material.dart';
import '../../../core/core.dart';
import '../../../models/models.dart';
import '../../services/Service.dart';

class ProductoFormScreen extends StatefulWidget {
  final ProductoDTO? producto; // null = crear, con data = editar

  const ProductoFormScreen({super.key, this.producto});

  @override
  State<ProductoFormScreen> createState() => _ProductoFormScreenState();
}

class _ProductoFormScreenState extends State<ProductoFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _productoService = ProductoService();
  bool _loading = false;
  String? _error;

  late final TextEditingController _nombreCtrl;
  late final TextEditingController _precioCtrl;
  late final TextEditingController _descripcionCtrl;
  late final TextEditingController _fotoUrlCtrl;

  bool get _isEditing => widget.producto != null;

  @override
  void initState() {
    super.initState();
    _nombreCtrl = TextEditingController(text: widget.producto?.nombre ?? '');
    _precioCtrl = TextEditingController(
      text: widget.producto?.precio.toStringAsFixed(2) ?? '',
    );
    _descripcionCtrl = TextEditingController(
      text: widget.producto?.descripcion ?? '',
    );
    _fotoUrlCtrl = TextEditingController(text: widget.producto?.fotoUrl ?? '');
  }

  @override
  void dispose() {
    _nombreCtrl.dispose();
    _precioCtrl.dispose();
    _descripcionCtrl.dispose();
    _fotoUrlCtrl.dispose();
    super.dispose();
  }

  Future<void> _guardar() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() {
      _loading = true;
      _error = null;
    });

    final request = ProductoRequest(
      nombre: _nombreCtrl.text.trim(),
      precio: double.parse(_precioCtrl.text.trim()),
      descripcion: _descripcionCtrl.text.trim().isEmpty
          ? null
          : _descripcionCtrl.text.trim(),
      fotoUrl: _fotoUrlCtrl.text.trim().isEmpty
          ? null
          : _fotoUrlCtrl.text.trim(),
    );

    final resp = _isEditing
        ? await _productoService.actualizarProducto(
            widget.producto!.id,
            request,
          )
        : await _productoService.crearProducto(request);

    if (!mounted) return;
    setState(() => _loading = false);

    if (resp.success) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            _isEditing ? 'Producto actualizado' : 'Producto creado',
          ),
        ),
      );
      Navigator.pop(context, true); // true = hubo cambios
    } else {
      setState(() => _error = resp.error);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_isEditing ? 'Editar producto' : 'Nuevo producto'),
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
              TextFormField(
                controller: _nombreCtrl,
                decoration: const InputDecoration(
                  labelText: 'Nombre del producto',
                  prefixIcon: Icon(Icons.fastfood_outlined),
                ),
                validator: (v) =>
                    (v == null || v.isEmpty) ? 'Campo requerido' : null,
              ),
              const SizedBox(height: 14),
              TextFormField(
                controller: _precioCtrl,
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                ),
                decoration: const InputDecoration(
                  labelText: 'Precio (S/)',
                  prefixIcon: Icon(Icons.attach_money),
                ),
                validator: (v) {
                  if (v == null || v.isEmpty) return 'Campo requerido';
                  final precio = double.tryParse(v);
                  if (precio == null || precio <= 0) {
                    return 'Ingresa un precio válido';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 14),
              TextFormField(
                controller: _descripcionCtrl,
                maxLines: 3,
                decoration: const InputDecoration(
                  labelText: 'Descripción (opcional)',
                  prefixIcon: Icon(Icons.description_outlined),
                  alignLabelWithHint: true,
                ),
              ),
              const SizedBox(height: 14),
              TextFormField(
                controller: _fotoUrlCtrl,
                decoration: const InputDecoration(
                  labelText: 'URL de la foto (opcional)',
                  prefixIcon: Icon(Icons.image_outlined),
                ),
              ),

              // Preview de la foto
              if (_fotoUrlCtrl.text.isNotEmpty) ...[
                const SizedBox(height: 14),
                ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: Image.network(
                    _fotoUrlCtrl.text,
                    height: 160,
                    width: double.infinity,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => Container(
                      height: 160,
                      color: AppColors.divider,
                      child: Center(
                        child: Text(
                          'No se pudo cargar la imagen',
                          style: TextStyle(color: AppColors.textSecondary),
                        ),
                      ),
                    ),
                  ),
                ),
              ],

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
                onPressed: _loading ? null : _guardar,
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
                    : Text(
                        _isEditing ? 'Guardar cambios' : 'Crear producto',
                        style: const TextStyle(fontSize: 16),
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
