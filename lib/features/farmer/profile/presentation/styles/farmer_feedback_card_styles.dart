import 'package:flutter/material.dart';
import 'package:agresell_app/core/theme/agrisell_colors.dart';

abstract final class FarmerFeedbackCardStyles {
  static final decoratedBoxDecoration = BoxDecoration(
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

  static const textStyle2 = TextStyle(
    color: AgrisellColors.brandBlack,
    fontSize: 12,
    height: 1.35,
  );
}
