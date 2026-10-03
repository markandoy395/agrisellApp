import 'package:flutter/material.dart';

import 'package:agresell_app/core/theme/agrisell_colors.dart';

abstract final class FarmerShopStyles {
  static const backgroundColor = AgrisellColors.homeBackground;
  static const minHeaderHeight = 188.0;
  static const maxHeaderHeight = 226.0;
  static const headerHeightFactor = 0.28;
  static const profileOverlap = 28.0;
  static const contentSpacing = 6.0;

  static double headerHeight(Size size) =>
      (size.height * headerHeightFactor).clamp(
        minHeaderHeight,
        maxHeaderHeight,
      );

  static double profileHeight(double width) => width < 380 ? 84.0 : 78.0;

  static double profileTop(double headerHeight) =>
      headerHeight - profileOverlap;

  static double contentTop(double profileTop, double profileHeight) =>
      profileTop + profileHeight + contentSpacing;
}
