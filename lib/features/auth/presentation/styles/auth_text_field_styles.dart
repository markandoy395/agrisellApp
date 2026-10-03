import 'package:flutter/material.dart';
import 'package:agresell_app/core/theme/agrisell_colors.dart';

abstract final class AuthTextFieldStyles {
  static TextStyle textStyle(double textSize) => TextStyle(
    color: AgrisellColors.brandBlack,
    fontSize: textSize,
    fontWeight: FontWeight.w400,
  );
}
