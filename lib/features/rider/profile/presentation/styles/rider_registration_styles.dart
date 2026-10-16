import 'package:agresell_app/core/theme/app_typography.dart';
import 'package:flutter/material.dart';

import 'package:agresell_app/core/theme/agrisell_colors.dart';

abstract final class RiderRegistrationStyles {
  // Surface and Borders
  static const Color surfaceColor = AgrisellColors.surface;
  static const BorderRadius modalBorderRadius = BorderRadius.vertical(
    top: Radius.circular(26),
  );

  // Paddings
  static const EdgeInsets headerPadding = EdgeInsets.fromLTRB(18, 18, 14, 10);
  static const EdgeInsets scrollPadding = EdgeInsets.fromLTRB(18, 8, 18, 18);
  static const EdgeInsets actionsPadding = EdgeInsets.fromLTRB(18, 10, 18, 12);

  // Typography
  static const TextStyle headerTitleStyle = TextStyle(
    fontFamily: AppTypography.fontFamily,
    color: AgrisellColors.authGreen,
    fontSize: 15,
    fontWeight: FontWeight.w800,
  );

  static const TextStyle errorMessageStyle = TextStyle(
    fontFamily: AppTypography.fontFamily,
    color: AgrisellColors.statusRedText,
    fontSize: 12,
  );

  // Spacing
  static const SizedBox stepSpacing = SizedBox(height: 18);
  static const SizedBox errorSpacing = SizedBox(height: 12);
}
