import 'package:agresell_app/core/theme/app_typography.dart';
import 'package:flutter/material.dart';

import 'package:agresell_app/core/theme/agrisell_colors.dart';

abstract final class RiderNotificationCardStyles {
  static const padding = EdgeInsets.fromLTRB(12, 12, 6, 12);
  static const iconContainerSize = 42.0;
  static const iconSize = 21.0;
  static const unreadDotSize = 8.0;
  static const borderRadiusValue = 16.0;

  static BoxDecoration cardDecoration({
    required bool isRead,
    required Color styleColor,
  }) => BoxDecoration(
    color: isRead ? AgrisellColors.surface : styleColor.withValues(alpha: 0.07),
    borderRadius: BorderRadius.circular(borderRadiusValue),
    border: Border.all(color: isRead ? AgrisellColors.borderLine : styleColor),
    boxShadow: [
      BoxShadow(
        color: AgrisellColors.brandBlack.withValues(alpha: 0.055),
        blurRadius: 12,
        offset: const Offset(0, 5),
      ),
    ],
  );

  static BoxDecoration iconDecoration(Color styleColor) => BoxDecoration(
    color: styleColor.withValues(alpha: 0.13),
    borderRadius: BorderRadius.circular(13),
  );

  static BoxDecoration unreadDotDecoration(Color styleColor) =>
      BoxDecoration(color: styleColor, shape: BoxShape.circle);

  static TextStyle titleStyle(bool isRead) => TextStyle(
    fontFamily: AppTypography.fontFamily,
    color: AgrisellColors.headingGreen,
    fontSize: 13,
    height: 1.25,
    fontWeight: isRead ? FontWeight.w700 : FontWeight.w800,
  );

  static TextStyle typeLabelStyle(Color styleColor) => TextStyle(
    fontFamily: AppTypography.fontFamily,
    color: styleColor,
    fontSize: 12,
    fontWeight: FontWeight.w700,
  );

  static const dateLabelStyle = TextStyle(
    fontFamily: AppTypography.fontFamily,
    color: AgrisellColors.mutedText,
    fontSize: 12,
    fontWeight: FontWeight.w600,
  );

  static const messageStyle = TextStyle(
    fontFamily: AppTypography.fontFamily,
    color: AgrisellColors.brandBlack,
    fontSize: 12,
    height: 1.35,
  );
}
