import 'package:flutter/material.dart';
import 'package:agresell_app/core/theme/agrisell_colors.dart';

abstract final class CheckoutVoucherPickerSheetStyles {
  static const containerDecoration = BoxDecoration(
    color: AgrisellColors.surface,
    borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
  );

  static final containerDecoration2 = BoxDecoration(
    color: AgrisellColors.borderLine,
    borderRadius: BorderRadius.circular(2),
  );

  static const noVouchersAvailableRightNowText = TextStyle(
    color: AgrisellColors.mutedText,
    fontSize: 14,
  );
}
