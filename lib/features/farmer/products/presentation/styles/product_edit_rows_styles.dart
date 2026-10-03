import 'package:flutter/material.dart';
import 'package:agresell_app/core/theme/agrisell_colors.dart';

abstract final class ProductEditRowsStyles {
  static final outlinedButtonStyle = OutlinedButton.styleFrom(
    alignment: Alignment.centerLeft,
    foregroundColor: AgrisellColors.authGreen,
    side: const BorderSide(color: AgrisellColors.borderLine),
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
  );
}
