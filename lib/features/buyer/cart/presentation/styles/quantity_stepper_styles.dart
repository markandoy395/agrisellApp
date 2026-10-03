import 'package:flutter/material.dart';
import 'package:agresell_app/core/theme/agrisell_colors.dart';

abstract final class QuantityStepperStyles {
  static final decoratedBoxDecoration = BoxDecoration(
    color: AgrisellColors.forestSoft,
    borderRadius: BorderRadius.circular(22),
  );

  static const textStyle = TextStyle(
    color: AgrisellColors.brandBlack,
    fontSize: 13,
    height: 1,
    fontWeight: FontWeight.w600,
  );
}
