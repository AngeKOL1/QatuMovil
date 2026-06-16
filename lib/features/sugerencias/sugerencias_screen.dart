import 'package:flutter/material.dart';
import '../../../core/core.dart';
import '../../../models/models.dart';
import '../../services/Service.dart';

class SugerenciasScreen extends StatefulWidget {
  const SugerenciasScreen({super.key});

  @override
  State<SugerenciasScreen> createState() => _SugerenciasScreenState();
}

class _SugerenciasScreenState extends State<SugerenciasScreen> {
  final _sugerenciaService = SugerenciaService();
  final _scrollCtrl = ScrollController();
  final List<SugerenciaResponse> _sugerencias = [];

  int _paginaActual = 0;
  bool _cargando = false;
  bool _esUltima = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _cargarSugerencias();
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

  Future<void> _cargarSugerencias({bool reset = false}) async {
    if (_cargando) return;
    if (reset) {
      _paginaActual = 0;
      _sugerencias.clear();
      _esUltima = false;
    }
    setState(() {
      _cargando = true;
      _error = null;
    });

    final resp = await _sugerenciaService.getMisSugerencias(
      pagina: _paginaActual,
    );

    if (!mounted) return;
    setState(() {
      _cargando = false;
      if (resp.success && resp.data != null) {
        _sugerencias.addAll(resp.data!.contenido);
        _esUltima = resp.data!.esUltima;
      } else {
        _error = resp.error;
      }
    });
  }

  Future<void> _cargarMas() async {
    if (_esUltima || _cargando) return;
    _paginaActual++;
    await _cargarSugerencias();
  }

  Future<void> _responder(SugerenciaResponse sugerencia, String accion) async {
    final confirmar = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(
          accion == 'ACEPTADA' ? 'Aceptar sugerencia' : 'Ignorar sugerencia',
        ),
        content: Text(
          accion == 'ACEPTADA'
              ? '¿Aceptar la reubicación a "${sugerencia.nombreZona}"?'
              : '¿Ignorar esta sugerencia?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text(
              accion == 'ACEPTADA' ? 'Aceptar' : 'Ignorar',
              style: TextStyle(
                color: accion == 'ACEPTADA'
                    ? AppColors.servicios
                    : AppColors.error,
              ),
            ),
          ),
        ],
      ),
    );

    if (confirmar != true) return;

    final resp = await _sugerenciaService.responderSugerencia(
      sugerencia.id,
      accion,
    );

    if (!mounted) return;

    if (resp.success) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            accion == 'ACEPTADA'
                ? 'Sugerencia aceptada'
                : 'Sugerencia ignorada',
          ),
        ),
      );
      _cargarSugerencias(reset: true);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(resp.error ?? 'Error al responder'),
          backgroundColor: AppColors.error,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Sugerencias'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
      ),
      body: _error != null && _sugerencias.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(_error!, style: TextStyle(color: AppColors.error)),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () => _cargarSugerencias(reset: true),
                    child: const Text('Reintentar'),
                  ),
                ],
              ),
            )
          : RefreshIndicator(
              onRefresh: () => _cargarSugerencias(reset: true),
              child: _sugerencias.isEmpty && !_cargando
                  ? ListView(
                      children: [
                        SizedBox(
                          height: MediaQuery.of(context).size.height * 0.6,
                          child: Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.lightbulb_outline,
                                  size: 64,
                                  color: AppColors.textSecondary,
                                ),
                                const SizedBox(height: 16),
                                Text(
                                  'No tienes sugerencias',
                                  style: TextStyle(
                                    color: AppColors.textSecondary,
                                    fontSize: 16,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  'Aquí aparecerán las sugerencias de reubicación',
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
                      itemCount: _sugerencias.length + (_cargando ? 1 : 0),
                      itemBuilder: (_, i) {
                        if (i == _sugerencias.length) {
                          return const Padding(
                            padding: EdgeInsets.all(16),
                            child: Center(
                              child: CircularProgressIndicator(strokeWidth: 2),
                            ),
                          );
                        }
                        return _sugerenciaTile(_sugerencias[i]);
                      },
                    ),
            ),
    );
  }

  Widget _sugerenciaTile(SugerenciaResponse s) {
    final esPendiente = s.estado == 'ENVIADA';
    final color = _colorForEstado(s.estado);
    final colorZona = s.tipoZona == 'RESTRINGIDA'
        ? AppColors.zonaRestringida
        : AppColors.zonaReasignacion;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: esPendiente ? AppColors.secondary : AppColors.divider,
          width: esPendiente ? 1.5 : 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            children: [
              Icon(Icons.location_on_rounded, color: colorZona, size: 20),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  s.nombreZona,
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
                  s.estado,
                  style: TextStyle(
                    color: color,
                    fontWeight: FontWeight.w600,
                    fontSize: 11,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 8),

          // Info
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: colorZona.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  s.tipoZona,
                  style: TextStyle(
                    color: colorZona,
                    fontSize: 11,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Icon(
                Icons.calendar_today,
                size: 12,
                color: AppColors.textSecondary,
              ),
              const SizedBox(width: 4),
              Text(
                _formatFecha(s.fechaEnvio),
                style: TextStyle(color: AppColors.textSecondary, fontSize: 12),
              ),
            ],
          ),

          // Botones de acción si está pendiente
          if (esPendiente) ...[
            const SizedBox(height: 14),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => _responder(s, 'IGNORADA'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.textSecondary,
                      side: BorderSide(color: AppColors.divider),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    child: const Text('Ignorar'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () => _responder(s, 'ACEPTADA'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.servicios,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    child: const Text('Aceptar'),
                  ),
                ),
              ],
            ),
          ],

          // Fecha de respuesta si ya respondió
          if (s.fechaRespuesta != null) ...[
            const SizedBox(height: 8),
            Text(
              'Respondido: ${_formatFecha(s.fechaRespuesta!)}',
              style: TextStyle(color: AppColors.textSecondary, fontSize: 12),
            ),
          ],
        ],
      ),
    );
  }

  Color _colorForEstado(String estado) {
    switch (estado) {
      case 'ENVIADA':
        return AppColors.secondary;
      case 'ACEPTADA':
        return AppColors.servicios;
      case 'IGNORADA':
        return AppColors.textSecondary;
      default:
        return AppColors.textSecondary;
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
