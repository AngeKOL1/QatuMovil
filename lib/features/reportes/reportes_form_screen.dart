import 'package:flutter/material.dart';
import '../../../core/core.dart';
import '../../../models/models.dart';
import '../../services/Service.dart';

class ReporteFormScreen extends StatefulWidget {
  const ReporteFormScreen({super.key});

  @override
  State<ReporteFormScreen> createState() => _ReporteFormScreenState();
}

class _ReporteFormScreenState extends State<ReporteFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _reporteService = ReporteService();
  final _asuntoCtrl = TextEditingController();
  final _descripcionCtrl = TextEditingController();

  bool _loading = false;
  String? _error;

  @override
  void dispose() {
    _asuntoCtrl.dispose();
    _descripcionCtrl.dispose();
    super.dispose();
  }

  Future<void> _enviar() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() {
      _loading = true;
      _error = null;
    });

    final resp = await _reporteService.crearReporte(
      ReporteRequest(
        asunto: _asuntoCtrl.text.trim(),
        descripcion: _descripcionCtrl.text.trim(),
      ),
    );

    if (!mounted) return;
    setState(() => _loading = false);

    if (resp.success) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Reporte enviado')));
      Navigator.pop(context, true);
    } else {
      setState(() => _error = resp.error);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Nuevo reporte'),
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
              Text(
                'Describe el problema o situación que quieres reportar',
                style: TextStyle(color: AppColors.textSecondary, fontSize: 14),
              ),
              const SizedBox(height: 20),
              TextFormField(
                controller: _asuntoCtrl,
                decoration: const InputDecoration(
                  labelText: 'Asunto',
                  prefixIcon: Icon(Icons.subject_rounded),
                ),
                validator: (v) =>
                    (v == null || v.isEmpty) ? 'Campo requerido' : null,
              ),
              const SizedBox(height: 14),
              TextFormField(
                controller: _descripcionCtrl,
                maxLines: 5,
                decoration: const InputDecoration(
                  labelText: 'Descripción',
                  prefixIcon: Icon(Icons.description_outlined),
                  alignLabelWithHint: true,
                ),
                validator: (v) =>
                    (v == null || v.isEmpty) ? 'Campo requerido' : null,
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
                onPressed: _loading ? null : _enviar,
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
                        'Enviar reporte',
                        style: TextStyle(fontSize: 16),
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
