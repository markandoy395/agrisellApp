import 'package:flutter/material.dart';

import 'package:agresell_app/core/theme/agrisell_colors.dart';

abstract final class FarmerProductEditStyles {
  static const backgroundColor = AgrisellColors.homeBackground;

  static final removeDialogConfirmButtonStyle = ElevatedButton.styleFrom(
    backgroundColor: AgrisellColors.statusRedText,
    foregroundColor: Colors.white,
  );

  static double calculateImageHeight(double screenWidth) =>
      (screenWidth * 0.84).clamp(292.0, 360.0);

  static const panelOverlap = 28.0;
}
