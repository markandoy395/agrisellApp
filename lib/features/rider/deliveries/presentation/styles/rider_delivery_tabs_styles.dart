import 'package:agresell_app/core/theme/app_typography.dart';
import 'package:flutter/material.dart';
import 'package:agresell_app/core/theme/agrisell_colors.dart';

abstract final class RiderDeliveryTabsStyles {
  static final filledButtonStyle = FilledButton.styleFrom(
    backgroundColor: AgrisellColors.authGreen,
    minimumSize: const Size.fromHeight(38),
    textStyle: const TextStyle(
      fontFamily: AppTypography.fontFamily,
      fontSize: 12,
      fontWeight: FontWeight.w700,
    ),
  );
}
