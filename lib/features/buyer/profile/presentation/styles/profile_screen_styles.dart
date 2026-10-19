import 'package:flutter/material.dart';

import 'package:agresell_app/features/buyer/profile/presentation/widgets/buyer_profile_style.dart';

/// Predefined style constants and variants for the buyer profile screen.
abstract final class ProfileScreenStyles {
  // --- Insets & Clearances ---
  static const double sectionSpacing = 18.0;
  static const double sectionHeaderGap = 8.0;
  static const double headerSpacing = 14.0;
  static const double addressSpacing = 10.0;
  static const double iconTextGap = 14.0;
  static const double chevronGap = 8.0;
  static const double titleSubtitleGap = 2.0;

  static const EdgeInsets contentPadding = EdgeInsets.only(top: 16);
  static const EdgeInsets sectionHeaderPadding = EdgeInsets.only(left: 4);
  static const EdgeInsets tilePadding = EdgeInsets.symmetric(
    horizontal: 16,
    vertical: 14,
  );

  static double horizontalPadding(double width) => width < 380 ? 12.0 : 16.0;

  static double navClearance(BuildContext context) =>
      8.0 + MediaQuery.paddingOf(context).bottom;

  // --- Dimensions & Radii ---
  static const double iconBoxSize = 44.0;
  static const double iconSize = 22.0;
  static const double chevronSize = 22.0;
  static final BorderRadius tileRadius = BorderRadius.circular(18);
  static final BorderRadius iconBoxRadius = BorderRadius.circular(12);

  // --- Colors ---
  static const Color destructiveRed = Color(0xFFD63031);
  static const Color chevronNormal = Color(0xFFA0B8AF);
  static const Color destructiveBorder = Color(0xFFFFCCCC);
  static const Color normalDivider = Color(0xFFEEF3F0);
  static const Color sessionDivider = Color(0xFFEFF3F4);
  static final Color sheetBarrierColor = const Color(
    0xFF164A38,
  ).withValues(alpha: 0.18);

  // --- Bottom Sheet ---
  static const double sheetInitialChildSize = 0.79;
  static const double sheetMinChildSize = 0.45;
  static const double sheetMaxChildSize = 0.95;

  // --- Gradients ---
  static const LinearGradient destructiveGradient = LinearGradient(
    colors: [Color(0xFFFFF0F0), Color(0xFFFFE4E4)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient normalGradient = LinearGradient(
    colors: [Color(0xFFE8F5EE), Color(0xFFD1EDDF)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  // --- Style Variants ---
  static BoxDecoration iconBoxDecoration({required bool destructive}) =>
      BoxDecoration(
        gradient: destructive ? destructiveGradient : normalGradient,
        borderRadius: iconBoxRadius,
        border: Border.all(
          color: destructive
              ? destructiveBorder
              : BuyerProfileStyle.borderSubtle,
          width: 1,
        ),
      );

  static TextStyle tileTitleStyle({required bool destructive}) =>
      BuyerProfileStyle.tileTitle.copyWith(
        color: destructive ? destructiveRed : BuyerProfileStyle.ink,
      );

  static Color tileIconColor({required bool destructive}) =>
      destructive ? destructiveRed : BuyerProfileStyle.green;

  static Color chevronColor({required bool destructive}) =>
      destructive ? destructiveRed : chevronNormal;
}
