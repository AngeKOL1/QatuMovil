import 'package:flutter/material.dart';
import '../../../core/core.dart';
import '../../../models/models.dart';
import '../../services/Service.dart';
import 'reportes_form_screen.dart';

class ReportesScreen extends StatefulWidget {
  const ReportesScreen({super.key});

  @override
  State<ReportesScreen> createState() => _ReportesScreenState();
}

class _ReportesScreenState extends State<ReportesScreen> {
  final _reporteService = ReporteService();
  final _scrollCtrl = ScrollController();
  final List<ReporteResponse> _reportes = [];

  int _paginaActual = 0;
  bool _cargando = false;
  bool _esUltima = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _cargarReportes();
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

  Future<void> _cargarReportes({bool reset = false}) async {
    if (_cargando) return;
    if (reset) {
      _paginaActual = 0;
      _reportes.clear();
      _esUltima = false;
    }
    setState(() {
      _cargando = true;
      _error = null;
    });

    final resp = await _reporteService.getMisReportes(pagina: _paginaActual);

    if (!mounted) return;
    setState(() {
      _cargando = false;
      if (resp.success && resp.data != null) {
        _reportes.addAll(resp.data!.contenido);
        _esUltima = resp.data!.esUltima;
      } else {
        _error = resp.error;
      }
    });
  }

  Future<void> _cargarMas() async {
    if (_esUltima || _cargando) return;
    _paginaActual++;
    await _cargarReportes();
  }

  Future<void> _irAFormulario() async {
    final resultado = await Navigator.push<bool>(
      context,
      MaterialPageRoute(builder: (_) => const ReporteFormScreen()),
    );
    if (resultado == true) {
      _cargarReportes(reset: true);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Mis reportes'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
      ),
      body: _error != null && _reportes.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(_error!, style: TextStyle(color: AppColors.error)),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () => _cargarReportes(reset: true),
                    child: const Text('Reintentar'),
                  ),
                ],
              ),
            )
          : RefreshIndicator(
              onRefresh: () => _cargarReportes(reset: true),
              child: _reportes.isEmpty && !_cargando
                  ? ListView(
                      children: [
                        SizedBox(
                          height: MediaQuery.of(context).size.height * 0.6,
                          child: Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.description_outlined,
                                  size: 64,
                                  color: AppColors.textSecondary,
                                ),
                                const SizedBox(height: 16),
                                Text(
                                  'No tienes reportes',
                                  style: TextStyle(
                                    color: AppColors.textSecondary,
                                    fontSize: 16,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  'Crea un reporte con el botón +',
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
                      itemCount: _reportes.length + (_cargando ? 1 : 0),
                      itemBuilder: (_, i) {
                        if (i == _reportes.length) {
                          return const Padding(
                            padding: EdgeInsets.all(16),
                            child: Center(
                              child: CircularProgressIndicator(strokeWidth: 2),
                            ),
                          );
                        }
                        return _reporteTile(_reportes[i]);
                      },
                    ),
            ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        onPressed: _irAFormulario,
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _reporteTile(ReporteResponse r) {
    final color = _colorForEstado(r.estado);
    final icon = _iconForEstado(r.estado);

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.divider),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            children: [
              Icon(icon, color: color, size: 20),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  r.asunto,
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 15,
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  r.estado,
                  style: TextStyle(
                    color: color,
                    fontWeight: FontWeight.w600,
                    fontSize: 11,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 10),

          // Descripción
          Text(
            r.descripcion,
            style: TextStyle(
              color: AppColors.textSecondary,
              fontSize: 14,
              height: 1.4,
            ),
            maxLines: 3,
            overflow: TextOverflow.ellipsis,
          ),

          const SizedBox(height: 10),

          // Fecha
          Row(
            children: [
              Icon(
                Icons.calendar_today,
                size: 12,
                color: AppColors.textSecondary,
              ),
              const SizedBox(width: 4),
              Text(
                _formatFecha(r.fechaEnvio),
                style: TextStyle(color: AppColors.textSecondary, fontSize: 12),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Color _colorForEstado(String estado) {
    switch (estado.toUpperCase()) {
      case 'ABIERTO':
        return AppColors.secondary;
      case 'EN_PROCESO':
        return AppColors.electronica;
      case 'RESUELTO':
        return AppColors.servicios;
      case 'CERRADO':
        return AppColors.textSecondary;
      default:
        return AppColors.textSecondary;
    }
  }

  IconData _iconForEstado(String estado) {
    switch (estado.toUpperCase()) {
      case 'ABIERTO':
        return Icons.error_outline;
      case 'EN_PROCESO':
        return Icons.hourglass_top_rounded;
      case 'RESUELTO':
        return Icons.check_circle_outline;
      case 'CERRADO':
        return Icons.cancel_outlined;
      default:
        return Icons.description_outlined;
    }
  }

  String _formatFecha(String fecha) {
    try {
      final dt = DateTime.parse(fecha);
      return '${dt.day.toString().padLeft(2, '0')}/${dt.month.toString().padLeft(2, '0')}/${dt.year}';
    } catch (_) {
      return fecha;
    }
  }
}
