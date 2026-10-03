import 'package:flutter/material.dart';
import 'package:agresell_app/core/theme/agrisell_colors.dart';

abstract final class CheckoutHeaderStyles {
  static final containerDecoration = BoxDecoration(
    color: AgrisellColors.authGreen,
    borderRadius: const BorderRadius.vertical(bottom: Radius.circular(22)),
    boxShadow: [
      BoxShadow(
        color: AgrisellColors.brandBlack.withValues(alpha: 0.16),
        blurRadius: 16,
        offset: const Offset(0, 6),
      ),
    ],
  );

  static const checkoutText = TextStyle(
    color: AgrisellColors.surface,
    fontSize: 15,
    height: 1,
    fontWeight: FontWeight.w800,
  );
}
