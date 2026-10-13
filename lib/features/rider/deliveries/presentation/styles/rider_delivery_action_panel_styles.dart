import 'package:flutter/material.dart';
import 'package:agresell_app/core/theme/agrisell_colors.dart';

abstract final class RiderDeliveryActionPanelStyles {
  static final filledButtonStyle = FilledButton.styleFrom(
    backgroundColor: AgrisellColors.authGreen,
    minimumSize: const Size(0, 48),
    maximumSize: Size.infinite,
    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
    textStyle: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700),
  );

  static final outlinedButtonStyle = OutlinedButton.styleFrom(
    foregroundColor: AgrisellColors.statusRedText,
    minimumSize: const Size(0, 48),
    maximumSize: Size.infinite,
    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
    side: const BorderSide(color: AgrisellColors.statusRedText),
    textStyle: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700),
  );
}
