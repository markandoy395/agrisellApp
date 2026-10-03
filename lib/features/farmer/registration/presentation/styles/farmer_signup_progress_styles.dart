import 'package:flutter/material.dart';
import 'package:agresell_app/core/theme/agrisell_colors.dart';

abstract final class FarmerSignupProgressStyles {
  static final _containerDecorationActive = BoxDecoration(
    color: AgrisellColors.authGreen,
    shape: BoxShape.circle,
    border: Border.all(color: AgrisellColors.surface, width: 2),
  );
  static final _containerDecorationInactive = BoxDecoration(
    color: AgrisellColors.deliveryGray,
    shape: BoxShape.circle,
    border: Border.all(color: AgrisellColors.surface, width: 2),
  );
  static BoxDecoration containerDecoration(bool active) =>
      active ? _containerDecorationActive : _containerDecorationInactive;

  static const textStyle = TextStyle(
    color: AgrisellColors.surface,
    fontSize: 13,
    fontWeight: FontWeight.w700,
  );

  static final _textStyle2Active = TextStyle(
    color: AgrisellColors.authGreen,
    fontSize: 12,
    fontWeight: FontWeight.w600,
  );
  static final _textStyle2Inactive = TextStyle(
    color: AgrisellColors.mutedText,
    fontSize: 12,
    fontWeight: FontWeight.w400,
  );
  static TextStyle textStyle2(bool active) =>
      active ? _textStyle2Active : _textStyle2Inactive;
}
