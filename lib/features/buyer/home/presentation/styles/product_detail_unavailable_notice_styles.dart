import 'package:flutter/material.dart';
import 'package:agresell_app/core/theme/agrisell_colors.dart';

abstract final class ProductDetailUnavailableNoticeStyles {
  static final containerDecoration = BoxDecoration(
    color: AgrisellColors.statusRedBackground,
    borderRadius: BorderRadius.circular(10),
    border: Border.all(
      color: AgrisellColors.statusRedText.withValues(alpha: 0.22),
    ),
  );

  static const thisProductIsNotAcceptingText = TextStyle(
    color: AgrisellColors.statusRedText,
    fontSize: 12,
    height: 1.25,
    fontWeight: FontWeight.w700,
  );
}
