import 'package:flutter/material.dart';
import 'package:agresell_app/core/theme/agrisell_colors.dart';
import 'package:agresell_app/core/utils/responsive.dart';

abstract final class AuthCheckboxStyles {
  static TextStyle textStyle(TextStyle baseStyle) =>
      baseStyle.copyWith(fontSize: 12);

  static const textStyle2 = TextStyle(color: AgrisellColors.authGreen);

  static TextStyle textStyle3(double scale) => TextStyle(
    color: AgrisellColors.brandBlack,
    fontSize: lerpDouble(12, 14, scale),
    fontWeight: FontWeight.w400,
  );
}
