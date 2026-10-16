import 'package:agresell_app/core/theme/agrisell_colors.dart';
import 'package:agresell_app/core/theme/app_typography.dart';
import 'package:flutter/material.dart';

abstract final class RiderHomeDesignStyles {
  static const green = AgrisellColors.authGreen;
  static const ink = AgrisellColors.brandBlack;
  static const muted = AgrisellColors.mutedText;
  static const red = AgrisellColors.unavailableRed;
  static const background = AgrisellColors.homeBackground;
  static const headerBackground = BoxDecoration(
    gradient: LinearGradient(
      colors: [AgrisellColors.forestGreen, AgrisellColors.authGreen],
    ),
  );
  static const header = BoxDecoration(
    gradient: LinearGradient(
      colors: [AgrisellColors.forestGreen, AgrisellColors.authGreen],
    ),
    borderRadius: BorderRadius.vertical(bottom: Radius.circular(24)),
  );
  static final card = BoxDecoration(
    color: AgrisellColors.surface,
    borderRadius: BorderRadius.circular(18),
    border: Border.all(color: AgrisellColors.borderLine),
    boxShadow: [
      BoxShadow(
        color: AgrisellColors.brandBlack.withValues(alpha: 0.04),
        blurRadius: 12,
      ),
    ],
  );
  static BoxDecoration earnings(bool online) => BoxDecoration(
    color: online ? AgrisellColors.forestSoft : AgrisellColors.pageBackground,
    borderRadius: BorderRadius.circular(16),
    border: Border.all(
      color: online ? AgrisellColors.forestSoft : AgrisellColors.borderLine,
    ),
  );
  static BoxDecoration status(bool online) => BoxDecoration(
    color: online ? AgrisellColors.limeSoft : AgrisellColors.deliveryGray,
    borderRadius: BorderRadius.circular(12),
  );
  static const badge = BoxDecoration(color: red, shape: BoxShape.circle);
  static const title = TextStyle(
    fontFamily: AppTypography.fontFamily,
    fontSize: 14,
    fontWeight: FontWeight.w700,
    color: ink,
  );
  static const greeting = TextStyle(
    fontFamily: AppTypography.fontFamily,
    fontSize: 19,
    fontWeight: FontWeight.w700,
    color: AgrisellColors.surface,
  );
  static const whiteCaption = TextStyle(
    fontFamily: AppTypography.fontFamily,
    fontSize: 11,
    color: AgrisellColors.surface,
  );
  static const statusText = TextStyle(
    fontFamily: AppTypography.fontFamily,
    fontSize: 11,
    fontWeight: FontWeight.w700,
    color: ink,
  );
  static const caption = TextStyle(
    fontFamily: AppTypography.fontFamily,
    fontSize: 12,
    color: muted,
    height: 1.4,
    fontWeight: FontWeight.w400,
  );
  static const body = TextStyle(
    fontFamily: AppTypography.fontFamily,
    fontSize: 12,
    color: ink,
    height: 1.4,
    fontWeight: FontWeight.w400,
  );
  static const amount = TextStyle(
    fontFamily: AppTypography.fontFamily,
    fontSize: 20,
    fontWeight: FontWeight.w700,
    color: ink,
  );
  static const metric = TextStyle(
    fontFamily: AppTypography.fontFamily,
    fontSize: 20,
    fontWeight: FontWeight.w700,
    color: ink,
  );
  static const metricLabel = TextStyle(
    fontFamily: AppTypography.fontFamily,
    fontSize: 10,
    color: muted,
  );
  static const badgeText = TextStyle(
    fontFamily: AppTypography.fontFamily,
    fontSize: 10,
    color: AgrisellColors.surface,
    fontWeight: FontWeight.w700,
  );
  static final primaryButton = FilledButton.styleFrom(
    textStyle: AppTypography.button,
    backgroundColor: green,
    foregroundColor: AgrisellColors.surface,
    minimumSize: const Size(0, 46),
    // Override the app theme's 40px cap; allow enlarged labels to grow.
    maximumSize: Size.infinite,
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
  );
  static final secondaryButton = TextButton.styleFrom(
    textStyle: AppTypography.button,
    backgroundColor: AgrisellColors.forestSoft,
    foregroundColor: green,
    minimumSize: const Size(0, 42),
    maximumSize: Size.infinite,
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
  );
  static final illustration = BoxDecoration(
    color: AgrisellColors.pageBackground,
    borderRadius: BorderRadius.circular(90),
  );
}
