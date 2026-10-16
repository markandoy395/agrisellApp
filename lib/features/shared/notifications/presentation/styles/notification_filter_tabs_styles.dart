import 'package:agresell_app/core/theme/app_typography.dart';
import 'package:flutter/material.dart';
import 'package:agresell_app/core/theme/agrisell_colors.dart';

abstract final class NotificationFilterTabsStyles {
  static final _textStyleActive = TextStyle(
    fontFamily: AppTypography.fontFamily,
    color: AgrisellColors.surface,
    fontSize: 12,
    fontWeight: FontWeight.w700,
  );
  static final _textStyleInactive = TextStyle(
    fontFamily: AppTypography.fontFamily,
    color: AgrisellColors.headingGreen,
    fontSize: 12,
    fontWeight: FontWeight.w700,
  );
  static TextStyle textStyle(bool isSelected) =>
      isSelected ? _textStyleActive : _textStyleInactive;
}
