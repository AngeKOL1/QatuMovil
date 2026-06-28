import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:http/http.dart' as http;
import '../../../../core/core.dart';

class RutaLayer extends StatefulWidget {
  final LatLng origen;
  final LatLng destino;

  const RutaLayer({super.key, required this.origen, required this.destino});

  @override
  State<RutaLayer> createState() => _RutaLayerState();
}

class _RutaLayerState extends State<RutaLayer> {
  List<LatLng> _puntosRuta = [];
  bool _cargando = true;

  @override
  void initState() {
    super.initState();
    _calcularRuta();
  }

  @override
  void didUpdateWidget(RutaLayer oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.origen != widget.origen ||
        oldWidget.destino != widget.destino) {
      _calcularRuta();
    }
  }

  Future<void> _calcularRuta() async {
    setState(() => _cargando = true);

    try {
      final url =
          'http://router.project-osrm.org/route/v1/driving/'
          '${widget.origen.longitude},${widget.origen.latitude};'
          '${widget.destino.longitude},${widget.destino.latitude}'
          '?geometries=geojson&overview=full';

      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final coords = data['routes'][0]['geometry']['coordinates'] as List;

        if (!mounted) return;
        setState(() {
          _puntosRuta = coords
              .map(
                (c) =>
                    LatLng((c[1] as num).toDouble(), (c[0] as num).toDouble()),
              )
              .toList();
          _cargando = false;
        });
      } else {
        // Si OSRM falla, usa línea recta como fallback
        _usarLineaRecta();
      }
    } catch (_) {
      _usarLineaRecta();
    }
  }

  void _usarLineaRecta() {
    if (!mounted) return;
    setState(() {
      _puntosRuta = [widget.origen, widget.destino];
      _cargando = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_cargando || _puntosRuta.isEmpty) {
      return PolylineLayer(
        polylines: [
          Polyline(
            points: [widget.origen, widget.destino],
            color: AppColors.zonaReasignacion.withOpacity(0.3),
            strokeWidth: 3,
            isDotted: true,
          ),
        ],
      );
    }

    return PolylineLayer(
      polylines: [
        Polyline(
          points: _puntosRuta,
          color: AppColors.zonaReasignacion,
          strokeWidth: 4,
          borderColor: AppColors.zonaReasignacion.withOpacity(0.3),
          borderStrokeWidth: 2,
        ),
      ],
    );
  }
}

class DestinoMarker {
  static Marker build(LatLng destino) {
    return Marker(
      point: destino,
      width: 44,
      height: 54,
      child: Column(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: AppColors.zonaReasignacion,
              shape: BoxShape.circle,
              border: Border.all(color: Colors.white, width: 2),
              boxShadow: [
                BoxShadow(
                  color: AppColors.zonaReasignacion.withOpacity(0.4),
                  blurRadius: 8,
                  spreadRadius: 2,
                ),
              ],
            ),
            child: const Icon(
              Icons.flag_rounded,
              color: Colors.white,
              size: 18,
            ),
          ),
          Container(
            width: 2,
            height: 10,
            color: AppColors.zonaReasignacion.withOpacity(0.8),
          ),
        ],
      ),
    );
  }
}
