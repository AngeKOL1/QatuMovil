import 'package:flutter/material.dart';

class AppColors {
  // Primarios
  static const Color primary = Color(0xFF1A7A4A);
  static const Color primaryLight = Color(0xFF4CAF78);
  static const Color primaryDark = Color(0xFF0D5C36);
  static const Color secondary = Color(0xFFF59E0B);
  static const Color secondaryLight = Color(0xFFFBBF24);

  // Categorías de vendedores
  static const Color comida = Color(0xFFEF4444);
  static const Color ropa = Color(0xFF8B5CF6);
  static const Color electronica = Color(0xFF3B82F6);
  static const Color servicios = Color(0xFF10B981);
  static const Color otros = Color(0xFF6B7280);

  // Heatmap
  static const Color heatRojo = Color(0xFFDC2626);
  static const Color heatAmarillo = Color(0xFFF59E0B);
  static const Color heatVerde = Color(0xFF16A34A);

  // Zonas
  static const Color zonaRestringida = Color(0xFFEF4444);
  static const Color zonaReasignacion = Color(0xFF3B82F6);

  // UI general
  static const Color background = Color(0xFFF9FAFB);
  static const Color surface = Colors.white;
  static const Color error = Color(0xFFDC2626);
  static const Color textPrimary = Color(0xFF111827);
  static const Color textSecondary = Color(0xFF6B7280);
  static const Color divider = Color(0xFFE5E7EB);

  // Helper para obtener color según categoría
  static Color forCategoria(String categoria) {
    switch (categoria.toUpperCase()) {
      case 'COMIDA':
        return comida;
      case 'ROPA':
        return ropa;
      case 'ELECTRONICA':
        return electronica;
      case 'SERVICIOS':
        return servicios;
      default:
        return otros;
    }
  }
}
