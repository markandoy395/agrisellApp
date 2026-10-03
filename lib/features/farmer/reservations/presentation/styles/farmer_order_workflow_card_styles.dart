import 'package:flutter/material.dart';

import 'package:agresell_app/core/theme/agrisell_colors.dart';

abstract final class FarmerOrderWorkflowCardStyles {
  // Container & Card
  static final BoxDecoration cardDecoration = BoxDecoration(
    color: AgrisellColors.surface,
    borderRadius: BorderRadius.circular(16),
    boxShadow: [
      BoxShadow(
        color: AgrisellColors.brandBlack.withValues(alpha: 0.08),
        blurRadius: 14,
        offset: const Offset(0, 6),
      ),
    ],
  );

  static EdgeInsets cardPadding(double screenWidth) =>
      EdgeInsets.all(screenWidth < 380 ? 12 : 14);

  // Typography
  static const TextStyle orderIdStyle = TextStyle(
    color: AgrisellColors.mutedText,
    fontSize: 12,
    fontWeight: FontWeight.w700,
  );

  static const TextStyle itemTextStyle = TextStyle(
    color: AgrisellColors.brandBlack,
    fontSize: 12,
    fontWeight: FontWeight.w700,
  );

  static const TextStyle buttonTextStyle = TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.w800,
  );

  // Insets & Spacing
  static const EdgeInsets itemPadding = EdgeInsets.only(bottom: 5);
  static const Color dividerColor = AgrisellColors.borderLine;

  static const SizedBox spacingSmall = SizedBox(height: 7);
  static const SizedBox spacingMedium = SizedBox(height: 8);
  static const SizedBox spacingLarge = SizedBox(height: 9);

  // Button Styles
  static final ButtonStyle actionButtonStyle = FilledButton.styleFrom(
    backgroundColor: AgrisellColors.authGreen,
    foregroundColor: AgrisellColors.surface,
    padding: const EdgeInsets.symmetric(horizontal: 13),
    textStyle: buttonTextStyle,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(8),
    ),
  );

  static final ButtonStyle trackingButtonStyle = OutlinedButton.styleFrom(
    foregroundColor: AgrisellColors.authGreen,
    side: const BorderSide(color: AgrisellColors.authGreen),
    padding: const EdgeInsets.symmetric(horizontal: 13),
    textStyle: buttonTextStyle,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(8),
    ),
  );

  static final ButtonStyle cancelButtonStyle = OutlinedButton.styleFrom(
    foregroundColor: AgrisellColors.statusRedText,
    side: const BorderSide(color: AgrisellColors.statusRedText),
    padding: const EdgeInsets.symmetric(horizontal: 13),
    textStyle: buttonTextStyle,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(8),
    ),
  );

  static const double primaryButtonHeight = 40.0;
  static const double secondaryButtonHeight = 38.0;
}
