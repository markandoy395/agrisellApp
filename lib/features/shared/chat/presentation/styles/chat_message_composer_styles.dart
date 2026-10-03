import 'package:flutter/material.dart';
import 'package:agresell_app/core/theme/agrisell_colors.dart';

abstract final class ChatMessageComposerStyles {
  static InputDecoration textFieldStyle(ChatMessageComposerStyle style) =>
      style.inputDecoration.copyWith(hintText: style.hintText, counterText: '');

  static final iconButtonStyle = IconButton.styleFrom(
    backgroundColor: AgrisellColors.authGreen,
    disabledBackgroundColor: AgrisellColors.mutedText,
    foregroundColor: AgrisellColors.surface,
  );
}

class ChatMessageComposerStyle {
  const ChatMessageComposerStyle({
    required this.padding,
    required this.decoration,
    required this.hintText,
    required this.inputDecoration,
    this.minLines = 1,
    this.maxLines = 1,
    this.sendButtonSize,
  });

  final EdgeInsets padding;
  final Decoration decoration;
  final String hintText;
  final InputDecoration inputDecoration;
  final int minLines;
  final int maxLines;
  final Size? sendButtonSize;
}
