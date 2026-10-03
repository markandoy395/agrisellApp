import 'package:flutter/material.dart';
import 'package:agresell_app/core/theme/agrisell_colors.dart';

abstract final class FarmerSoldStatusOverlayStyles {
  static final decoratedBoxDecoration = BoxDecoration(
    gradient: LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: [
        AgrisellColors.brandBlack.withValues(alpha: 0.46),
        AgrisellColors.brandBlack.withValues(alpha: 0.12),
      ],
    ),
  );

  static final decoratedBoxDecoration2 = BoxDecoration(
    color: AgrisellColors.statusRedBackground,
    borderRadius: BorderRadius.circular(16),
    border: Border.all(
      color: AgrisellColors.statusRedText.withValues(alpha: 0.22),
    ),
    boxShadow: [
      BoxShadow(
        color: AgrisellColors.brandBlack.withValues(alpha: 0.16),
        blurRadius: 8,
        offset: const Offset(0, 3),
      ),
    ],
  );

  static const soldText = TextStyle(
    color: AgrisellColors.statusRedText,
    fontSize: 12,
    height: 1,
    fontWeight: FontWeight.w800,
  );
}
