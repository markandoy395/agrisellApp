import 'package:flutter/material.dart';

import 'package:agresell_app/core/theme/agrisell_colors.dart';

abstract final class ProductDetailStyles {
  static const backgroundColor = AgrisellColors.pageBackground;
  static const imagePadding = EdgeInsets.symmetric(horizontal: 12);
  static const sectionPadding = EdgeInsets.fromLTRB(12, 12, 12, 0);
  static const bottomSpacerHeight = 24.0;
  static const minImageHeight = 210.0;
  static const maxImageHeight = 285.0;
  static const imageHeightFactor = 0.62;

  static double imageHeight(double width) =>
      (width * imageHeightFactor).clamp(minImageHeight, maxImageHeight);
}
