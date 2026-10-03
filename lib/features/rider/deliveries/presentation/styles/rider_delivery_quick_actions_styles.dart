import 'package:flutter/material.dart';
import 'package:agresell_app/core/theme/agrisell_colors.dart';

abstract final class RiderDeliveryQuickActionsStyles {
  static final outlinedButtonStyle = OutlinedButton.styleFrom(
    foregroundColor: AgrisellColors.authGreen,
    side: const BorderSide(color: AgrisellColors.borderLine),
    padding: const EdgeInsets.symmetric(horizontal: 2),
    textStyle: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700),
  );
}
