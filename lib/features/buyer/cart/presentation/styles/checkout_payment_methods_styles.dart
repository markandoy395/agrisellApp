import 'package:flutter/material.dart';
import 'package:agresell_app/core/theme/agrisell_colors.dart';

abstract final class CheckoutPaymentMethodsStyles {
  static final decoratedBoxDecoration = BoxDecoration(
    color: AgrisellColors.surface,
    borderRadius: BorderRadius.circular(12),
    boxShadow: [
      BoxShadow(
        color: AgrisellColors.brandBlack.withValues(alpha: 0.07),
        blurRadius: 14,
        offset: const Offset(0, 5),
      ),
    ],
  );

  static final _containerDecorationActive = BoxDecoration(
    color: AgrisellColors.authGreen,
    borderRadius: BorderRadius.circular(9),
  );
  static final _containerDecorationInactive = BoxDecoration(
    color: AgrisellColors.searchBackground,
    borderRadius: BorderRadius.circular(9),
  );
  static BoxDecoration containerDecoration(bool selected) =>
      selected ? _containerDecorationActive : _containerDecorationInactive;

  static const subtitleText = TextStyle(
    color: AgrisellColors.mutedText,
    fontSize: 12,
    height: 1.2,
  );
}
