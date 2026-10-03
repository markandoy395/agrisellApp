import 'package:flutter/material.dart';

import 'package:agresell_app/core/theme/agrisell_colors.dart';

abstract final class FarmerHistoryScreenStyles {
  // App bar & Tabs
  static const appBarBackground = AgrisellColors.authGreen;
  static const appBarForeground = AgrisellColors.surface;
  static const tabIndicatorColor = AgrisellColors.surface;
  static const tabSelectedColor = AgrisellColors.surface;
  static const tabUnselectedColor = AgrisellColors.surface;
  static const tabSelectedStyle = TextStyle(
    fontSize: 13,
    fontWeight: FontWeight.w800,
  );
  static const tabUnselectedStyle = TextStyle(fontSize: 12);

  // Load failure
  static const errorTextStyle = TextStyle(
    color: AgrisellColors.mutedText,
    fontSize: 13,
  );

  // Reviews Banner
  static const reviewsBannerMargin = EdgeInsets.fromLTRB(14, 12, 14, 6);
  static const reviewsBannerPadding = EdgeInsets.symmetric(
    horizontal: 14,
    vertical: 12,
  );
  static const reviewsBannerBorderColor = Color(0xFFCDE4D7);
  static const reviewsBannerIconColor = AgrisellColors.accentOrange;
  static const reviewsBannerButtonBackground = Color(0xFFE8F5EE);

  static final reviewsBannerDecoration = BoxDecoration(
    color: AgrisellColors.surface,
    borderRadius: BorderRadius.circular(14),
    border: Border.all(color: reviewsBannerBorderColor),
    boxShadow: [
      BoxShadow(
        color: AgrisellColors.brandBlack.withValues(alpha: 0.04),
        blurRadius: 10,
        offset: const Offset(0, 3),
      ),
    ],
  );

  static const reviewsBannerTitleStyle = TextStyle(
    color: AgrisellColors.headingGreen,
    fontSize: 13,
    fontWeight: FontWeight.w800,
  );

  static const reviewsBannerSubtitleStyle = TextStyle(
    color: AgrisellColors.mutedText,
    fontSize: 12,
    fontWeight: FontWeight.w500,
  );

  static final reviewsBannerButtonStyle = FilledButton.styleFrom(
    backgroundColor: reviewsBannerButtonBackground,
    foregroundColor: AgrisellColors.authGreen,
    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(10),
    ),
  );

  static const reviewsBannerButtonTextStyle = TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.w700,
  );
}
