import 'package:flutter/material.dart';
import 'package:agresell_app/core/theme/agrisell_colors.dart';

abstract final class FarmerOrderPaymentPanelStyles {
  static BoxDecoration containerDecoration(
    ({Color background, Color foreground}) colors,
  ) => BoxDecoration(
    color: colors.background,
    borderRadius: BorderRadius.circular(10),
    border: Border.all(color: colors.foreground.withValues(alpha: 0.3)),
  );

  static TextStyle textStyle(({Color background, Color foreground}) colors) =>
      TextStyle(
        color: colors.foreground,
        fontSize: 13,
        fontWeight: FontWeight.w800,
      );

  static TextStyle textStyle2(({Color background, Color foreground}) colors) =>
      TextStyle(
        color: colors.foreground,
        fontSize: 12,
        fontWeight: FontWeight.w600,
      );

  static final filledButtonStyle = FilledButton.styleFrom(
    backgroundColor: AgrisellColors.authGreen,
    padding: const EdgeInsets.symmetric(horizontal: 11),
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
  );

  static final filledButtonStyle2 = FilledButton.styleFrom(
    backgroundColor: AgrisellColors.statusPurpleText,
    padding: const EdgeInsets.symmetric(horizontal: 11),
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
  );
}
