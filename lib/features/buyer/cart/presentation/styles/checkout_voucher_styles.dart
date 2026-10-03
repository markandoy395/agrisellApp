import 'package:flutter/material.dart';

import 'package:agresell_app/core/theme/agrisell_colors.dart';

abstract final class CheckoutVoucherStyles {
  // Container Decorations
  static final BoxDecoration panelDecoration = BoxDecoration(
    color: AgrisellColors.surface,
    borderRadius: BorderRadius.circular(8),
    boxShadow: [
      BoxShadow(
        color: AgrisellColors.brandBlack.withValues(alpha: 0.08),
        blurRadius: 12,
        offset: const Offset(0, 5),
      ),
    ],
  );

  static final BoxDecoration iconContainerDecoration = BoxDecoration(
    color: AgrisellColors.forestSoft,
    borderRadius: BorderRadius.circular(6),
  );

  static final BoxDecoration appliedVoucherDecoration = BoxDecoration(
    color: AgrisellColors.forestSoft,
    borderRadius: BorderRadius.circular(8),
    border: Border.all(
      color: AgrisellColors.authGreen.withValues(alpha: 0.3),
    ),
  );

  static final BoxDecoration discountBadgeDecoration = BoxDecoration(
    color: AgrisellColors.authGreen,
    borderRadius: BorderRadius.circular(4),
  );

  // Paddings & Insets
  static const EdgeInsets panelPadding = EdgeInsets.all(12);
  static const EdgeInsets iconContainerPadding = EdgeInsets.all(6);
  static const EdgeInsets appliedVoucherPadding = EdgeInsets.symmetric(
    horizontal: 10,
    vertical: 8,
  );
  static const EdgeInsets discountBadgePadding = EdgeInsets.symmetric(
    horizontal: 5,
    vertical: 1,
  );
  static const EdgeInsets browseButtonPadding = EdgeInsets.symmetric(
    horizontal: 8,
  );
  static const EdgeInsets inputContentPadding = EdgeInsets.symmetric(
    horizontal: 10,
    vertical: 8,
  );
  static const EdgeInsets applyButtonPadding = EdgeInsets.symmetric(
    horizontal: 14,
  );

  // Text Styles
  static const TextStyle titleTextStyle = TextStyle(
    color: AgrisellColors.brandBlack,
    fontSize: 13,
    fontWeight: FontWeight.w700,
  );

  static const TextStyle subtitleTextStyle = TextStyle(
    color: AgrisellColors.mutedText,
    fontSize: 12,
  );

  static const TextStyle browseButtonTextStyle = TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.w700,
  );

  static const TextStyle appliedCodeTextStyle = TextStyle(
    color: AgrisellColors.brandBlack,
    fontSize: 13,
    fontWeight: FontWeight.w800,
    letterSpacing: 0.5,
  );

  static const TextStyle discountBadgeTextStyle = TextStyle(
    color: Colors.white,
    fontSize: 12,
    fontWeight: FontWeight.w700,
  );

  static const TextStyle discountSummaryTextStyle = TextStyle(
    color: AgrisellColors.authGreen,
    fontSize: 12,
    fontWeight: FontWeight.w600,
  );

  static const TextStyle inputTextStyle = TextStyle(
    fontSize: 13,
    fontWeight: FontWeight.w700,
    letterSpacing: 0.5,
  );

  static const TextStyle inputHintTextStyle = TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.w400,
    color: AgrisellColors.mutedText,
  );

  static const TextStyle applyButtonTextStyle = TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.w700,
  );

  static const TextStyle errorTextStyle = TextStyle(
    color: AgrisellColors.statusRedText,
    fontSize: 12,
    fontWeight: FontWeight.w500,
  );

  // Button Styles
  static final ButtonStyle browseButtonStyle = TextButton.styleFrom(
    foregroundColor: AgrisellColors.authGreen,
    visualDensity: VisualDensity.compact,
    padding: browseButtonPadding,
  );

  static final ButtonStyle applyButtonStyle = ElevatedButton.styleFrom(
    backgroundColor: AgrisellColors.authGreen,
    foregroundColor: Colors.white,
    padding: applyButtonPadding,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(6),
    ),
    elevation: 0,
  );

  // Input Field Styles
  static final OutlineInputBorder defaultInputBorder = OutlineInputBorder(
    borderRadius: BorderRadius.circular(6),
    borderSide: const BorderSide(color: AgrisellColors.borderLine),
  );

  static final OutlineInputBorder focusedInputBorder = OutlineInputBorder(
    borderRadius: BorderRadius.circular(6),
    borderSide: const BorderSide(
      color: AgrisellColors.authGreen,
      width: 1.5,
    ),
  );

  static InputDecoration inputDecoration({required String hintText}) =>
      InputDecoration(
        hintText: hintText,
        hintStyle: inputHintTextStyle,
        filled: true,
        fillColor: AgrisellColors.homeBackground,
        contentPadding: inputContentPadding,
        border: defaultInputBorder,
        enabledBorder: defaultInputBorder,
        focusedBorder: focusedInputBorder,
      );

  // Constraints & Dimensions
  static const double inputRowHeight = 38.0;
  static const BoxConstraints removeButtonConstraints = BoxConstraints(
    minWidth: 32,
    minHeight: 32,
  );
}
