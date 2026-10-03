import 'package:flutter/material.dart';
import 'package:agresell_app/core/theme/agrisell_colors.dart';

abstract final class ProductDetailReviewTileStyles {
  static const textStyle = TextStyle(
    color: AgrisellColors.brandBlack,
    fontSize: 13,
    height: 1.3,
  );

  static final containerDecoration = BoxDecoration(
    color: AgrisellColors.statusBlueBackground,
    borderRadius: BorderRadius.circular(8),
    border: Border.all(color: AgrisellColors.accentBlue.withValues(alpha: 0.3)),
  );

  static const textStyle2 = TextStyle(
    color: AgrisellColors.statusBlueText,
    fontSize: 12,
    fontWeight: FontWeight.w700,
  );

  static const noteText = TextStyle(
    color: AgrisellColors.headingGreenAlt,
    fontSize: 12,
    height: 1.25,
  );

  static final containerDecoration2 = BoxDecoration(
    color: AgrisellColors.forestSoft.withValues(alpha: 0.65),
    borderRadius: BorderRadius.circular(8),
    border: const Border(
      left: BorderSide(color: AgrisellColors.authGreen, width: 3.5),
    ),
  );
}
