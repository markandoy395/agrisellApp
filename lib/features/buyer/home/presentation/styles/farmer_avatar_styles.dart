import 'package:flutter/material.dart';
import 'package:agresell_app/core/theme/agrisell_colors.dart';

abstract final class FarmerAvatarStyles {
  static TextStyle textStyle(double size) => TextStyle(
    color: AgrisellColors.forestDark,
    fontSize: size < 50 ? 14 : 15,
    fontWeight: FontWeight.w700,
  );
}
