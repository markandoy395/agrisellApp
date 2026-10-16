import 'package:agresell_app/core/theme/app_typography.dart';
import 'package:flutter/material.dart';

abstract final class RiderRequestFilterSheetStyles {
  static EdgeInsets sheetPadding(double bottomInset) =>
      EdgeInsets.fromLTRB(18, 0, 18, 18 + bottomInset);

  static const headerTitleStyle = TextStyle(
    fontFamily: AppTypography.fontFamily,
    fontSize: 15,
    fontWeight: FontWeight.w800,
  );

  static const sectionLabelStyle = TextStyle(
    fontFamily: AppTypography.fontFamily,
    fontSize: 12,
    fontWeight: FontWeight.w700,
  );

  static const categoryInputDecoration = InputDecoration(
    labelText: 'Product category',
    isDense: true,
  );

  static const chipSpacing = 7.0;
  static const sectionSpacing = SizedBox(height: 8);
  static const actionSpacing = SizedBox(height: 14);
  static const buttonSpacing = SizedBox(width: 8);
}
