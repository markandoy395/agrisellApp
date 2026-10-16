import 'package:agresell_app/core/theme/app_typography.dart';
import 'package:flutter/material.dart';
import 'package:agresell_app/core/theme/agrisell_colors.dart';

abstract final class RiderHistoryWidgetsStyles {
  static const textStyle = TextStyle(
    fontFamily: AppTypography.fontFamily,
    color: AgrisellColors.headingGreen,
    fontSize: 12,
    fontWeight: FontWeight.w800,
  );

  static const valueText = TextStyle(
    fontFamily: AppTypography.fontFamily,
    color: AgrisellColors.mutedText,
    fontSize: 12,
    height: 1.25,
    fontWeight: FontWeight.w600,
  );

  static BoxDecoration decoratedBoxDecoration(Color color) => BoxDecoration(
    color: color.withValues(alpha: 0.12),
    borderRadius: BorderRadius.circular(12),
  );

  static TextStyle textStyle2(Color color) => TextStyle(
    fontFamily: AppTypography.fontFamily,
    color: color,
    fontSize: 12,
    fontWeight: FontWeight.w800,
  );
}
