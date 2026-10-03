import 'package:flutter/material.dart';
import 'package:agresell_app/core/theme/agrisell_colors.dart';

abstract final class RiderAcceptanceDialogStyles {
  static const textStyle = TextStyle(fontSize: 12, height: 1.35);

  static const textStyle2 = TextStyle(
    color: AgrisellColors.statusRedText,
    fontSize: 12,
    height: 1.35,
    fontWeight: FontWeight.w700,
  );

  static final _valueTextActive = TextStyle(
    color: AgrisellColors.authGreen,
    fontSize: 14,
    fontWeight: FontWeight.w800,
  );
  static final _valueTextInactive = TextStyle(
    color: AgrisellColors.headingGreen,
    fontSize: 13,
    fontWeight: FontWeight.w800,
  );
  static TextStyle valueText(bool emphasized) =>
      emphasized ? _valueTextActive : _valueTextInactive;
}
