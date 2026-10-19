import 'package:flutter/material.dart';
import 'package:agresell_app/core/theme/agrisell_colors.dart';
import 'package:agresell_app/core/theme/app_typography.dart';

abstract final class CustomBottomNavTabStyles {
  static TextStyle textStyle(
    bool isSelected,
    Color activeBackground,
    Color labelColor,
    double labelFontSize,
  ) => TextStyle(
    fontFamily: AppTypography.fontFamily,
    color: isSelected ? activeBackground : labelColor,
    fontSize: labelFontSize,
    height: 1,
    fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
  );

  static BoxDecoration animatedContainerDecoration(
    bool isSelected,
    Color activeBackground,
  ) => BoxDecoration(
    color: isSelected ? activeBackground : Colors.transparent,
    borderRadius: BorderRadius.circular(12),
  );

  static final containerDecoration = BoxDecoration(
    color: AgrisellColors.authGreen,
    borderRadius: BorderRadius.circular(9),
    border: Border.all(color: AgrisellColors.surface, width: 1.5),
    boxShadow: [
      BoxShadow(
        color: AgrisellColors.brandBlack.withValues(alpha: 0.16),
        blurRadius: 6,
        offset: const Offset(0, 2),
      ),
    ],
  );

  static const textStyle2 = TextStyle(
    color: AgrisellColors.surface,
    fontSize: 12,
    height: 1,
    fontWeight: FontWeight.w700,
  );
}
