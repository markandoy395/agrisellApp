import 'package:flutter/material.dart';
import 'package:agresell_app/core/theme/agrisell_colors.dart';

abstract final class CompactOrderActionButtonStyles {
  static ButtonStyle filledButtonStyle(
    EdgeInsets padding,
    TextStyle textStyle,
    RoundedRectangleBorder shape,
  ) => FilledButton.styleFrom(
    backgroundColor: AgrisellColors.authGreen,
    foregroundColor: AgrisellColors.surface,
    padding: padding,
    textStyle: textStyle,
    shape: shape,
  );

  static ButtonStyle outlinedButtonStyle(
    Color color,
    EdgeInsets padding,
    TextStyle textStyle,
    RoundedRectangleBorder shape,
  ) => OutlinedButton.styleFrom(
    foregroundColor: color,
    side: BorderSide(color: color.withValues(alpha: 0.5)),
    padding: padding,
    textStyle: textStyle,
    shape: shape,
  );
}
