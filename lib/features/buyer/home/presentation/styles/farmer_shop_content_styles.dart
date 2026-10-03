import 'package:flutter/material.dart';
import 'package:agresell_app/core/theme/agrisell_colors.dart';

abstract final class FarmerShopContentStyles {
  static final containerDecoration = BoxDecoration(
    color: AgrisellColors.surface,
    border: Border.all(color: AgrisellColors.borderLine),
    borderRadius: const BorderRadius.vertical(top: Radius.circular(22)),
  );

  static final containerDecoration2 = BoxDecoration(
    color: AgrisellColors.homeBackground,
    borderRadius: const BorderRadius.vertical(top: Radius.circular(18)),
  );
}
