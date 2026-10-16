import 'package:agresell_app/core/theme/app_typography.dart';
import 'package:flutter/material.dart';
import 'package:agresell_app/core/theme/agrisell_colors.dart';

abstract final class RiderBatchDeliverySummaryStyles {
  static const textStyle = TextStyle(
    fontFamily: AppTypography.fontFamily,
    color: AgrisellColors.headingGreenAlt,
    fontSize: 12,
  );

  static const textStyle2 = TextStyle(
    fontFamily: AppTypography.fontFamily,
    color: AgrisellColors.headingGreenAlt,
    fontSize: 12,
    fontWeight: FontWeight.w700,
  );

  static const textStyle3 = TextStyle(
    fontFamily: AppTypography.fontFamily,
    color: AgrisellColors.headingGreenAlt,
    fontSize: 12,
    fontWeight: FontWeight.w600,
  );
}
