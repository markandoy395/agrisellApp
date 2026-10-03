import 'package:flutter/material.dart';
import 'package:agresell_app/core/theme/agrisell_colors.dart';

abstract final class GcashPaymentNoticeStyles {
  static final containerDecoration = BoxDecoration(
    color: AgrisellColors.statusBlueBackground,
    borderRadius: BorderRadius.circular(10),
  );

  static const textStyle = TextStyle(
    color: AgrisellColors.statusBlueText,
    fontSize: 13,
    fontWeight: FontWeight.w800,
  );

  static final containerDecoration2 = BoxDecoration(
    color: AgrisellColors.forestSoft,
    borderRadius: BorderRadius.circular(12),
    border: Border.all(color: AgrisellColors.authGreen),
  );

  static final containerDecoration3 = BoxDecoration(
    color: AgrisellColors.statusOrangeBackground,
    borderRadius: BorderRadius.circular(10),
  );

  static const textStyle3 = TextStyle(
    color: AgrisellColors.statusOrangeText,
    fontSize: 12,
    height: 1.25,
    fontWeight: FontWeight.w600,
  );
}
