import 'package:flutter/material.dart';

abstract final class ReserveChatBubbleStyles {
  static BoxDecoration decoratedBoxDecoration(Color background) =>
      BoxDecoration(color: background, borderRadius: BorderRadius.circular(8));

  static TextStyle nameText(Color textColor) => TextStyle(
    color: textColor.withValues(alpha: 0.72),
    fontSize: 12,
    height: 1,
    fontWeight: FontWeight.w800,
  );

  static TextStyle textText(Color textColor) => TextStyle(
    color: textColor,
    fontSize: 12,
    height: 1.3,
    fontWeight: FontWeight.w500,
  );
}
