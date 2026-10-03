import 'package:flutter/material.dart';
import 'package:agresell_app/core/theme/agrisell_colors.dart';

abstract final class FarmerRestockLotFieldsStyles {
  static ButtonStyle outlinedButtonStyle(String? errorText) =>
      OutlinedButton.styleFrom(
        alignment: Alignment.centerLeft,
        foregroundColor: AgrisellColors.authGreen,
        side: BorderSide(
          color: errorText == null
              ? AgrisellColors.borderLine
              : AgrisellColors.statusRedText,
        ),
      );

  static InputDecoration inputDecoration(String? hintText, String? errorText) =>
      InputDecoration(
        isDense: true,
        filled: true,
        fillColor: AgrisellColors.searchBackground,
        hintText: hintText,
        errorText: errorText,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
      );
}
