import 'package:flutter/material.dart';

import 'package:agresell_app/core/theme/app_typography.dart';

abstract final class FarmerProfileStyle {
  // Core brand palette
  static const green = Color(0xFF08683F);
  static const deepGreen = Color(0xFF054D2D);
  static const richGreen = Color(0xFF0A7A49);
  static const mint = Color(0xFFE5F7EF);
  static const mintDeep = Color(0xFFCDF0DC);
  static const ink = Color(0xFF071E27);
  static const muted = Color(0xFF687781);
  static const background = Color(0xFFF0F5F2);
  static const surface = Color(0xFFFFFFFF);
  static const borderSubtle = Color(0xFFE3EDE8);

  // Gradient presets
  static const heroGradient = LinearGradient(
    colors: [Color(0xFF062E1D), Color(0xFF0B5435), Color(0xFF0E6B43)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    stops: [0.0, 0.55, 1.0],
  );

  // Typography tokens aligned with centralized AppTypography scale
  static const heading = TextStyle(
    fontFamily: AppTypography.fontFamily,
    color: ink,
    fontSize: 15,
    fontWeight: FontWeight.w700,
    letterSpacing: -0.2,
  );

  static const sectionLabel = TextStyle(
    fontFamily: AppTypography.fontFamily,
    color: Color(0xFF3A6652),
    fontSize: 12,
    fontWeight: FontWeight.w700,
    letterSpacing: 1.2,
  );

  static const tileTitle = TextStyle(
    fontFamily: AppTypography.fontFamily,
    color: ink,
    fontSize: 15,
    fontWeight: FontWeight.w600,
    letterSpacing: -0.1,
  );

  static const tileSubtitle = TextStyle(
    fontFamily: AppTypography.fontFamily,
    color: muted,
    fontSize: 13,
    height: 1.35,
  );
}
