import 'package:flutter/material.dart';
import 'package:agresell_app/core/theme/agrisell_colors.dart';
import 'package:agresell_app/core/utils/responsive.dart';

abstract final class AuthCardStyles {
  static const containerDecoration = BoxDecoration(
    color: AgrisellColors.surface,
    borderRadius: BorderRadius.vertical(top: Radius.circular(46)),
  );

  static TextStyle titleText(bool largeTitle, double scale) => TextStyle(
    color: AgrisellColors.authGreen,
    fontSize: largeTitle ? 15 : lerpDouble(14, 15, scale),
    fontWeight: FontWeight.w700,
    height: 1.1,
  );
}
