import 'package:flutter/material.dart';
import 'package:agresell_app/core/theme/agrisell_colors.dart';

abstract final class BasketCheckoutControlsStyles {
  static const textStyle2 = TextStyle(
    color: AgrisellColors.authGreen,
    fontSize: 15,
    height: 1,
    fontWeight: FontWeight.w800,
  );

  static final _allTextActive = TextStyle(
    color: AgrisellColors.brandBlack,
    fontSize: 15,
    height: 1,
    fontWeight: FontWeight.w500,
  );
  static final _allTextInactive = TextStyle(
    color: AgrisellColors.mutedText,
    fontSize: 15,
    height: 1,
    fontWeight: FontWeight.w500,
  );
  static TextStyle allText(bool enabled) =>
      enabled ? _allTextActive : _allTextInactive;
}
