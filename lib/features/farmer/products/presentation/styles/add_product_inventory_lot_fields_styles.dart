import 'package:flutter/material.dart';
import 'package:agresell_app/core/theme/agrisell_colors.dart';

abstract final class AddProductInventoryLotFieldsStyles {
  static ButtonStyle outlinedButtonStyle(String? errorText) =>
      OutlinedButton.styleFrom(
        alignment: Alignment.centerLeft,
        foregroundColor: AgrisellColors.authGreen,
        side: BorderSide(
          color: errorText == null
              ? AgrisellColors.borderLine
              : AgrisellColors.statusRedText,
        ),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      );
}
