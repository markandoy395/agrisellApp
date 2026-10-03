import 'package:flutter/material.dart';
import 'package:agresell_app/core/theme/agrisell_colors.dart';

abstract final class FarmerOrderCancellationDialogStyles {
  static const inputDecoration = InputDecoration(
    hintText: 'Select reason',
    border: OutlineInputBorder(),
    contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 10),
  );

  static final filledButtonStyle = FilledButton.styleFrom(
    backgroundColor: AgrisellColors.statusRedText,
    foregroundColor: AgrisellColors.surface,
  );
}
