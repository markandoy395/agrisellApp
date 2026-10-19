import 'package:flutter/material.dart';

import 'agrisell_colors.dart';

abstract final class AppVersionFooterStyles {
  static const padding = EdgeInsets.fromLTRB(16, 20, 16, 8);

  static const label = TextStyle(
    color: AgrisellColors.mutedText,
    fontSize: 12,
    fontWeight: FontWeight.w400,
  );
}
