import 'package:flutter/material.dart';

abstract final class ProductSaleStatusBadgeStyles {
  static BoxDecoration containerDecoration(Color token_background) =>
      BoxDecoration(
        color: token_background,
        borderRadius: BorderRadius.circular(9),
      );

  static BoxDecoration containerDecoration2(Color token_background) =>
      BoxDecoration(
        color: token_background,
        borderRadius: BorderRadius.circular(10),
      );

  static TextStyle textStyle(Color token_foreground) => TextStyle(
    color: token_foreground,
    fontSize: 12,
    fontWeight: FontWeight.w700,
  );
}
