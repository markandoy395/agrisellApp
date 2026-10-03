import 'package:flutter/material.dart';

import 'package:agresell_app/core/theme/agrisell_colors.dart';

abstract final class RiderApplicationSubmittedStyles {
  static const headingStyle = TextStyle(
    color: AgrisellColors.headingGreen,
    fontSize: 15,
    fontWeight: FontWeight.w800,
  );

  static const referenceStyle = TextStyle(fontSize: 12);

  static const mutedBodyStyle = TextStyle(
    fontSize: 12,
    color: AgrisellColors.mutedText,
    height: 1.35,
  );

  static const buttonSize = Size(double.infinity, 40);
}
