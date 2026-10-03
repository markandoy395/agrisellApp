import 'package:flutter/material.dart';
import 'package:agresell_app/core/theme/agrisell_colors.dart';

abstract final class ProductDetailRecommendationsStyles {
  static BoxDecoration containerDecoration(BorderRadius radius) =>
      BoxDecoration(
        borderRadius: radius,
        border: Border.all(color: AgrisellColors.borderLine),
      );

  static final containerDecoration2 = BoxDecoration(
    color: AgrisellColors.forestSoft,
    borderRadius: BorderRadius.circular(10),
  );

  static const availableText = TextStyle(
    color: AgrisellColors.authGreen,
    fontSize: 12,
    fontWeight: FontWeight.w600,
  );
}
