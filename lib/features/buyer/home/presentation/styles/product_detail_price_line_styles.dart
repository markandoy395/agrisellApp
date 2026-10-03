import 'package:flutter/material.dart';
import 'package:agresell_app/core/theme/agrisell_colors.dart';

abstract final class ProductDetailPriceLineStyles {
  static final containerDecoration = BoxDecoration(
    color: AgrisellColors.authGreen,
    borderRadius: BorderRadius.circular(6),
  );

  static const saleText = TextStyle(
    color: AgrisellColors.surface,
    fontSize: 12,
    height: 1,
    fontWeight: FontWeight.w700,
    letterSpacing: 0.3,
  );

  static const textStyle = TextStyle(
    color: Colors.red,
    fontSize: 14,
    decoration: TextDecoration.lineThrough,
    decorationColor: Colors.red,
    fontWeight: FontWeight.w700,
  );

  static const textStyle2 = TextStyle(
    color: AgrisellColors.authGreen,
    fontSize: 15,
    height: 1,
    fontWeight: FontWeight.w800,
  );
}
