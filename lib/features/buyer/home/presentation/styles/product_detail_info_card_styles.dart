import 'package:flutter/material.dart';

import 'package:agresell_app/core/theme/agrisell_colors.dart';

abstract final class ProductDetailInfoCardStyles {
  static const cardPadding = EdgeInsets.all(16);

  static final cardDecoration = BoxDecoration(
    color: AgrisellColors.surface,
    borderRadius: BorderRadius.circular(20),
    border: Border.all(color: AgrisellColors.borderLine),
    boxShadow: [
      BoxShadow(
        color: AgrisellColors.brandBlack.withValues(alpha: 0.06),
        blurRadius: 14,
        offset: const Offset(0, 5),
      ),
    ],
  );

  static const nameStyle = TextStyle(
    color: AgrisellColors.headingGreen,
    fontSize: 15,
    height: 1.15,
    fontWeight: FontWeight.w800,
  );

  static const sectionTitleStyle = TextStyle(
    color: AgrisellColors.headingGreen,
    fontSize: 14,
    fontWeight: FontWeight.w800,
  );

  static const descriptionStyle = TextStyle(
    color: AgrisellColors.mutedText,
    fontSize: 12,
    height: 1.45,
    fontWeight: FontWeight.w400,
  );

  static const factTextStyle = TextStyle(
    color: AgrisellColors.mutedText,
    fontSize: 12,
    fontWeight: FontWeight.w500,
  );

  static const storageTextStyle = TextStyle(
    color: AgrisellColors.mutedText,
    fontSize: 12,
    height: 1.3,
    fontWeight: FontWeight.w500,
  );

  static const factIconColor = AgrisellColors.authGreen;
  static const factIconSize = 16.0;
  static const factWrapSpacing = 14.0;
  static const factWrapRunSpacing = 8.0;
  static const factItemSpacing = 4.0;
}
