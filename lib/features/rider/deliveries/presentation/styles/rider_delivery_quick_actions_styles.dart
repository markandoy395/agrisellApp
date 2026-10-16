import 'package:agresell_app/core/theme/app_typography.dart';
import 'package:flutter/material.dart';
import 'package:agresell_app/core/theme/agrisell_colors.dart';

abstract final class RiderDeliveryQuickActionsStyles {
  static final outlinedButtonStyle = OutlinedButton.styleFrom(
    foregroundColor: AgrisellColors.authGreen,
    side: const BorderSide(color: AgrisellColors.borderLine),
    minimumSize: const Size(0, 56),
    maximumSize: Size.infinite,
    padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
    textStyle: const TextStyle(
      fontFamily: AppTypography.fontFamily,
      fontSize: 12,
      fontWeight: FontWeight.w700,
    ),
  );
}
