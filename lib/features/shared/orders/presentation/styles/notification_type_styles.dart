import 'package:flutter/material.dart';

abstract final class NotificationTypeStyles {
  static BoxDecoration containerDecoration(NotificationStyle style) =>
      BoxDecoration(
        color: style.background,
        borderRadius: BorderRadius.circular(13),
      );

  static TextStyle textStyle(NotificationStyle style) =>
      TextStyle(color: style.color, fontSize: 12, fontWeight: FontWeight.w700);
}

class NotificationStyle {
  const NotificationStyle({
    required this.icon,
    required this.color,
    required this.background,
    required this.label,
  });

  final IconData icon;
  final Color color;
  final Color background;
  final String label;
}
