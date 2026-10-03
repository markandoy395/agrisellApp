import 'package:flutter/material.dart';
import 'package:agresell_app/core/theme/agrisell_colors.dart';
import 'package:agresell_app/core/utils/responsive.dart';

abstract final class AuthButtonStyles {
  static ButtonStyle filledButtonStyle(
    double effectiveRadius,
    double? fontSize,
    double scale,
  ) => FilledButton.styleFrom(
    backgroundColor: AgrisellColors.authGreen,
    foregroundColor: AgrisellColors.surface,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(effectiveRadius),
    ),
    textStyle: TextStyle(
      fontSize: fontSize ?? lerpDouble(12, 13, scale),
      fontWeight: FontWeight.w600,
    ),
    padding: const EdgeInsets.symmetric(horizontal: 16),
  );

  static BoxDecoration containerDecoration(double effectiveRadius) =>
      BoxDecoration(
        borderRadius: BorderRadius.circular(effectiveRadius),
        boxShadow: [
          BoxShadow(
            color: AgrisellColors.authGreen.withValues(alpha: 0.32),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      );

  static ButtonStyle outlinedButtonStyle(double scale) =>
      OutlinedButton.styleFrom(
        foregroundColor: AgrisellColors.authGreen,
        side: const BorderSide(color: AgrisellColors.authGreen, width: 2),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        textStyle: TextStyle(
          fontSize: lerpDouble(12, 13, scale),
          fontWeight: FontWeight.w600,
        ),
        padding: const EdgeInsets.symmetric(horizontal: 16),
      );
}
