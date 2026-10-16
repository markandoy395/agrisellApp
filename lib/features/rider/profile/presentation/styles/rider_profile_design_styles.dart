import 'package:flutter/material.dart';
import 'package:agresell_app/core/theme/agrisell_colors.dart';
import 'package:agresell_app/core/theme/app_typography.dart';

abstract final class RiderProfileDesignStyles {
  static const background = AgrisellColors.pageBackground;
  static const radius = BorderRadius.all(Radius.circular(20));
  static final title = AppTypography.title.copyWith(
    color: AgrisellColors.headingGreen,
    fontWeight: FontWeight.w700,
    fontSize: 17,
  );
  static final heading = title.copyWith(fontSize: 23);
  static final whiteHeading = heading.copyWith(color: AgrisellColors.surface);
  static final body = AppTypography.body.copyWith(
    color: AgrisellColors.headingGreen,
    height: 1.4,
  );
  static final muted = AppTypography.body.copyWith(
    color: AgrisellColors.mutedText,
    height: 1.4,
  );
  static final whiteSubtitle = muted.copyWith(
    color: AgrisellColors.surface.withValues(alpha: .85),
  );
  static final caption = AppTypography.caption.copyWith(
    color: AgrisellColors.mutedText,
  );
  static final value = title.copyWith(fontSize: 21);
  static final badgeText = AppTypography.caption.copyWith(
    color: AgrisellColors.authGreen,
    fontWeight: FontWeight.w600,
  );
  static const header = BoxDecoration(
    gradient: LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: [AgrisellColors.forestDark, AgrisellColors.authGreen],
    ),
  );
  static final card = BoxDecoration(
    color: AgrisellColors.surface,
    borderRadius: radius,
    border: Border.all(color: AgrisellColors.borderLine),
  );
  static final softCard = BoxDecoration(
    color: AgrisellColors.forestSoft,
    borderRadius: radius,
    border: Border.all(
      color: AgrisellColors.deliveryGreen.withValues(alpha: .3),
    ),
  );
  static BoxDecoration badge(Color color) => BoxDecoration(
    color: color.withValues(alpha: .13),
    borderRadius: BorderRadius.circular(10),
  );
  static final primary = FilledButton.styleFrom(
    minimumSize: const Size(64, 50),
    maximumSize: Size.infinite,
    backgroundColor: AgrisellColors.authGreen,
    foregroundColor: AgrisellColors.surface,
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
    textStyle: AppTypography.body.copyWith(fontWeight: FontWeight.w600),
    padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
  );
  static final secondary = OutlinedButton.styleFrom(
    minimumSize: const Size(64, 50),
    maximumSize: Size.infinite,
    foregroundColor: AgrisellColors.authGreen,
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
    side: const BorderSide(color: AgrisellColors.deliveryGreen),
    textStyle: AppTypography.body.copyWith(fontWeight: FontWeight.w600),
    padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
  );
  static final appBar = AppBarTheme(
    backgroundColor: AgrisellColors.surface,
    foregroundColor: AgrisellColors.headingGreen,
    elevation: 0,
    scrolledUnderElevation: 0,
    centerTitle: false,
    titleTextStyle: title,
    iconTheme: const IconThemeData(color: AgrisellColors.headingGreen),
  );
  static InputDecoration input(String label, {Widget? suffix}) =>
      InputDecoration(
        labelText: label,
        floatingLabelBehavior: FloatingLabelBehavior.auto,
        labelStyle: muted,
        suffixIcon: suffix,
        filled: true,
        fillColor: AgrisellColors.surface,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 16,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: AgrisellColors.borderLine),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: AgrisellColors.borderLine),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: AgrisellColors.authGreen),
        ),
      );
}
