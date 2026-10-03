import 'package:flutter/material.dart';
import 'package:agresell_app/core/theme/agrisell_colors.dart';

abstract final class RiderStateCardsStyles {
  static const titleText = TextStyle(
    color: AgrisellColors.headingGreen,
    fontSize: 15,
    fontWeight: FontWeight.w700,
  );

  static ButtonStyle outlinedButtonStyle(Color accentColor) =>
      OutlinedButton.styleFrom(
        foregroundColor: accentColor,
        side: BorderSide(color: accentColor),
        textStyle: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700),
      );

  static BoxDecoration containerDecoration(Color color) => BoxDecoration(
    color: color.withValues(alpha: 0.12),
    borderRadius: BorderRadius.circular(16),
  );
}
