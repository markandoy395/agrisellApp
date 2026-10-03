import 'package:flutter/material.dart';

import 'package:agresell_app/core/theme/agrisell_colors.dart';

abstract final class OtpVerificationCodeStyles {
  static const codeSeparatorPadding = EdgeInsets.symmetric(horizontal: 10);

  static const codeSeparatorText = TextStyle(
    color: AgrisellColors.mutedText,
    fontSize: 15,
    fontWeight: FontWeight.w400,
  );

  static const hiddenCodeInput = InputDecoration(
    border: InputBorder.none,
    counterText: '',
  );

  static BoxDecoration codeGroupDecoration(
    Color borderColor,
    bool hasCurrentInGroup,
  ) => BoxDecoration(
    color: const Color(0xFFF9FAF9),
    borderRadius: BorderRadius.circular(10),
    border: Border.all(
      color: borderColor,
      width: hasCurrentInGroup ? 1.5 : 1.2,
    ),
  );

  static BoxDecoration cursorDecoration(Color accentColor) =>
      BoxDecoration(color: accentColor, borderRadius: BorderRadius.circular(1));

  static const digitText = TextStyle(
    color: AgrisellColors.headingGreen,
    fontSize: 15,
    fontWeight: FontWeight.w700,
  );

  static final resendRadius = BorderRadius.circular(8);

  static const resendPadding = EdgeInsets.symmetric(
    horizontal: 10,
    vertical: 6,
  );

  static BoxDecoration resendDecoration(Color accentColor, bool isEnabled) =>
      BoxDecoration(
        color: isEnabled
            ? AgrisellColors.forestSoft.withValues(alpha: 0.6)
            : AgrisellColors.searchBackground,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: isEnabled
              ? accentColor.withValues(alpha: 0.3)
              : AgrisellColors.borderLine,
          width: 1,
        ),
      );

  static TextStyle resendText(Color accentColor, bool isEnabled) => TextStyle(
    color: isEnabled ? accentColor : AgrisellColors.mutedText,
    fontSize: 12,
    fontWeight: FontWeight.w600,
  );
}
