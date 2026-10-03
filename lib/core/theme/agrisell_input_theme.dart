import 'package:flutter/material.dart';

import 'package:agresell_app/core/theme/agrisell_colors.dart';

abstract final class AgrisellInputTheme {
  static InputDecorationTheme buildInputDecorationTheme({
    required String fontFamily,
    required TextStyle floatingLabelStyle,
  }) {
    final border = OutlineInputBorder(
      borderRadius: BorderRadius.circular(8),
      borderSide: const BorderSide(color: AgrisellColors.borderLine),
    );

    return InputDecorationTheme(
      filled: true,
      fillColor: AgrisellColors.surface,
      border: border,
      enabledBorder: border,
      focusedBorder: border.copyWith(
        borderSide: const BorderSide(color: AgrisellColors.authGreen),
      ),
      labelStyle: TextStyle(
        color: AgrisellColors.mutedText,
        fontFamily: fontFamily,
      ),
      floatingLabelStyle: floatingLabelStyle,
      hintStyle: TextStyle(
        color: AgrisellColors.mutedText,
        fontFamily: fontFamily,
      ),
    );
  }
}
