import 'package:flutter/material.dart';

import 'package:agresell_app/core/theme/agrisell_colors.dart';

abstract final class FarmerVerificationFormStyles {
  static const existingImageColor = AgrisellColors.authGreen;
  static const missingImageColor = AgrisellColors.mutedText;
  static final _inputBorder = OutlineInputBorder(
    borderRadius: BorderRadius.circular(10),
    borderSide: const BorderSide(color: AgrisellColors.borderLine),
  );
  static final _focusedBorder = OutlineInputBorder(
    borderRadius: BorderRadius.circular(10),
    borderSide: const BorderSide(color: AgrisellColors.authGreen, width: 1.5),
  );
  static final formPanel = BoxDecoration(
    color: AgrisellColors.surface,
    borderRadius: BorderRadius.circular(16),
    border: Border.all(color: AgrisellColors.borderLine),
  );
  static final emptyUpload = _uploadPanel(AgrisellColors.borderLine, 1);
  static final existingUpload = _uploadPanel(AgrisellColors.authGreen, 1.5);
  static final notesInput = InputDecoration(
    hintText: 'Explain the corrections you made...',
    hintStyle: const TextStyle(fontSize: 13, color: AgrisellColors.mutedText),
    filled: true,
    fillColor: AgrisellColors.homeBackground,
    border: _inputBorder,
    enabledBorder: _inputBorder,
    focusedBorder: _focusedBorder,
  );

  static InputDecoration profileInput(Widget prefixIcon) => InputDecoration(
    prefixIcon: prefixIcon,
    filled: true,
    fillColor: AgrisellColors.homeBackground,
    contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
    border: _inputBorder,
    enabledBorder: _inputBorder,
    focusedBorder: _focusedBorder,
  );

  static BoxDecoration _uploadPanel(Color border, double width) =>
      BoxDecoration(
        color: AgrisellColors.homeBackground,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: border, width: width),
      );
}
