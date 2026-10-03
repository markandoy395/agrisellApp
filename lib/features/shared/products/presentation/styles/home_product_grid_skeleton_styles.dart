import 'package:flutter/material.dart';
import 'package:agresell_app/core/theme/agrisell_colors.dart';

abstract final class HomeProductGridSkeletonStyles {
  static final decoratedBoxDecoration = BoxDecoration(
    color: AgrisellColors.surface,
    borderRadius: BorderRadius.circular(10),
    border: Border.all(color: AgrisellColors.borderLine),
    boxShadow: [
      BoxShadow(
        color: AgrisellColors.brandBlack.withValues(alpha: 0.05),
        blurRadius: 6,
        offset: const Offset(0, 2),
      ),
    ],
  );

  static BoxDecoration containerDecoration(Color color) =>
      BoxDecoration(color: color, borderRadius: BorderRadius.circular(8));
}
