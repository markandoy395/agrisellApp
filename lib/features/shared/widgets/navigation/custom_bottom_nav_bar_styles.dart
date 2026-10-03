import 'package:flutter/material.dart';
import 'package:agresell_app/core/theme/agrisell_colors.dart';

abstract final class CustomBottomNavBarStyles {
  static BoxDecoration containerDecoration(Color shadowColor) => BoxDecoration(
    borderRadius: BorderRadius.circular(22),
    border: Border.all(
      color: AgrisellColors.brandBlack.withValues(alpha: 0.06),
    ),
    boxShadow: [
      BoxShadow(color: shadowColor, blurRadius: 18, offset: const Offset(0, 6)),
    ],
  );
}
