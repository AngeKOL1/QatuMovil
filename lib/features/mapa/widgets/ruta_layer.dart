import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import '../../../../core/core.dart';

class RutaLayer extends StatelessWidget {
  final LatLng origen;
  final LatLng destino;

  const RutaLayer({super.key, required this.origen, required this.destino});

  @override
  Widget build(BuildContext context) {
    return PolylineLayer(
      polylines: [
        Polyline(
          points: [origen, destino],
          color: AppColors.zonaReasignacion,
          strokeWidth: 4,
          isDotted: true,
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
