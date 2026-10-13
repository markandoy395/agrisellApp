import 'package:flutter/material.dart';
import 'package:agresell_app/core/theme/agrisell_colors.dart';
import 'farmer_restock_dialog_styles.dart';

abstract final class FarmerRestockLotFieldsStyles {
  static const guidanceStyle = TextStyle(
    color: AgrisellColors.mutedText,
    fontSize: 12,
    height: 1.4,
  );
  static const dropdownTextStyle = TextStyle(
    color: AgrisellColors.headingGreen,
    fontSize: 16,
    fontWeight: FontWeight.w700,
  );
  static ButtonStyle outlinedButtonStyle(String? errorText) =>
      OutlinedButton.styleFrom(
        alignment: Alignment.centerLeft,
        foregroundColor: AgrisellColors.authGreen,
        backgroundColor: AgrisellColors.surface,
        minimumSize: const Size(0, 46),
        maximumSize: Size.infinite,
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(9)),
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
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 14,
        ),
        hintText: hintText,
        hintStyle: FarmerRestockDialogStyles.headerSubtitleStyle,
        errorText: errorText,
        border: FarmerRestockDialogStyles.fieldBorder,
        enabledBorder: FarmerRestockDialogStyles.fieldBorder,
        focusedBorder: FarmerRestockDialogStyles.fieldFocusedBorder,
      );
}
