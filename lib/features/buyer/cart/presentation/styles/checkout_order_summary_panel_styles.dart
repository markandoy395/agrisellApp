import 'package:flutter/material.dart';
import 'package:agresell_app/core/theme/agrisell_colors.dart';

abstract final class CheckoutOrderSummaryPanelStyles {
  static final decoratedBoxDecoration = BoxDecoration(
    color: AgrisellColors.surface,
    borderRadius: BorderRadius.circular(8),
    boxShadow: [
      BoxShadow(
        color: AgrisellColors.brandBlack.withValues(alpha: 0.08),
        blurRadius: 12,
        offset: const Offset(0, 5),
      ),
    ],
  );

  static final containerDecoration = BoxDecoration(
    color: AgrisellColors.forestSoft,
    borderRadius: BorderRadius.circular(6),
  );

  static const orderSummaryDiscountsText = TextStyle(
    color: AgrisellColors.brandBlack,
    fontSize: 13,
    fontWeight: FontWeight.w700,
  );

  static final containerDecoration2 = BoxDecoration(
    color: AgrisellColors.forestSoft,
    borderRadius: BorderRadius.circular(6),
    border: Border.all(color: AgrisellColors.authGreen.withValues(alpha: 0.2)),
  );

  static const textStyle = TextStyle(
    color: AgrisellColors.authGreen,
    fontSize: 12,
    fontWeight: FontWeight.w700,
  );

  static final _labelTextActive = TextStyle(
    color: AgrisellColors.brandBlack,
    fontSize: 13,
    fontWeight: FontWeight.w800,
  );
  static final _labelTextInactive = TextStyle(
    color: AgrisellColors.mutedText,
    fontSize: 12,
    fontWeight: FontWeight.w500,
  );
  static TextStyle labelText(bool isTotal) =>
      isTotal ? _labelTextActive : _labelTextInactive;

  static TextStyle valueText(Color? valueColor, bool isTotal) => TextStyle(
    color:
        valueColor ??
        (isTotal ? AgrisellColors.authGreen : AgrisellColors.brandBlack),
    fontSize: isTotal ? 16 : 12,
    fontWeight: isTotal ? FontWeight.w800 : FontWeight.w600,
  );
}
