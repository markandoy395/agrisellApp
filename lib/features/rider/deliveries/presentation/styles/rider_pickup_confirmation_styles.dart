import 'package:flutter/material.dart';

import 'package:agresell_app/core/theme/agrisell_colors.dart';

abstract final class RiderPickupConfirmationStyles {
  static const summaryTitleStyle = TextStyle(
    fontSize: 15,
    fontWeight: FontWeight.w800,
  );

  static const smallTextStyle = TextStyle(fontSize: 12);

  static const smallBoldStyle = TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.w700,
  );

  static const sectionHeaderStyle = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w800,
  );

  static const errorTextStyle = TextStyle(
    color: AgrisellColors.statusRedText,
    fontSize: 12,
    fontWeight: FontWeight.w700,
  );

  static const errorItemStyle = TextStyle(
    color: AgrisellColors.statusRedText,
    fontSize: 12,
  );

  static TextStyle locationStatusStyle({required bool usable}) => TextStyle(
    fontSize: 12,
    color: usable ? AgrisellColors.authGreen : AgrisellColors.statusRedText,
    fontWeight: FontWeight.w700,
  );

  static const completeButtonBox = Size(double.infinity, 38);
}
