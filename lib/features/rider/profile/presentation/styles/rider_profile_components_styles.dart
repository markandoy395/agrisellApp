import 'package:agresell_app/core/theme/app_typography.dart';
import 'package:flutter/material.dart';

abstract final class RiderProfileComponentsStyles {
  static const valueText = TextStyle(
    fontFamily: AppTypography.fontFamily,
    fontSize: 12,
    height: 1.25,
    fontWeight: FontWeight.w600,
  );

  static TextStyle labelText(Color color) => TextStyle(
    fontFamily: AppTypography.fontFamily,
    color: color,
    fontSize: 12,
    fontWeight: FontWeight.w700,
  );
}
