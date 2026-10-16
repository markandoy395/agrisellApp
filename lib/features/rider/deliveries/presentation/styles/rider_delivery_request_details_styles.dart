import 'package:agresell_app/core/theme/app_typography.dart';
import 'package:flutter/material.dart';
import 'package:agresell_app/core/theme/agrisell_colors.dart';

abstract final class RiderDeliveryRequestDetailsStyles {
  static const textText = TextStyle(
    fontFamily: AppTypography.fontFamily,
    color: AgrisellColors.brandBlack,
    fontSize: 12,
    height: 1.2,
    fontWeight: FontWeight.w600,
  );

  static final containerDecoration = BoxDecoration(
    color: AgrisellColors.searchBackground,
    borderRadius: BorderRadius.circular(8),
  );
}
