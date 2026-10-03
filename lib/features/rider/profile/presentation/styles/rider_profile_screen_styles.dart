import 'package:flutter/material.dart';

import 'package:agresell_app/core/theme/agrisell_colors.dart';

abstract final class RiderProfileScreenStyles {
  static const backgroundColor = AgrisellColors.homeBackground;
  static const settingsConstraints = BoxConstraints.tightFor(
    width: 38,
    height: 38,
  );
  static const settingsIconPadding = EdgeInsets.zero;
  static const settingsIconColor = AgrisellColors.surface;
  static const settingsIconSize = 24.0;
  static const emptyStatePadding = EdgeInsets.all(22);
}
