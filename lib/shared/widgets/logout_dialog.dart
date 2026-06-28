import 'package:flutter/material.dart';
import '../../core/core.dart';

Future<bool> mostrarLogoutDialog(BuildContext context) async {
  final resultado = await showDialog<bool>(
    context: context,
    builder: (_) => AlertDialog(
      title: const Text('Cerrar sesión'),
      content: const Text('¿Estás seguro de que quieres cerrar sesión?'),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context, false),
          child: const Text('Cancelar'),
        ),
        TextButton(
          onPressed: () => Navigator.pop(context, true),
          child: Text(
            'Cerrar sesión',
            style: TextStyle(color: AppColors.error),
          ),
        ),
      ],
    ),
  );
  return resultado ?? false;
}
