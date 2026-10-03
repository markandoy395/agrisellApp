import 'package:flutter/material.dart';
import 'package:agresell_app/core/theme/agrisell_colors.dart';

abstract final class SoldOverlayStyles {
  static final decoratedBoxDecoration = BoxDecoration(
    color: AgrisellColors.brandBlack.withValues(alpha: 0.18),
  );

  static TextStyle soldText(double fontSize, double strokeWidth) => TextStyle(
    fontSize: fontSize,
    height: 1,
    letterSpacing: 0,
    fontWeight: FontWeight.w900,
    foreground: Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..color = AgrisellColors.brandBlack,
  );

  static TextStyle soldText2(double fontSize) => TextStyle(
    color: AgrisellColors.surface,
    fontSize: fontSize,
    height: 1,
    letterSpacing: 0,
    fontWeight: FontWeight.w900,
    shadows: [
      Shadow(
        color: AgrisellColors.brandBlack.withValues(alpha: 0.6),
        blurRadius: 6,
        offset: const Offset(0, 2),
      ),
    ],
  );
}
