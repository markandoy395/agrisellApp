import 'package:flutter/material.dart';
import 'package:agresell_app/core/theme/agrisell_colors.dart';

abstract final class FarmerOrderInformationStyles {
  static final containerDecoration = BoxDecoration(
    color: AgrisellColors.surface,
    borderRadius: BorderRadius.circular(16),
    border: Border.all(color: AgrisellColors.borderLine),
  );

  static const textStyle = TextStyle(
    color: AgrisellColors.brandBlack,
    fontSize: 13,
    height: 1.3,
    fontWeight: FontWeight.w700,
  );
}
