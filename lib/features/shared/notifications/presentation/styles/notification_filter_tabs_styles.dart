import 'package:flutter/material.dart';
import 'package:agresell_app/core/theme/agrisell_colors.dart';

abstract final class NotificationFilterTabsStyles {
  static final _textStyleActive = TextStyle(
    color: AgrisellColors.surface,
    fontSize: 12,
    fontWeight: FontWeight.w700,
  );
  static final _textStyleInactive = TextStyle(
    color: AgrisellColors.headingGreen,
    fontSize: 12,
    fontWeight: FontWeight.w700,
  );
  static TextStyle textStyle(bool isSelected) =>
      isSelected ? _textStyleActive : _textStyleInactive;
}
