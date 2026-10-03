import 'package:flutter/material.dart';
import 'package:agresell_app/core/theme/agrisell_colors.dart';

abstract final class FarmerShopTabsStyles {
  static const containerDecoration = BoxDecoration(
    color: AgrisellColors.surface,
    border: Border(bottom: BorderSide(color: AgrisellColors.borderLine)),
  );

  static TextStyle labelText(Color textColor) => TextStyle(
    color: textColor,
    fontSize: 13,
    height: 1,
    fontWeight: FontWeight.w700,
  );
}
