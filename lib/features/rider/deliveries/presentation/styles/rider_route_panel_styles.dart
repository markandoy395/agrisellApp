import 'package:agresell_app/core/theme/app_typography.dart';
import 'package:flutter/material.dart';

import 'package:agresell_app/core/theme/agrisell_colors.dart';

/// Styling constants and text styles for the rider route panel.
abstract final class RiderRoutePanelStyles {
  // Text Styles
  static const TextStyle metricsTitle = TextStyle(
    fontFamily: AppTypography.fontFamily,
    color: AgrisellColors.headingGreen,
    fontSize: 12,
    fontWeight: FontWeight.w700,
  );

  static const TextStyle dropdownText = TextStyle(
    fontFamily: AppTypography.fontFamily,
    fontSize: 12,
  );

  static const TextStyle progressPercent = TextStyle(
    fontFamily: AppTypography.fontFamily,
    color: AgrisellColors.mutedText,
    fontSize: 12,
    fontWeight: FontWeight.w700,
  );

  static const TextStyle destinationText = TextStyle(
    fontFamily: AppTypography.fontFamily,
    color: AgrisellColors.mutedText,
    fontSize: 12,
    height: 1.3,
  );

  static const TextStyle maneuverInstruction = TextStyle(
    fontFamily: AppTypography.fontFamily,
    color: AgrisellColors.headingGreen,
    fontSize: 13,
    fontWeight: FontWeight.w800,
  );

  static const TextStyle maneuverDistance = TextStyle(
    fontFamily: AppTypography.fontFamily,
    color: AgrisellColors.headingGreen,
    fontSize: 12,
    fontWeight: FontWeight.w800,
  );

  static const TextStyle statusText = TextStyle(
    fontFamily: AppTypography.fontFamily,
    color: AgrisellColors.mutedText,
    fontSize: 12,
  );

  static const TextStyle routeStatusText = TextStyle(
    fontFamily: AppTypography.fontFamily,
    color: AgrisellColors.mutedText,
    fontSize: 12,
  );

  // Next Maneuver Card Decoration & Padding
  static final BoxDecoration maneuverDecoration = BoxDecoration(
    color: AgrisellColors.forestSoft,
    borderRadius: BorderRadius.circular(10),
  );

  static const EdgeInsets maneuverPadding = EdgeInsets.symmetric(
    horizontal: 9,
    vertical: 7,
  );

  // Status & Metrics Padding
  static const EdgeInsets statusPadding = EdgeInsets.only(top: 4);

  // Progress Bar
  static const double progressMinHeight = 4.0;
  static final BorderRadius progressBorderRadius = BorderRadius.circular(4);
  static final Color progressBackground = AgrisellColors.authGreen.withValues(
    alpha: 0.14,
  );

  // Spacing & Icon Dimensions
  static const double maneuverItemSpacing = 8.0;
  static const double gpsSpacing = 4.0;
  static const double gpsIconSize = 14.0;
  static const double settingsIconSize = 18.0;
}
