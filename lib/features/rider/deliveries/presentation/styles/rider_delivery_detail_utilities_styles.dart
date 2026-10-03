import 'package:flutter/material.dart';
import 'package:agresell_app/core/theme/agrisell_colors.dart';

abstract final class RiderDeliveryDetailUtilitiesStyles {
  static final outlinedButtonStyle = OutlinedButton.styleFrom(
    foregroundColor: AgrisellColors.authGreen,
    side: const BorderSide(color: AgrisellColors.borderLine),
    minimumSize: const Size.fromHeight(38),
    textStyle: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700),
  );

  static InputDecoration inputDecoration(String label) =>
      InputDecoration(labelText: 'Enter the $label');

  static const textStyle = TextStyle(
    fontSize: 12,
    height: 1.35,
    fontWeight: FontWeight.w600,
  );
}
