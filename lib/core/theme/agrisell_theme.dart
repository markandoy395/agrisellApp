import 'package:flutter/material.dart';

import 'package:agresell_app/core/theme/agrisell_button_themes.dart';
import 'package:agresell_app/core/theme/agrisell_colors.dart';
import 'package:agresell_app/core/theme/agrisell_component_themes.dart';
import 'package:agresell_app/core/theme/agrisell_input_theme.dart';
import 'package:agresell_app/core/theme/app_typography.dart';

abstract final class AgrisellTheme {
  static const String fontFamily = AppTypography.fontFamily;

  static const TextStyle floatingInputLabelStyle = TextStyle(
    color: AgrisellColors.authGreen,
    fontFamily: fontFamily,
    fontSize: 12,
    fontWeight: FontWeight.w600,
    height: 1.2,
  );

  static final ThemeData light = _buildLightTheme();

  static ThemeData _buildLightTheme() {
    final colorScheme = ColorScheme.fromSeed(
      seedColor: AgrisellColors.forestGreen,
      brightness: Brightness.light,
      primary: AgrisellColors.forestGreen,
      secondary: AgrisellColors.limeGreen,
      surface: AgrisellColors.surface,
      error: AgrisellColors.statusRedText,
    );
    final textTheme = _textTheme.apply(fontFamily: fontFamily);
    final inputDecoration = AgrisellInputTheme.buildInputDecorationTheme(
      fontFamily: fontFamily,
      floatingLabelStyle: floatingInputLabelStyle,
    );

    return ThemeData(
      useMaterial3: true,
      fontFamily: fontFamily,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: AgrisellColors.pageBackground,
      appBarTheme: const AppBarTheme(
        backgroundColor: AgrisellColors.forestGreen,
        foregroundColor: AgrisellColors.surface,
        elevation: 0,
        centerTitle: false,
      ),
      cardTheme: AgrisellComponentThemes.cardTheme,
      filledButtonTheme: AgrisellButtonThemes.filledButtonTheme,
      elevatedButtonTheme: AgrisellButtonThemes.elevatedButtonTheme,
      outlinedButtonTheme: AgrisellButtonThemes.outlinedButtonTheme,
      textButtonTheme: AgrisellButtonThemes.textButtonTheme,
      floatingActionButtonTheme:
          AgrisellButtonThemes.floatingActionButtonTheme,
      dialogTheme: AgrisellComponentThemes.dialogTheme,
      datePickerTheme: AgrisellComponentThemes.datePickerTheme(
        fontFamily: fontFamily,
        inputDecoration: inputDecoration,
      ),
      bottomSheetTheme: AgrisellComponentThemes.bottomSheetTheme,
      snackBarTheme: AgrisellComponentThemes.snackBarTheme(fontFamily),
      popupMenuTheme: AgrisellComponentThemes.popupMenuTheme(fontFamily),
      dropdownMenuTheme: AgrisellComponentThemes.dropdownMenuTheme(
        fontFamily: fontFamily,
        inputDecoration: inputDecoration,
      ),
      bannerTheme: AgrisellComponentThemes.bannerTheme(fontFamily),
      inputDecorationTheme: inputDecoration,
      textTheme: textTheme,
      primaryTextTheme: textTheme,
    );
  }

  static final TextTheme _textTheme = AppTypography.createTextTheme(
    displayColor: AgrisellColors.headingGreen,
    bodyColor: AgrisellColors.brandBlack,
  );
}
