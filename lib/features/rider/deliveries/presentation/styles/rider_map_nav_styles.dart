import 'package:flutter/material.dart';
import 'package:agresell_app/core/theme/agrisell_colors.dart';
import 'package:agresell_app/core/theme/app_typography.dart';

abstract final class RiderMapNavStyles {
  static const bannerCard = BoxDecoration(
    color: AgrisellColors.authGreen,
    borderRadius: BorderRadius.all(Radius.circular(18)),
    boxShadow: [
      BoxShadow(
        color: AgrisellColors.shadowStrong,
        blurRadius: 10,
        offset: Offset(0, 4),
      ),
    ],
  );

  static final maneuverDistance = AppTypography.title.copyWith(
    color: AgrisellColors.surface,
    fontSize: 24,
    fontWeight: FontWeight.bold,
  );

  static final maneuverInstruction = AppTypography.body.copyWith(
    color: AgrisellColors.surface,
    fontSize: 14,
  );

  static final exitPillButton = TextButton.styleFrom(
    backgroundColor: AgrisellColors.statusRedBackground,
    foregroundColor: AgrisellColors.statusRedText,
    shape: const StadiumBorder(),
    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
    textStyle: const TextStyle(
      fontFamily: AppTypography.fontFamily,
      fontWeight: FontWeight.w600,
      fontSize: 13,
    ),
  );

  static final navigatePillButton = TextButton.styleFrom(
    backgroundColor: AgrisellColors.statusBlueBackground,
    foregroundColor: AgrisellColors.statusBlueText,
    shape: const StadiumBorder(),
    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
    textStyle: const TextStyle(
      fontFamily: AppTypography.fontFamily,
      fontWeight: FontWeight.w600,
      fontSize: 13,
    ),
  );

  static const nextAlertCard = BoxDecoration(
    color: AgrisellColors.statusBlueBackground,
    borderRadius: BorderRadius.all(Radius.circular(14)),
    border: Border.fromBorderSide(
      BorderSide(color: AgrisellColors.statusBlueBackground),
    ),
  );

  static const actionTile = BoxDecoration(
    color: AgrisellColors.surface,
    borderRadius: BorderRadius.all(Radius.circular(14)),
    border: Border.fromBorderSide(BorderSide(color: AgrisellColors.borderLine)),
    boxShadow: [
      BoxShadow(
        color: AgrisellColors.shadowLight,
        blurRadius: 4,
        offset: Offset(0, 2),
      ),
    ],
  );

  static const actionLabel = TextStyle(
    fontFamily: AppTypography.fontFamily,
    fontSize: 12,
    fontWeight: FontWeight.w500,
    color: AgrisellColors.brandBlack,
  );

  static const activeStepCircle = BoxDecoration(
    color: AgrisellColors.authGreen,
    shape: BoxShape.circle,
  );

  static const pendingStepCircle = BoxDecoration(
    color: AgrisellColors.searchBackground,
    shape: BoxShape.circle,
    border: Border.fromBorderSide(
      BorderSide(color: AgrisellColors.deliveryGray),
    ),
  );

  static const activeStepText = TextStyle(
    fontFamily: AppTypography.fontFamily,
    fontSize: 11,
    fontWeight: FontWeight.w600,
    color: AgrisellColors.authGreen,
  );

  static const inactiveStepText = TextStyle(
    fontFamily: AppTypography.fontFamily,
    fontSize: 11,
    color: AgrisellColors.mutedText,
  );
}
