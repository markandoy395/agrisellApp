import 'package:flutter/material.dart';

import 'package:agresell_app/core/theme/agrisell_colors.dart';

/// Predefined styles, dimensions, paddings, and layout rules for the Farmer Dashboard.
abstract final class FarmerDashboardStyles {
  // Colors
  static const Color backgroundColor = AgrisellColors.homeBackground;

  // Responsive Dimensions
  static double horizontalPadding(double width) => width < 380 ? 12.0 : 14.0;
  static double gridSpacing(double width) => width < 380 ? 9.0 : 11.0;
  static double productRatio(double width) => width < 380 ? 0.72 : 0.75;
  static double navClearance(double bottomPadding) => 148.0 + bottomPadding;

  // Spacing & Offsets
  static const double tabsTopSpacing = 14.0;
  static const double contentTopSpacing = 10.0;
  static const double loadingTopSpacing = 32.0;
  static const int gridCrossAxisCount = 2;

  // Paddings
  static EdgeInsets tabsPadding(double horizontalPadding) =>
      EdgeInsets.fromLTRB(horizontalPadding, tabsTopSpacing, horizontalPadding, 0);

  static EdgeInsets contentPadding(double horizontalPadding) =>
      EdgeInsets.fromLTRB(horizontalPadding, contentTopSpacing, horizontalPadding, 0);

  static const EdgeInsets loadingPadding = EdgeInsets.only(top: loadingTopSpacing);

  // Grid Delegates
  static SliverGridDelegateWithFixedCrossAxisCount gridDelegate({
    required double gridSpacing,
    required double productRatio,
  }) =>
      SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: gridCrossAxisCount,
        crossAxisSpacing: gridSpacing,
        mainAxisSpacing: gridSpacing + 2,
        childAspectRatio: productRatio,
      );
}
