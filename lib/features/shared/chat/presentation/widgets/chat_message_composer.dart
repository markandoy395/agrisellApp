export 'package:agresell_app/features/shared/chat/presentation/styles/chat_message_composer_styles.dart';
import 'chat_message_field.dart';
import 'package:agresell_app/features/shared/chat/presentation/styles/chat_message_composer_styles.dart';
import 'package:flutter/material.dart';
import '../styles/chat_reference_styles.dart';

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
            child: ChatMessageField(
              controller: controller,
              minLines: style.minLines,
              maxLines: style.maxLines,
              enabled: !isSending,
              onSend: onSend,
              decoration: ChatMessageComposerStyles.textFieldStyle(style),
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
      icon: Icon(Icons.send_outlined, size: size == null ? 20 : 19),
      style: ChatReferenceStyles.sendButton,
    );
    if (size == null) return button;
    return SizedBox(width: size!.width, height: size!.height, child: button);
  }
}
