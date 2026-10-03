import 'package:flutter/material.dart';

import 'package:agresell_app/core/theme/agrisell_colors.dart';

abstract final class FarmerReserveStyles {
  // Colors
  static const Color backgroundColor = AgrisellColors.homeBackground;
  static const Color loadingIconColor = AgrisellColors.headingGreen;
  static const Color emptyIconColor = AgrisellColors.authGreen;

  // Paddings & Dimensions
  static double horizontalPadding(double screenWidth) =>
      screenWidth < 380 ? 12.0 : 14.0;

  static double navClearance(BuildContext context) =>
      154.0 + MediaQuery.paddingOf(context).bottom;

  static const EdgeInsets errorPadding = EdgeInsets.all(28);
  static const EdgeInsets emptyPadding = EdgeInsets.fromLTRB(24, 34, 24, 24);

  static const SizedBox orderItemSpacing = SizedBox(height: 14);
  static const SizedBox spacingSmall = SizedBox(height: 5);
  static const SizedBox spacingMedium = SizedBox(height: 10);
  static const SizedBox spacingLarge = SizedBox(height: 12);

  // Typography
  static const TextStyle loadingTitleStyle = TextStyle(
    color: AgrisellColors.headingGreen,
    fontSize: 13,
    fontWeight: FontWeight.w700,
  );

  static const TextStyle errorTitleStyle = TextStyle(
    color: AgrisellColors.headingGreen,
    fontSize: 14,
    fontWeight: FontWeight.w800,
  );

  static const TextStyle errorSubtitleStyle = TextStyle(
    color: AgrisellColors.mutedText,
    fontSize: 12,
  );

  static const TextStyle emptyTitleStyle = TextStyle(
    color: AgrisellColors.headingGreen,
    fontSize: 14,
    fontWeight: FontWeight.w800,
  );

  static const TextStyle emptySubtitleStyle = TextStyle(
    color: AgrisellColors.mutedText,
    fontSize: 12,
  );
}
