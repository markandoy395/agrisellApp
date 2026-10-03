import 'package:flutter/material.dart';
import 'package:agresell_app/core/theme/agrisell_colors.dart';
import 'package:agresell_app/features/buyer/home/presentation/controllers/home_product_browse_controller.dart';

abstract final class HomeProductFilterSheetStyles {
  static const sortByText = TextStyle(
    color: AgrisellColors.brandBlack,
    fontSize: 13,
    fontWeight: FontWeight.w700,
  );

  static TextStyle textStyle(
    HomeProductBrowseController controller,
    HomeProductSort option,
  ) => TextStyle(
    color: controller.sort == option
        ? AgrisellColors.surface
        : AgrisellColors.brandBlack,
    fontSize: 12,
    fontWeight: FontWeight.w600,
  );

  static final filledButtonStyle = FilledButton.styleFrom(
    backgroundColor: AgrisellColors.authGreen,
    foregroundColor: AgrisellColors.surface,
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
  );

  static final containerDecoration = BoxDecoration(
    color: AgrisellColors.mutedText.withValues(alpha: 0.35),
    borderRadius: BorderRadius.circular(4),
  );
}
