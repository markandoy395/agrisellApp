import 'package:flutter/material.dart';
import 'package:agresell_app/core/theme/agrisell_colors.dart';

abstract final class ReservedOrderCardStyles {
  static final decoratedBoxDecoration = BoxDecoration(
    color: AgrisellColors.surface,
    borderRadius: BorderRadius.circular(8),
    boxShadow: [
      BoxShadow(
        color: AgrisellColors.brandBlack.withValues(alpha: 0.08),
        blurRadius: 18,
        offset: const Offset(0, 8),
      ),
    ],
  );

  static const textStyle = TextStyle(
    color: AgrisellColors.brandBlack,
    fontSize: 12,
    height: 1.26,
    fontWeight: FontWeight.w500,
  );
}
