import 'package:flutter/material.dart';

abstract final class ChatAvatarStyles {
  static TextStyle textStyle(ChatAvatarStyle style) =>
      style.textStyle.copyWith(color: style.foregroundColor);
}

class ChatAvatarStyle {
  const ChatAvatarStyle({
    required this.diameter,
    required this.backgroundColor,
    required this.foregroundColor,
    required this.textStyle,
  });

  final double diameter;
  final Color backgroundColor;
  final Color foregroundColor;
  final TextStyle textStyle;
}
