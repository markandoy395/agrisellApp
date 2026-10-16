import 'package:agresell_app/core/theme/app_typography.dart';
import 'package:flutter/material.dart';

abstract final class RiderStatusPillsStyles {
  static BoxDecoration containerDecoration(Color backgroundColor) =>
      BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(14),
      );

  static TextStyle labelText(Color foregroundColor) => TextStyle(
    fontFamily: AppTypography.fontFamily,
    color: foregroundColor,
    fontSize: 12,
    height: 1,
    fontWeight: FontWeight.w700,
  );
}
