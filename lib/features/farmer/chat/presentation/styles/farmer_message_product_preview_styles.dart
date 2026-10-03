import 'package:flutter/material.dart';
import 'package:agresell_app/core/theme/agrisell_colors.dart';

abstract final class FarmerMessageProductPreviewStyles {
  static final decoratedBoxDecoration = BoxDecoration(
    color: AgrisellColors.surface,
    borderRadius: BorderRadius.circular(8),
    boxShadow: [
      BoxShadow(
        color: AgrisellColors.brandBlack.withValues(alpha: 0.08),
        blurRadius: 16,
        offset: const Offset(0, 7),
      ),
    ],
  );

  static const textStyle = TextStyle(
    color: AgrisellColors.headingGreen,
    fontSize: 14,
    height: 1.15,
    fontWeight: FontWeight.w800,
  );

  static const textStyle2 = TextStyle(
    color: AgrisellColors.brandBlack,
    fontSize: 12,
    height: 1,
    fontWeight: FontWeight.w600,
  );

  static final containerDecoration = BoxDecoration(
    color: AgrisellColors.statusGreenBackground,
    borderRadius: BorderRadius.circular(14),
  );

  static const labelText = TextStyle(
    color: AgrisellColors.authGreen,
    fontSize: 12,
    height: 1,
    fontWeight: FontWeight.w800,
  );
}
