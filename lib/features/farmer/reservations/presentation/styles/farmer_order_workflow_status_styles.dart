import 'package:flutter/material.dart';
import 'package:agresell_app/core/theme/agrisell_colors.dart';

abstract final class FarmerOrderWorkflowStatusStyles {
  static final _containerDecorationActive = BoxDecoration(
    color: AgrisellColors.statusRedBackground,
    borderRadius: BorderRadius.circular(999),
  );
  static final _containerDecorationInactive = BoxDecoration(
    color: AgrisellColors.statusGreenBackground,
    borderRadius: BorderRadius.circular(999),
  );
  static BoxDecoration containerDecoration(bool isExpired) =>
      isExpired ? _containerDecorationActive : _containerDecorationInactive;

  static TextStyle labelText(Color color) =>
      TextStyle(color: color, fontSize: 12, fontWeight: FontWeight.w800);
}
