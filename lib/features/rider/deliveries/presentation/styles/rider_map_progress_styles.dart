import 'package:flutter/material.dart';
import 'package:agresell_app/core/theme/agrisell_colors.dart';
import 'package:agresell_app/core/theme/app_typography.dart';

abstract final class RiderMapProgressStyles {
  static BoxDecoration milestone(bool reached) => BoxDecoration(
    color: reached ? AgrisellColors.authGreen : AgrisellColors.searchBackground,
    shape: BoxShape.circle,
    border: Border.all(
      color: reached ? AgrisellColors.authGreen : AgrisellColors.deliveryGray,
    ),
  );
  static TextStyle label(bool reached) => AppTypography.caption.copyWith(
    fontWeight: reached ? FontWeight.w600 : FontWeight.w400,
    color: reached ? AgrisellColors.authGreen : AgrisellColors.mutedText,
  );
  static final nextAction = AppTypography.button.copyWith(
    color: AgrisellColors.statusBlueText,
  );
  static const exitCircle = BoxDecoration(
    color: AgrisellColors.surfaceOverlay,
    shape: BoxShape.circle,
  );
  static const radar = BoxDecoration(
    color: AgrisellColors.routeRadar,
    shape: BoxShape.circle,
  );
  static const poiCircle = BoxDecoration(
    color: AgrisellColors.statusBlueBackground,
    shape: BoxShape.circle,
  );
}
