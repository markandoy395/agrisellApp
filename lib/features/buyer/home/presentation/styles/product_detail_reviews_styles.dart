import 'package:flutter/material.dart';
import 'package:agresell_app/core/theme/agrisell_colors.dart';

abstract final class ProductDetailReviewsStyles {
  static final decoratedBoxDecoration = BoxDecoration(
    color: AgrisellColors.surface,
    borderRadius: BorderRadius.circular(14),
    boxShadow: [
      BoxShadow(
        color: AgrisellColors.brandBlack.withValues(alpha: 0.06),
        blurRadius: 14,
        offset: const Offset(0, 5),
      ),
    ],
  );

  static final containerDecoration = BoxDecoration(
    color: AgrisellColors.statusOrangeBackground,
    borderRadius: BorderRadius.circular(999),
  );

  static const textStyle = TextStyle(
    color: AgrisellColors.statusOrangeText,
    fontSize: 12,
    fontWeight: FontWeight.w800,
  );
}
