import 'package:flutter/material.dart';

import 'package:agresell_app/core/theme/agrisell_colors.dart';

/// Shared visual tokens for Flutter's legacy [DropdownButton] controls.
///
/// Unlike Material 3 [DropdownMenu], these controls do not read a global menu
/// theme for their popup surface, so each control uses these tokens directly.
abstract final class AppDropdownStyle {
  static const menuColor = AgrisellColors.surface;
  static const iconColor = AgrisellColors.authGreen;
  static const textStyle = TextStyle(
    color: AgrisellColors.headingGreen,
    fontFamily: 'Poppins',
    fontSize: 14,
    fontWeight: FontWeight.w600,
  );
  static const menuBorderRadius = BorderRadius.all(Radius.circular(16));
}
