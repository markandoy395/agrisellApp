import 'package:flutter/material.dart';
import 'package:agresell_app/core/theme/agrisell_colors.dart';

abstract final class ProductDetailSellerCardStyles {
  static BoxDecoration containerDecoration(BorderRadius borderRadius) =>
      BoxDecoration(
        borderRadius: borderRadius,
        border: Border.all(color: AgrisellColors.borderLine),
      );

  static const textStyle = TextStyle(
    color: AgrisellColors.brandBlack,
    fontSize: 13,
    height: 1.05,
    fontWeight: FontWeight.w800,
  );

  static const textStyle2 = TextStyle(
    color: AgrisellColors.brandBlack,
    fontSize: 12,
    height: 1.05,
    fontWeight: FontWeight.w500,
  );
}
