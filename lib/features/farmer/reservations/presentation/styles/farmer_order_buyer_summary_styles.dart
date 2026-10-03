import 'package:flutter/material.dart';
import 'package:agresell_app/core/theme/agrisell_colors.dart';

abstract final class FarmerOrderBuyerSummaryStyles {
  static final containerDecoration = BoxDecoration(
    color: AgrisellColors.forestSoft,
    borderRadius: BorderRadius.circular(12),
  );

  static const valueText = TextStyle(
    color: AgrisellColors.brandBlack,
    fontSize: 12,
    height: 1.25,
    fontWeight: FontWeight.w600,
  );
}
