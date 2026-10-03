import 'package:flutter/material.dart';
import 'package:agresell_app/core/theme/agrisell_colors.dart';

abstract final class FarmerCardStyles {
  static BoxDecoration decoratedBoxDecoration(BorderRadius borderRadius) =>
      BoxDecoration(
        color: AgrisellColors.surface,
        borderRadius: borderRadius,
        boxShadow: [
          BoxShadow(
            color: AgrisellColors.brandBlack.withValues(alpha: 0.08),
            blurRadius: 14,
            offset: const Offset(0, 5),
          ),
        ],
      );
}
