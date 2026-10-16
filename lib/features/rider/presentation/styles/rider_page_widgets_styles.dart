import 'package:agresell_app/core/theme/app_typography.dart';
import 'package:flutter/material.dart';
import 'package:agresell_app/core/theme/agrisell_colors.dart';

abstract final class RiderPageWidgetsStyles {
  static const containerDecoration = BoxDecoration(
    color: AgrisellColors.authGreen,
    borderRadius: BorderRadius.vertical(bottom: Radius.circular(22)),
  );

  static const titleText = TextStyle(
    fontFamily: AppTypography.fontFamily,
    color: AgrisellColors.surface,
    fontSize: 15,
    height: 1.1,
    fontWeight: FontWeight.w800,
  );

  static final valueText = TextStyle(
    fontFamily: AppTypography.fontFamily,
    color: AgrisellColors.surface.withValues(alpha: 0.9),
    fontSize: 15,
    height: 1.2,
    fontWeight: FontWeight.w600,
  );

  static final decoratedBoxDecoration = BoxDecoration(
    color: AgrisellColors.surface,
    borderRadius: BorderRadius.circular(12),
    border: Border.all(color: AgrisellColors.borderLine),
    boxShadow: [
      BoxShadow(
        color: AgrisellColors.brandBlack.withValues(alpha: 0.07),
        blurRadius: 12,
        offset: const Offset(0, 5),
      ),
    ],
  );

  static const titleText2 = TextStyle(
    fontFamily: AppTypography.fontFamily,
    color: AgrisellColors.headingGreen,
    fontSize: 14,
    height: 1.1,
    fontWeight: FontWeight.w800,
  );
}
