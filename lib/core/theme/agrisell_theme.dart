import 'package:flutter/material.dart';

import 'package:agresell_app/core/theme/agrisell_colors.dart';
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
          minimumSize: const Size(64, 38),
          maximumSize: const Size(double.infinity, 40),
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 0),
          textStyle: AppTypography.button,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          minimumSize: const Size(64, 38),
          maximumSize: const Size(double.infinity, 40),
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 0),
          textStyle: AppTypography.button,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          minimumSize: const Size(64, 38),
          maximumSize: const Size(double.infinity, 40),
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 0),
          textStyle: AppTypography.button,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          minimumSize: const Size(48, 38),
          maximumSize: const Size(double.infinity, 40),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 0),
          textStyle: AppTypography.button,
        ),
      ),
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        backgroundColor: AgrisellColors.forestGreen,
        foregroundColor: AgrisellColors.surface,
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: AgrisellColors.surface,
        surfaceTintColor: Colors.transparent,
        elevation: 12,
        shadowColor: const Color(0x2E0B0B0B),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        titleTextStyle: AppTypography.title.copyWith(
          color: AgrisellColors.headingGreen,
          fontSize: 15,
          fontWeight: FontWeight.w800,
        ),
        contentTextStyle: AppTypography.body.copyWith(
          color: AgrisellColors.brandBlack,
        ),
        actionsPadding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
      ),
      datePickerTheme: DatePickerThemeData(
        backgroundColor: AgrisellColors.surface,
        surfaceTintColor: Colors.transparent,
        elevation: 12,
        shadowColor: const Color(0x2E0B0B0B),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        headerBackgroundColor: AgrisellColors.forestGreen,
        headerForegroundColor: AgrisellColors.surface,
        headerHelpStyle: const TextStyle(
          color: AgrisellColors.surface,
          fontFamily: fontFamily,
          fontWeight: FontWeight.w600,
        ),
        headerHeadlineStyle: const TextStyle(
          color: AgrisellColors.surface,
          fontFamily: fontFamily,
          fontSize: 15,
          fontWeight: FontWeight.w800,
        ),
        weekdayStyle: const TextStyle(
          color: AgrisellColors.mutedText,
          fontFamily: fontFamily,
          fontWeight: FontWeight.w700,
        ),
        dayStyle: const TextStyle(
          color: AgrisellColors.headingGreen,
          fontFamily: fontFamily,
          fontWeight: FontWeight.w600,
        ),
        todayBorder: const BorderSide(color: AgrisellColors.authGreen),
        inputDecorationTheme: _inputDecoration,
        cancelButtonStyle: const ButtonStyle(
          foregroundColor: WidgetStatePropertyAll(AgrisellColors.authGreen),
        ),
        confirmButtonStyle: const ButtonStyle(
          foregroundColor: WidgetStatePropertyAll(AgrisellColors.authGreen),
        ),
      ),
      bottomSheetTheme: const BottomSheetThemeData(
        backgroundColor: AgrisellColors.surface,
        surfaceTintColor: Colors.transparent,
        modalBackgroundColor: AgrisellColors.surface,
        modalBarrierColor: Color(0x730B0B0B),
        elevation: 12,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        clipBehavior: Clip.antiAlias,
        showDragHandle: true,
        dragHandleColor: AgrisellColors.borderLine,
        dragHandleSize: Size(40, 4),
      ),
      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        backgroundColor: AgrisellColors.headingGreen,
        contentTextStyle: const TextStyle(
          color: AgrisellColors.surface,
          fontFamily: fontFamily,
          fontSize: 13,
          fontWeight: FontWeight.w600,
        ),
        elevation: 8,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        insetPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
      ),
      popupMenuTheme: PopupMenuThemeData(
        color: AgrisellColors.surface,
        surfaceTintColor: Colors.transparent,
        elevation: 8,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        textStyle: const TextStyle(
          color: AgrisellColors.headingGreen,
          fontFamily: fontFamily,
          fontSize: 13,
          fontWeight: FontWeight.w600,
        ),
      ),
      dropdownMenuTheme: DropdownMenuThemeData(
        textStyle: const TextStyle(
          color: AgrisellColors.headingGreen,
          fontFamily: fontFamily,
          fontSize: 14,
          fontWeight: FontWeight.w600,
        ),
        inputDecorationTheme: _inputDecoration,
        disabledColor: AgrisellColors.mutedText,
        menuStyle: MenuStyle(
          backgroundColor: const WidgetStatePropertyAll(AgrisellColors.surface),
          surfaceTintColor: const WidgetStatePropertyAll(Colors.transparent),
          elevation: const WidgetStatePropertyAll(8),
          padding: const WidgetStatePropertyAll(
            EdgeInsets.symmetric(vertical: 8),
          ),
          shape: WidgetStatePropertyAll(
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          ),
        ),
      ),
      bannerTheme: const MaterialBannerThemeData(
        backgroundColor: AgrisellColors.forestSoft,
        surfaceTintColor: Colors.transparent,
        dividerColor: AgrisellColors.borderLine,
        elevation: 0,
        padding: EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        leadingPadding: EdgeInsets.only(right: 12),
        contentTextStyle: TextStyle(
          color: AgrisellColors.headingGreen,
          fontFamily: fontFamily,
          fontSize: 13,
          fontWeight: FontWeight.w600,
          height: 1.35,
        ),
      ),
      inputDecorationTheme: _inputDecoration,
      textTheme: textTheme,
      primaryTextTheme: textTheme,
    );
  }

  static final TextTheme _textTheme = AppTypography.createTextTheme(
    displayColor: AgrisellColors.headingGreen,
    bodyColor: AgrisellColors.brandBlack,
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
      floatingLabelStyle: floatingInputLabelStyle,
      hintStyle: const TextStyle(
        color: AgrisellColors.mutedText,
        fontFamily: fontFamily,
      ),
    );
  }
}
