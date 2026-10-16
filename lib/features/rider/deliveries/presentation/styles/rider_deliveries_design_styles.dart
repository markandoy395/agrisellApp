import 'package:flutter/material.dart';
import 'package:agresell_app/core/theme/agrisell_colors.dart';
import 'package:agresell_app/core/theme/app_typography.dart';

abstract final class RiderDeliveriesDesignStyles {
  static const title = TextStyle(
    fontFamily: AppTypography.fontFamily,
    fontSize: 15,
    fontWeight: FontWeight.w800,
    color: AgrisellColors.headingGreen,
  );
  static const body = AppTypography.body;
  static final caption = AppTypography.caption.copyWith(
    color: AgrisellColors.mutedText,
  );
  static final label = AppTypography.caption.copyWith(
    color: AgrisellColors.headingGreen,
    fontWeight: FontWeight.w600,
  );
  static final earning = AppTypography.subtitle.copyWith(
    color: AgrisellColors.authGreen,
  );
  static final distance = AppTypography.caption.copyWith(
    color: AgrisellColors.statusBlueText,
    fontWeight: FontWeight.w600,
  );
  static final card = BoxDecoration(
    color: AgrisellColors.surface,
    borderRadius: BorderRadius.circular(16),
    border: Border.all(color: AgrisellColors.borderLine),
  );
  static final inset = BoxDecoration(
    color: AgrisellColors.forestSoft,
    borderRadius: BorderRadius.circular(12),
  );
  static const header = BoxDecoration(
    gradient: LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: [AgrisellColors.forestSoft, AgrisellColors.surface],
    ),
  );
  static final primary = FilledButton.styleFrom(
    backgroundColor: AgrisellColors.authGreen,
    foregroundColor: AgrisellColors.surface,
    minimumSize: const Size(0, 44),
    maximumSize: Size.infinite,
    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
    textStyle: AppTypography.button,
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
  );
  static final secondary = OutlinedButton.styleFrom(
    foregroundColor: AgrisellColors.authGreen,
    minimumSize: const Size(0, 44),
    maximumSize: Size.infinite,
    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
    side: const BorderSide(color: AgrisellColors.authGreen),
    textStyle: AppTypography.button,
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
  );
  static final iconButton = IconButton.styleFrom(
    backgroundColor: AgrisellColors.searchBackground,
    foregroundColor: AgrisellColors.headingGreen,
    minimumSize: const Size(44, 44),
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
  );
  static InputDecoration input(String hint, {Widget? prefix, Widget? suffix}) =>
      InputDecoration(
        hintText: hint,
        hintStyle: caption,
        prefixIcon: prefix,
        suffixIcon: suffix,
        filled: true,
        fillColor: AgrisellColors.searchBackground,
        isDense: true,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 14,
          vertical: 14,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
      );
}
