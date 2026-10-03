import 'package:flutter/material.dart';
import 'package:agresell_app/core/theme/agrisell_colors.dart';

abstract final class ProductDetailBottomBarStyles {
  static final containerDecoration = BoxDecoration(
    color: AgrisellColors.surface,
    boxShadow: [
      BoxShadow(
        color: AgrisellColors.brandBlack.withValues(alpha: 0.09),
        blurRadius: 16,
        offset: const Offset(0, -4),
      ),
    ],
  );

  static final outlinedButtonStyle = OutlinedButton.styleFrom(
    foregroundColor: AgrisellColors.authGreen,
    padding: const EdgeInsets.symmetric(horizontal: 8),
    side: const BorderSide(color: AgrisellColors.authGreen),
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
    textStyle: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700),
  );

  static final filledButtonStyle = FilledButton.styleFrom(
    backgroundColor: AgrisellColors.authGreen,
    foregroundColor: AgrisellColors.surface,
    padding: const EdgeInsets.symmetric(horizontal: 12),
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
    textStyle: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700),
  );

  static final filledButtonStyle2 = FilledButton.styleFrom(
    disabledBackgroundColor: AgrisellColors.deliveryGray,
    disabledForegroundColor: AgrisellColors.mutedText,
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
  );
}
