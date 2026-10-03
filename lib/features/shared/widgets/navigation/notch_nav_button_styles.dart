import 'package:flutter/material.dart';

abstract final class NotchNavButtonStyles {
  static BoxDecoration decoratedBoxDecoration(
    Color background,
    BorderRadius? borderRadius,
  ) => BoxDecoration(
    color: background,
    shape: borderRadius == null ? BoxShape.circle : BoxShape.rectangle,
    borderRadius: borderRadius,
  );

  static TextStyle labelText(Color color) => TextStyle(
    color: color,
    fontSize: 12,
    height: 1,
    fontWeight: FontWeight.w800,
  );
}
