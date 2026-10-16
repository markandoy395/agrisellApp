import 'package:agresell_app/core/theme/app_typography.dart';
import 'package:flutter/material.dart';
import 'package:agresell_app/core/theme/agrisell_colors.dart';

abstract final class RiderCapacityEditorStyles {
  static const title = TextStyle(
    fontFamily: AppTypography.fontFamily,
    fontWeight: FontWeight.w700,
    color: AgrisellColors.headingGreen,
  );
  static InputDecoration decoration(String? error) => InputDecoration(
    labelText: 'Your cargo capacity (kg)',
    errorText: error,
    errorMaxLines: 3,
  );
  static final saveButton = FilledButton.styleFrom(
    minimumSize: const Size(0, 48),
    maximumSize: Size.infinite,
  );
}
