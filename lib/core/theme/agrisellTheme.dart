import 'package:flutter/material.dart';

import 'package:agresell_app/core/theme/agrisellColors.dart';

abstract final class AgrisellTheme {
  static const String fontFamily = 'Poppins';

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
      cardTheme: CardThemeData(
        color: AgrisellColors.surface,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
          side: const BorderSide(color: AgrisellColors.borderLine),
        ),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: AgrisellColors.primaryButton,
          foregroundColor: AgrisellColors.surface,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
      ),
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        backgroundColor: AgrisellColors.forestGreen,
        foregroundColor: AgrisellColors.surface,
      ),
      inputDecorationTheme: _inputDecoration,
      textTheme: textTheme,
      primaryTextTheme: textTheme,
    );
  }

  static const TextTheme _textTheme = TextTheme(
    headlineLarge: TextStyle(
      color: AgrisellColors.headingGreen,
      fontWeight: FontWeight.w700,
    ),
    headlineMedium: TextStyle(
      color: AgrisellColors.headingGreen,
      fontWeight: FontWeight.w700,
    ),
    titleLarge: TextStyle(
      color: AgrisellColors.headingGreen,
      fontWeight: FontWeight.w700,
    ),
    bodyMedium: TextStyle(color: AgrisellColors.brandBlack),
    bodySmall: TextStyle(color: AgrisellColors.mutedText),
  );

  static final InputDecorationTheme _inputDecoration =
      _buildInputDecorationTheme();

  static InputDecorationTheme _buildInputDecorationTheme() {
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
      labelStyle: const TextStyle(
        color: AgrisellColors.mutedText,
        fontFamily: fontFamily,
      ),
      floatingLabelStyle: const TextStyle(
        color: AgrisellColors.authGreen,
        fontFamily: fontFamily,
      ),
      hintStyle: const TextStyle(
        color: AgrisellColors.mutedText,
        fontFamily: fontFamily,
      ),
    );
  }
}
