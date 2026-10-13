import 'package:flutter/material.dart';

import 'package:agresell_app/core/theme/agrisell_colors.dart';
import 'package:agresell_app/core/theme/app_typography.dart';

abstract final class AgrisellComponentThemes {
  static CardThemeData get cardTheme => CardThemeData(
    color: AgrisellColors.surface,
    elevation: 0,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(8),
      side: const BorderSide(color: AgrisellColors.borderLine),
    ),
  );

  static DialogThemeData get dialogTheme => DialogThemeData(
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
  );

  static DatePickerThemeData datePickerTheme({
    required String fontFamily,
    required InputDecorationTheme inputDecoration,
  }) => DatePickerThemeData(
    backgroundColor: AgrisellColors.surface,
    surfaceTintColor: Colors.transparent,
    elevation: 12,
    shadowColor: const Color(0x2E0B0B0B),
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
    headerBackgroundColor: AgrisellColors.forestGreen,
    headerForegroundColor: AgrisellColors.surface,
    headerHelpStyle: TextStyle(
      color: AgrisellColors.surface,
      fontFamily: fontFamily,
      fontWeight: FontWeight.w600,
    ),
    headerHeadlineStyle: TextStyle(
      color: AgrisellColors.surface,
      fontFamily: fontFamily,
      fontSize: 15,
      fontWeight: FontWeight.w800,
    ),
    weekdayStyle: TextStyle(
      color: AgrisellColors.mutedText,
      fontFamily: fontFamily,
      fontWeight: FontWeight.w700,
    ),
    dayStyle: TextStyle(
      color: AgrisellColors.headingGreen,
      fontFamily: fontFamily,
      fontWeight: FontWeight.w600,
    ),
    todayBorder: const BorderSide(color: AgrisellColors.authGreen),
    inputDecorationTheme: inputDecoration,
    cancelButtonStyle: const ButtonStyle(
      foregroundColor: WidgetStatePropertyAll(AgrisellColors.authGreen),
    ),
    confirmButtonStyle: const ButtonStyle(
      foregroundColor: WidgetStatePropertyAll(AgrisellColors.authGreen),
    ),
  );

  static const BottomSheetThemeData bottomSheetTheme = BottomSheetThemeData(
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
  );

  static SnackBarThemeData snackBarTheme(String fontFamily) =>
      SnackBarThemeData(
        behavior: SnackBarBehavior.fixed,
        backgroundColor: AgrisellColors.headingGreen,
        contentTextStyle: TextStyle(
          color: AgrisellColors.surface,
          fontFamily: fontFamily,
          fontSize: 13,
          fontWeight: FontWeight.w600,
        ),
        elevation: 8,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        insetPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
      );

  static PopupMenuThemeData popupMenuTheme(String fontFamily) =>
      PopupMenuThemeData(
        color: AgrisellColors.surface,
        surfaceTintColor: Colors.transparent,
        elevation: 8,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        textStyle: TextStyle(
          color: AgrisellColors.headingGreen,
          fontFamily: fontFamily,
          fontSize: 13,
          fontWeight: FontWeight.w600,
        ),
      );

  static DropdownMenuThemeData dropdownMenuTheme({
    required String fontFamily,
    required InputDecorationTheme inputDecoration,
  }) => DropdownMenuThemeData(
    textStyle: TextStyle(
      color: AgrisellColors.headingGreen,
      fontFamily: fontFamily,
      fontSize: 14,
      fontWeight: FontWeight.w600,
    ),
    inputDecorationTheme: inputDecoration,
    disabledColor: AgrisellColors.mutedText,
    menuStyle: MenuStyle(
      backgroundColor: const WidgetStatePropertyAll(AgrisellColors.surface),
      surfaceTintColor: const WidgetStatePropertyAll(Colors.transparent),
      elevation: const WidgetStatePropertyAll(8),
      padding: const WidgetStatePropertyAll(EdgeInsets.symmetric(vertical: 8)),
      shape: WidgetStatePropertyAll(
        RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
    ),
  );

  static MaterialBannerThemeData bannerTheme(String fontFamily) =>
      MaterialBannerThemeData(
        backgroundColor: AgrisellColors.forestSoft,
        surfaceTintColor: Colors.transparent,
        dividerColor: AgrisellColors.borderLine,
        elevation: 0,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        leadingPadding: const EdgeInsets.only(right: 12),
        contentTextStyle: TextStyle(
          color: AgrisellColors.headingGreen,
          fontFamily: fontFamily,
          fontSize: 13,
          fontWeight: FontWeight.w600,
          height: 1.35,
        ),
      );
}
