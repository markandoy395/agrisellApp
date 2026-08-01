import 'package:flutter/material.dart';

import 'package:agresell_app/core/theme/agrisell_colors.dart';

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

class ChatMessageComposer extends StatelessWidget {
  const ChatMessageComposer({
    required this.controller,
    required this.onSend,
    required this.style,
    this.isSending = false,
    super.key,
  });

  final TextEditingController controller;
  final VoidCallback onSend;
  final ChatMessageComposerStyle style;
  final bool isSending;

  @override
  Widget build(BuildContext context) => DecoratedBox(
    decoration: style.decoration,
    child: Padding(
      padding: style.padding,
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: controller,
              minLines: style.minLines,
              maxLines: style.maxLines,
              maxLength: 1000,
              onSubmitted: (_) => onSend(),
              textInputAction: TextInputAction.send,
              style: const TextStyle(fontSize: 13),
              decoration: style.inputDecoration.copyWith(
                hintText: style.hintText,
                counterText: '',
              ),
            ),
          ),
          const SizedBox(width: 8),
          _SendButton(
            onPressed: isSending ? null : onSend,
            size: style.sendButtonSize,
          ),
        ],
      ),
    ),
  );
}

class _SendButton extends StatelessWidget {
  const _SendButton({required this.onPressed, required this.size});

  final VoidCallback? onPressed;
  final Size? size;

  @override
  Widget build(BuildContext context) {
    final button = IconButton.filled(
      onPressed: onPressed,
      tooltip: 'Send message',
      icon: Icon(Icons.send_rounded, size: size == null ? 20 : 19),
      style: IconButton.styleFrom(
        backgroundColor: AgrisellColors.authGreen,
        disabledBackgroundColor: AgrisellColors.mutedText,
        foregroundColor: AgrisellColors.surface,
      ),
    );
    if (size == null) return button;
    return SizedBox(width: size!.width, height: size!.height, child: button);
  }
}
