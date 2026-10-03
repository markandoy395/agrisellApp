import 'package:flutter/material.dart';
import 'package:agresell_app/core/theme/agrisell_colors.dart';

abstract final class FarmerDashboardTabsStyles {
  static final containerDecoration = BoxDecoration(
    color: AgrisellColors.surface,
    borderRadius: const BorderRadius.vertical(top: Radius.circular(21)),
    boxShadow: [
      BoxShadow(
        color: AgrisellColors.brandBlack.withValues(alpha: 0.08),
        blurRadius: 10,
        offset: const Offset(0, 4),
      ),
    ],
  );

  static TextStyle labelText(Color textColor) => TextStyle(
    color: textColor,
    fontSize: 13,
    height: 1,
    fontWeight: FontWeight.w800,
  );
}
