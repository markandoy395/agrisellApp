import 'package:flutter/material.dart';

abstract final class AppSnackBarStyles {
  static EdgeInsets margin(double keyboardInset) =>
      EdgeInsets.fromLTRB(12, 0, 12, 12 + keyboardInset);
  static const padding = EdgeInsets.fromLTRB(16, 6, 6, 6);
  static const radius = BorderRadius.all(Radius.circular(12));
  static const text = TextStyle(fontSize: 13, height: 1.35);

  static TextStyle contentText(ThemeData theme) =>
      (theme.snackBarTheme.contentTextStyle ?? theme.textTheme.bodyMedium!)
          .merge(text)
          .copyWith(
            color:
                theme.snackBarTheme.contentTextStyle?.color ??
                theme.colorScheme.onInverseSurface,
          );

  static double maxContentHeight(MediaQueryData media) {
    final available =
        media.size.height - media.viewInsets.bottom - media.padding.vertical;
    return (available * 0.25).clamp(48.0, 180.0);
  }
}
