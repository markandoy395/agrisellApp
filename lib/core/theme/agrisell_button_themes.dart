import 'package:flutter/material.dart';

import 'package:agresell_app/core/theme/agrisell_colors.dart';
import 'package:agresell_app/core/theme/app_typography.dart';

abstract final class AgrisellButtonThemes {
  static FilledButtonThemeData get filledButtonTheme => FilledButtonThemeData(
    style: FilledButton.styleFrom(
      backgroundColor: AgrisellColors.primaryButton,
      foregroundColor: AgrisellColors.surface,
      minimumSize: const Size(64, 38),
      maximumSize: const Size(double.infinity, 40),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 0),
      textStyle: AppTypography.button,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
    ),
  );

  static ElevatedButtonThemeData get elevatedButtonTheme =>
      ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          minimumSize: const Size(64, 38),
          maximumSize: const Size(double.infinity, 40),
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 0),
          textStyle: AppTypography.button,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
      );

  static OutlinedButtonThemeData get outlinedButtonTheme =>
      OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          minimumSize: const Size(64, 38),
          maximumSize: const Size(double.infinity, 40),
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 0),
          textStyle: AppTypography.button,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
      );

  static TextButtonThemeData get textButtonTheme => TextButtonThemeData(
    style: TextButton.styleFrom(
      minimumSize: const Size(48, 38),
      // Selection toolbar buttons require at least 48px of height.
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 0),
      textStyle: AppTypography.button,
    ),
  );

  static const FloatingActionButtonThemeData floatingActionButtonTheme =
      FloatingActionButtonThemeData(
        backgroundColor: AgrisellColors.forestGreen,
        foregroundColor: AgrisellColors.surface,
      );
}
