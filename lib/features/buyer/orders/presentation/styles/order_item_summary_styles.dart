import 'package:flutter/material.dart';
import 'package:agresell_app/core/theme/agrisell_colors.dart';

abstract final class OrderItemSummaryStyles {
  static const textStyle = TextStyle(
    color: AgrisellColors.brandBlack,
    fontSize: 14,
    height: 1.12,
    fontWeight: FontWeight.w800,
  );

  static final decoratedBoxDecoration = BoxDecoration(
    color: AgrisellColors.surface,
    borderRadius: BorderRadius.circular(8),
    border: Border.all(color: AgrisellColors.borderLine),
  );

  static const textStyle2 = TextStyle(
    color: AgrisellColors.brandBlack,
    fontSize: 12,
    height: 1,
    fontWeight: FontWeight.w600,
  );

  static final _containerDecorationActive = BoxDecoration(
    color: AgrisellColors.limeSoft,
    borderRadius: BorderRadius.circular(999),
  );
  static final _containerDecorationInactive = BoxDecoration(
    color: AgrisellColors.homeBackground,
    borderRadius: BorderRadius.circular(999),
  );
  static BoxDecoration containerDecoration(bool isPrimary) =>
      isPrimary ? _containerDecorationActive : _containerDecorationInactive;

  static final _labelTextActive = TextStyle(
    color: AgrisellColors.authGreen,
    fontSize: 12,
    height: 1,
    fontWeight: FontWeight.w700,
  );
  static final _labelTextInactive = TextStyle(
    color: AgrisellColors.brandBlack,
    fontSize: 12,
    height: 1,
    fontWeight: FontWeight.w700,
  );
  static TextStyle labelText(bool isPrimary) =>
      isPrimary ? _labelTextActive : _labelTextInactive;
}
