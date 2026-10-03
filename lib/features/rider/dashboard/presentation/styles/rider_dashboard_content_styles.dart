import 'package:flutter/material.dart';

import 'package:agresell_app/core/theme/agrisell_colors.dart';

abstract final class RiderDashboardContentStyles {
  static const EdgeInsets cardPadding =
      EdgeInsets.symmetric(horizontal: 14, vertical: 12);

  static final BoxDecoration safetyIconDecoration = BoxDecoration(
    color: AgrisellColors.statusBlueBackground,
    borderRadius: BorderRadius.circular(12),
  );

  static const TextStyle safetyTitleStyle = TextStyle(
    color: AgrisellColors.headingGreen,
    fontSize: 13,
    fontWeight: FontWeight.w800,
  );

  static const TextStyle safetySubtitleStyle = TextStyle(
    color: AgrisellColors.mutedText,
    fontSize: 12,
    height: 1.25,
    fontWeight: FontWeight.w600,
  );

  static final BoxDecoration earningsIconDecoration = BoxDecoration(
    color: AgrisellColors.limeSoft,
    borderRadius: BorderRadius.circular(12),
  );

  static const TextStyle earningsAmountStyle = TextStyle(
    color: AgrisellColors.headingGreen,
    fontSize: 15,
    height: 1.1,
    fontWeight: FontWeight.w900,
  );

  static const TextStyle earningsLabelStyle = TextStyle(
    color: AgrisellColors.mutedText,
    fontSize: 12,
    height: 1.1,
    fontWeight: FontWeight.w600,
  );

  static const TextStyle earningsPendingStyle = TextStyle(
    color: AgrisellColors.mutedText,
    fontSize: 12,
    height: 1.1,
    fontWeight: FontWeight.w700,
  );
}
