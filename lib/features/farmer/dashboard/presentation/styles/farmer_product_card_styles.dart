import 'package:flutter/material.dart';
import 'package:agresell_app/core/theme/agrisell_colors.dart';

abstract final class FarmerProductCardStyles {
  static BoxDecoration decoratedBoxDecoration(BorderRadius radius) =>
      BoxDecoration(
        color: AgrisellColors.surface,
        borderRadius: radius,
        border: Border.all(color: AgrisellColors.borderLine),
        boxShadow: [
          BoxShadow(
            color: AgrisellColors.brandBlack.withValues(alpha: 0.05),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      );

  static final decoratedBoxDecoration2 = BoxDecoration(
    color: AgrisellColors.surface.withValues(alpha: 0.94),
    borderRadius: BorderRadius.circular(6),
    border: Border.all(color: AgrisellColors.borderLine),
  );

  static const labelText = TextStyle(
    color: AgrisellColors.headingGreen,
    fontSize: 12,
    height: 1,
    fontWeight: FontWeight.w700,
  );

  static final decoratedBoxDecoration3 = BoxDecoration(
    color: AgrisellColors.statusRedText,
    borderRadius: BorderRadius.circular(6),
    boxShadow: [
      BoxShadow(
        color: Colors.black.withValues(alpha: 0.15),
        blurRadius: 4,
        offset: const Offset(0, 1),
      ),
    ],
  );

  static const labelText2 = TextStyle(
    color: Colors.white,
    fontSize: 12,
    height: 1,
    fontWeight: FontWeight.w700,
    letterSpacing: 0.3,
  );
}
