import 'package:flutter/material.dart';
import 'package:agresell_app/core/theme/agrisell_colors.dart';

abstract final class FarmerGcashRefundSheetStyles {
  static final containerDecoration = BoxDecoration(
    color: AgrisellColors.statusPurpleBackground,
    borderRadius: BorderRadius.circular(10),
  );

  static const textStyle = TextStyle(
    color: AgrisellColors.statusPurpleText,
    fontSize: 13,
    fontWeight: FontWeight.w900,
  );

  static InputDecoration inputDecoration(String? value1) => InputDecoration(
    labelText: 'Refund transaction reference',
    hintText: 'Reference from the refund receipt',
    errorText: value1,
    prefixIcon: const Icon(Icons.receipt_long_outlined, size: 19),
    filled: true,
    fillColor: AgrisellColors.searchBackground,
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(10),
      borderSide: BorderSide.none,
    ),
  );

  static final filledButtonStyle = FilledButton.styleFrom(
    backgroundColor: AgrisellColors.statusPurpleText,
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
  );
}
