import 'dart:async';
import 'package:flutter/material.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import '../../core/core.dart';

class ConnectionBanner extends StatefulWidget {
  final Widget child;

  const ConnectionBanner({super.key, required this.child});

  @override
  State<ConnectionBanner> createState() => _ConnectionBannerState();
}

class _ConnectionBannerState extends State<ConnectionBanner> {
  bool _sinConexion = false;
  late StreamSubscription _subscription;

  @override
  void initState() {
    super.initState();
    _verificarConexion();
    _subscription = Connectivity().onConnectivityChanged.listen(
      _actualizarEstado,
    );
  }

  @override
  void dispose() {
    _subscription.cancel();
    super.dispose();
  }

  Future<void> _verificarConexion() async {
    final result = await Connectivity().checkConnectivity();
    _actualizarEstado(result);
  }

  void _actualizarEstado(List<ConnectivityResult> result) {
    if (!mounted) return;
    setState(() {
      _sinConexion = result.contains(ConnectivityResult.none);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Banner de sin conexión
        AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          height: _sinConexion ? null : 0,
          color: AppColors.error,
          width: double.infinity,
          child: _sinConexion
              ? SafeArea(
                  bottom: false,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    child: Row(
                      children: [
                        const Icon(
                          Icons.wifi_off_rounded,
                          color: Colors.white,
                          size: 18,
                        ),
                        const SizedBox(width: 8),
                        const Expanded(
                          child: Text(
                            'Sin conexión a internet',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 13,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                        GestureDetector(
                          onTap: _verificarConexion,
                          child: const Text(
                            'Reintentar',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              decoration: TextDecoration.underline,
                              decorationColor: Colors.white,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                )
              : const SizedBox.shrink(),
        ),
        // Contenido de la app
        Expanded(child: widget.child),
      ],
    );
  }
}