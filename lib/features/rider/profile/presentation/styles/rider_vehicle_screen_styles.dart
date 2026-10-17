import 'package:flutter/material.dart';
import 'package:agresell_app/core/theme/agrisell_colors.dart';
import 'package:agresell_app/core/theme/app_typography.dart';
import 'rider_profile_design_styles.dart';

abstract final class RiderVehicleScreenStyles {
  static const sheetBackground = AgrisellColors.surface;
  static const sheetShape = RoundedRectangleBorder(
    borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
  );
  static final title = AppTypography.title.copyWith(
    color: AgrisellColors.headingGreen,
    fontSize: 18,
  );
  static final saveButton = RiderProfileDesignStyles.primary;
  static final cancelButton = RiderProfileDesignStyles.secondary;

  static InputDecoration inputDecoration(List<String> fieldLabels, int index) =>
      InputDecoration(labelText: fieldLabels[index]);
}
