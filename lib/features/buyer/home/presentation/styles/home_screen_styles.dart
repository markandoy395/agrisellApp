import 'package:flutter/material.dart';

import 'package:agresell_app/core/theme/agrisell_colors.dart';

abstract final class HomeScreenStyles {
  static const Color scaffoldBackground = AgrisellColors.homeBackground;
  static const Color navBarBackground = AgrisellColors.surface;
  static const Color navBarActiveBackground = AgrisellColors.authGreen;
  static const Color navBarActiveIconColor = AgrisellColors.surface;
  static const Color navBarInactiveIconColor = AgrisellColors.brandBlack;
  static const Color navBarInactiveLabelColor = AgrisellColors.brandBlack;

  static final Color navBarShadowColor =
      AgrisellColors.brandBlack.withValues(alpha: 0.16);

  static double chatBottomPadding(double bottomInset) => bottomInset + 8;
}
