import 'package:flutter/material.dart';
import 'package:agresell_app/core/theme/agrisell_colors.dart';

abstract final class HomeProductCardDetailsStyles {
  static const containerDecoration = BoxDecoration(
    color: AgrisellColors.surface,
  );

  static final textStyle = TextStyle(
    color: AgrisellColors.brandBlack,
    fontSize: 14,
    height: 1.1,
    fontWeight: FontWeight.w700,
  );

  static final _valueTextActive = TextStyle(
    color: AgrisellColors.mutedText,
    fontSize: 12,
    height: 1,
    fontWeight: FontWeight.w700,
  );
  static final _valueTextInactive = TextStyle(
    color: AgrisellColors.mutedText,
    fontSize: 12,
    height: 1,
    fontWeight: FontWeight.w500,
  );
  static TextStyle valueText(bool emphasis) =>
      emphasis ? _valueTextActive : _valueTextInactive;

  static const textStyle2 = TextStyle(
    color: AgrisellColors.authGreen,
    fontSize: 14,
    height: 1.05,
    fontWeight: FontWeight.w700,
  );
}
