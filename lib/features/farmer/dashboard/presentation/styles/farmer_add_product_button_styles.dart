import 'package:flutter/material.dart';
import 'package:agresell_app/core/theme/agrisell_colors.dart';

abstract final class FarmerAddProductButtonStyles {
  static final filledButtonStyle = FilledButton.styleFrom(
    minimumSize: const Size(190, 38),
    padding: const EdgeInsets.symmetric(horizontal: 24),
    backgroundColor: AgrisellColors.authGreen,
    foregroundColor: AgrisellColors.surface,
    disabledBackgroundColor: AgrisellColors.brandBlack.withValues(alpha: 0.16),
    disabledForegroundColor: AgrisellColors.brandBlack.withValues(alpha: 0.56),
    elevation: 5,
    shadowColor: AgrisellColors.brandBlack.withValues(alpha: 0.25),
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(22)),
  );

  static const addNewProductsText = TextStyle(
    fontSize: 13,
    height: 1,
    fontWeight: FontWeight.w700,
  );
}
