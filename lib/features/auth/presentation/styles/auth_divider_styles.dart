import 'package:flutter/material.dart';
import 'package:agresell_app/core/theme/agrisell_colors.dart';
import 'package:agresell_app/core/utils/responsive.dart';

abstract final class AuthDividerStyles {
  static TextStyle textText(double scale) => TextStyle(
    color: AgrisellColors.brandBlack,
    fontSize: lerpDouble(12, 14, scale),
    fontWeight: FontWeight.w400,
  );
}
