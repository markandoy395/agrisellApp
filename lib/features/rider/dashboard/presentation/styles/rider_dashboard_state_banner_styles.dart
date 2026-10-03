import 'package:flutter/material.dart';

import 'package:agresell_app/core/theme/agrisell_colors.dart';

abstract final class RiderDashboardStateBannerStyles {
  static final statsBannerDecoration = BoxDecoration(
    color: AgrisellColors.surface,
    borderRadius: BorderRadius.circular(12),
    border: Border.all(color: AgrisellColors.borderLine),
  );

  static const statsTitleStyle = TextStyle(
    color: AgrisellColors.headingGreen,
    fontSize: 14,
    height: 1.1,
    fontWeight: FontWeight.w900,
  );

  static final statsChipDecoration = BoxDecoration(
    color: AgrisellColors.homeBackground,
    borderRadius: BorderRadius.circular(10),
    border: Border.all(color: AgrisellColors.borderLine),
  );

  static const statsChipConstraints = BoxConstraints(minWidth: 92);

  static const statsValueStyle = TextStyle(
    color: AgrisellColors.headingGreen,
    fontSize: 13,
    height: 1.1,
    fontWeight: FontWeight.w900,
  );

  static const statsLabelStyle = TextStyle(
    color: AgrisellColors.mutedText,
    fontSize: 12,
    height: 1.1,
    fontWeight: FontWeight.w700,
  );
}
