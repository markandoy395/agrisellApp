import 'package:flutter/material.dart';

abstract final class MessageBottomBorderStyles {
  static BoxDecoration decoratedBoxDecoration(Color color, double radius) =>
      BoxDecoration(
        color: color,
        borderRadius: BorderRadius.vertical(bottom: Radius.circular(radius)),
      );
}
