import 'package:flutter/material.dart';

import 'agrisell_colors.dart';

abstract final class AppVersionFooterStyles {
  static const padding = EdgeInsets.symmetric(horizontal: 16, vertical: 20);

  static const label = TextStyle(
    color: AgrisellColors.mutedText,
    fontSize: 12,
    fontWeight: FontWeight.w400,
  );
}
