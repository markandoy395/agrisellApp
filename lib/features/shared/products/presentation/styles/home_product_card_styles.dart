import 'package:flutter/material.dart';
import 'package:agresell_app/core/theme/agrisell_colors.dart';

abstract final class HomeProductCardStyles {
  static BoxDecoration decoratedBoxDecoration(BorderRadius borderRadius) =>
      BoxDecoration(
        color: AgrisellColors.surface,
        borderRadius: borderRadius,
        border: Border.all(color: AgrisellColors.borderLine),
        boxShadow: [
          BoxShadow(
            color: AgrisellColors.brandBlack.withValues(alpha: 0.05),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      );
}
