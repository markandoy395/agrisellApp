import 'package:flutter/material.dart';
import 'package:agresell_app/core/theme/agrisell_colors.dart';
import 'package:agresell_app/features/farmer/products/presentation/controllers/add_product_draft.dart';

abstract final class AddProductAvailabilityFieldsStyles {
  static ButtonStyle outlinedButtonStyle(Map<AddProductField, String> errors) =>
      OutlinedButton.styleFrom(
        alignment: Alignment.centerLeft,
        foregroundColor: AgrisellColors.authGreen,
        side: BorderSide(
          color: errors.containsKey(AddProductField.harvestDate)
              ? AgrisellColors.statusRedText
              : AgrisellColors.borderLine,
        ),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      );

  static TextStyle textStyle(Map<AddProductField, String> errors) => TextStyle(
    color: errors.containsKey(AddProductField.harvestDate)
        ? AgrisellColors.statusRedText
        : AgrisellColors.mutedText,
    fontSize: 12,
    height: 1.25,
  );
}
