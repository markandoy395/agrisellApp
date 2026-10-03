import 'package:flutter/material.dart';
import 'package:agresell_app/core/theme/agrisell_colors.dart';

abstract final class GcashReferenceRetrySheetStyles {
  static final containerDecoration = BoxDecoration(
    color: AgrisellColors.statusRedBackground,
    borderRadius: BorderRadius.circular(10),
  );

  static const textStyle = TextStyle(
    color: AgrisellColors.statusRedText,
    fontSize: 12,
    height: 1.3,
  );

  static final inputDecoration = InputDecoration(
    labelText: 'New GCash reference number',
    helperText: 'Enter the 13-digit number from your receipt.',
    helperMaxLines: 2,
    prefixIcon: const Icon(Icons.receipt_long_outlined, size: 19),
    filled: true,
    fillColor: AgrisellColors.searchBackground,
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(10),
      borderSide: BorderSide.none,
    ),
  );
}
