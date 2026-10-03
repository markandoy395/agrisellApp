import 'package:flutter/material.dart';
import 'package:agresell_app/core/theme/agrisell_colors.dart';

abstract final class MessageFilterTabsStyles {
  static BoxDecoration animatedContainerDecoration(Color background) =>
      BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AgrisellColors.authGreen),
      );

  static TextStyle textStyle(Color foreground) => TextStyle(
    color: foreground,
    fontSize: 12,
    height: 1,
    fontWeight: FontWeight.w700,
  );
}
