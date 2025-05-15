import 'package:flutter/material.dart';

class AppColors {
  static const background = Color(0xFFFFFCF2);
  static const primary = Color(0xFFE67553);
  static const secondary = Color(0xFF2D4436);

  static const softYellow = Color(0xFFFFEEBC);
  static const softBlue = Color(0xFFD2E8FF);

  static const textPrimary = Color(0xFF1F2937);
  static const textSecondary = Color(0xFF2E422A);

  static Color dynamicBackground(bool highContrast) =>
      highContrast ? Colors.blueGrey : const Color(0xFFFFF7E6);
}
