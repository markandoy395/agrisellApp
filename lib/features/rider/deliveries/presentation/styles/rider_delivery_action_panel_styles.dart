import 'package:agresell_app/core/theme/app_typography.dart';
import 'package:flutter/material.dart';
import 'package:agresell_app/core/theme/agrisell_colors.dart';

abstract final class RiderDeliveryActionPanelStyles {
  static final filledButtonStyle = FilledButton.styleFrom(
    backgroundColor: AgrisellColors.authGreen,
    foregroundColor: AgrisellColors.surface,
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    minimumSize: const Size(0, 48),
    maximumSize: Size.infinite,
    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
    textStyle: const TextStyle(
      fontFamily: AppTypography.fontFamily,
      fontSize: 12,
      fontWeight: FontWeight.w700,
    ),
  );

  static final outlinedButtonStyle = OutlinedButton.styleFrom(
    foregroundColor: AgrisellColors.statusRedText,
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    minimumSize: const Size(0, 48),
    maximumSize: Size.infinite,
    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
    side: const BorderSide(color: AgrisellColors.statusRedText),
    textStyle: const TextStyle(
      fontFamily: AppTypography.fontFamily,
      fontSize: 12,
      fontWeight: FontWeight.w700,
    ),
  );
}
