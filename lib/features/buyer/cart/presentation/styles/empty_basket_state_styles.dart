import 'package:flutter/material.dart';
import 'package:agresell_app/core/theme/agrisell_colors.dart';

abstract final class EmptyBasketStateStyles {
  static final containerDecoration = BoxDecoration(
    color: AgrisellColors.surface,
    borderRadius: BorderRadius.circular(8),
    boxShadow: [
      BoxShadow(
        color: AgrisellColors.brandBlack.withValues(alpha: 0.08),
        blurRadius: 14,
        offset: const Offset(0, 6),
      ),
    ],
  );

  static const yourBasketIsReadyForText = TextStyle(
    color: AgrisellColors.brandBlack,
    fontSize: 15,
    height: 1.15,
    fontWeight: FontWeight.w700,
  );

  static const textStyle = TextStyle(
    color: AgrisellColors.mutedText,
    fontSize: 12,
    height: 1.25,
    fontWeight: FontWeight.w500,
  );

  static final filledButtonStyle = FilledButton.styleFrom(
    backgroundColor: AgrisellColors.authGreen,
    foregroundColor: AgrisellColors.surface,
    padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
  );
}
