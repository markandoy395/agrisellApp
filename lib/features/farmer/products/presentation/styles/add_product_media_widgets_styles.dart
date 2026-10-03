import 'package:flutter/material.dart';
import 'package:agresell_app/core/theme/agrisell_colors.dart';

abstract final class AddProductMediaWidgetsStyles {
  static final containerDecoration = BoxDecoration(
    color: AgrisellColors.brandBlack.withValues(alpha: 0.42),
    shape: BoxShape.circle,
  );

  static final textStyle = TextStyle(
    color: AgrisellColors.brandBlack.withValues(alpha: 0.56),
    fontSize: 12,
    height: 1,
    fontWeight: FontWeight.w600,
  );
}
