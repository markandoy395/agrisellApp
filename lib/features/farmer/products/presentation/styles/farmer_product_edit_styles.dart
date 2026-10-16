import 'package:flutter/material.dart';

import 'package:agresell_app/core/theme/agrisell_colors.dart';

abstract final class FarmerProductEditStyles {
  static const backgroundColor = AgrisellColors.homeBackground;

  static final removeDialogConfirmButtonStyle = ElevatedButton.styleFrom(
    backgroundColor: AgrisellColors.statusRedText,
    foregroundColor: Colors.white,
  );

  static double calculateImageHeight(
    double screenWidth, {
    bool keyboardVisible = false,
    double availableHeight = double.infinity,
  }) {
    final normalHeight = (screenWidth * 0.84).clamp(292.0, 360.0);
    return keyboardVisible
        ? normalHeight.clamp(0.0, availableHeight * 0.4)
        : normalHeight;
  }

  static const panelOverlap = 28.0;
}
