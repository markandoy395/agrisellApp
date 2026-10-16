import 'package:agresell_app/core/theme/app_typography.dart';
import 'package:flutter/material.dart';
import 'package:agresell_app/core/theme/agrisell_colors.dart';

abstract final class RiderCapacitySetupBannerStyles {
  static const padding = EdgeInsets.all(14);
  static const title = TextStyle(
    fontFamily: AppTypography.fontFamily,
    fontSize: 15,
    fontWeight: FontWeight.w700,
    color: AgrisellColors.headingGreen,
  );
  static final decoration = BoxDecoration(
    color: AgrisellColors.forestSoft,
    borderRadius: BorderRadius.circular(14),
    border: Border.all(color: AgrisellColors.borderLine),
  );
  static final button = FilledButton.styleFrom(
    minimumSize: const Size(0, 48),
    maximumSize: Size.infinite,
  );
}
