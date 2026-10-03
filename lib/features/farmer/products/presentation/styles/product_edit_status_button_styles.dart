import 'package:flutter/material.dart';
import 'package:agresell_app/core/theme/agrisell_colors.dart';

abstract final class ProductEditStatusButtonStyles {
  static ButtonStyle outlinedButtonStyle(bool isSold, Color red) =>
      OutlinedButton.styleFrom(
        backgroundColor: isSold ? red : AgrisellColors.surface,
        foregroundColor: isSold ? AgrisellColors.surface : red,
        side: BorderSide(color: red, width: 1.8),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        padding: const EdgeInsets.symmetric(horizontal: 12),
        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
      );

  static const textStyle = TextStyle(
    fontSize: 15,
    height: 1,
    fontWeight: FontWeight.w700,
  );
}
