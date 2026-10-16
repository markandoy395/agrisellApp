import 'package:agresell_app/core/theme/app_typography.dart';
import 'package:flutter/material.dart';

import 'package:agresell_app/core/theme/agrisell_colors.dart';
import 'rider_home_design_styles.dart';

abstract final class RiderDashboardContentStyles {
  static const EdgeInsets cardPadding = EdgeInsets.symmetric(
    horizontal: 14,
    vertical: 12,
  );

  static final BoxDecoration safetyIconDecoration = BoxDecoration(
    color: AgrisellColors.statusGreenBackground,
    borderRadius: BorderRadius.circular(12),
  );

  static const TextStyle safetyTitleStyle = RiderHomeDesignStyles.title;

  static const TextStyle safetySubtitleStyle = RiderHomeDesignStyles.caption;

  static final BoxDecoration earningsIconDecoration = BoxDecoration(
    color: AgrisellColors.limeSoft,
    borderRadius: BorderRadius.circular(12),
  );

  static const TextStyle earningsAmountStyle = TextStyle(
    fontFamily: AppTypography.fontFamily,
    color: AgrisellColors.headingGreen,
    fontSize: 15,
    height: 1.1,
    fontWeight: FontWeight.w800,
  );

  static const TextStyle earningsLabelStyle = TextStyle(
    fontFamily: AppTypography.fontFamily,
    color: AgrisellColors.mutedText,
    fontSize: 12,
    height: 1.1,
    fontWeight: FontWeight.w600,
  );

  static const TextStyle earningsPendingStyle = TextStyle(
    fontFamily: AppTypography.fontFamily,
    color: AgrisellColors.mutedText,
    fontSize: 12,
    height: 1.1,
    fontWeight: FontWeight.w700,
  );
}
