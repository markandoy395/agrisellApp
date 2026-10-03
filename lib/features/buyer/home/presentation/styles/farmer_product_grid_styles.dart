import 'package:flutter/material.dart';
import 'package:agresell_app/core/theme/agrisell_colors.dart';

abstract final class FarmerProductGridStyles {
  static final containerDecoration = BoxDecoration(
    color: AgrisellColors.surface,
    borderRadius: BorderRadius.circular(18),
    border: Border.all(color: AgrisellColors.borderLine),
  );

  static final outlinedButtonStyle = OutlinedButton.styleFrom(
    foregroundColor: AgrisellColors.authGreen,
    minimumSize: const Size(112, 38),
  );
}
