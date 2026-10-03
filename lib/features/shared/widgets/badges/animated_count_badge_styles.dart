import 'package:flutter/material.dart';
import 'package:agresell_app/core/theme/agrisell_colors.dart';

abstract final class AnimatedCountBadgeStyles {
  static BoxDecoration containerDecoration(
    Color backgroundColor,
    Color borderColor,
  ) => BoxDecoration(
    color: backgroundColor,
    borderRadius: BorderRadius.circular(9),
    border: Border.all(color: borderColor, width: 1.5),
    boxShadow: [
      BoxShadow(
        color: AgrisellColors.brandBlack.withValues(alpha: 0.16),
        blurRadius: 6,
        offset: const Offset(0, 2),
      ),
    ],
  );

  static TextStyle labelText(Color foregroundColor) => TextStyle(
    color: foregroundColor,
    fontSize: 12,
    height: 1,
    fontWeight: FontWeight.w700,
  );
}
