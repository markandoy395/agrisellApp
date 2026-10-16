import 'package:agresell_app/core/theme/app_typography.dart';
import 'package:flutter/material.dart';

import 'package:agresell_app/core/theme/agrisell_colors.dart';

abstract final class RiderPickupConfirmationStyles {
  static const summaryTitleStyle = TextStyle(
    fontFamily: AppTypography.fontFamily,
    fontSize: 15,
    fontWeight: FontWeight.w800,
  );

  static const smallTextStyle = TextStyle(
    fontFamily: AppTypography.fontFamily,
    fontSize: 12,
  );

  static const smallBoldStyle = TextStyle(
    fontFamily: AppTypography.fontFamily,
    fontSize: 12,
    fontWeight: FontWeight.w700,
  );

  static const sectionHeaderStyle = TextStyle(
    fontFamily: AppTypography.fontFamily,
    fontSize: 14,
    fontWeight: FontWeight.w800,
  );

  static const errorTextStyle = TextStyle(
    fontFamily: AppTypography.fontFamily,
    color: AgrisellColors.statusRedText,
    fontSize: 12,
    fontWeight: FontWeight.w700,
  );

  static const errorItemStyle = TextStyle(
    fontFamily: AppTypography.fontFamily,
    color: AgrisellColors.statusRedText,
    fontSize: 12,
  );

  static TextStyle locationStatusStyle({required bool usable}) => TextStyle(
    fontFamily: AppTypography.fontFamily,
    fontSize: 12,
    color: usable ? AgrisellColors.authGreen : AgrisellColors.statusRedText,
    fontWeight: FontWeight.w700,
  );

  static const completeButtonBox = Size(double.infinity, 38);
}
