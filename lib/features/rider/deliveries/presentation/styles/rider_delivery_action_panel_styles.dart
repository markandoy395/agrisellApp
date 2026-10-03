import 'package:flutter/material.dart';
import 'package:agresell_app/core/theme/agrisell_colors.dart';

abstract final class RiderDeliveryActionPanelStyles {
  static final filledButtonStyle = FilledButton.styleFrom(
    backgroundColor: AgrisellColors.authGreen,
    textStyle: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700),
  );

  static final outlinedButtonStyle = OutlinedButton.styleFrom(
    foregroundColor: AgrisellColors.statusRedText,
    side: const BorderSide(color: AgrisellColors.statusRedText),
    textStyle: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700),
  );
}
