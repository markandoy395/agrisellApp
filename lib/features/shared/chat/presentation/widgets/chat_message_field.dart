import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:agresell_app/core/theme/app_typography.dart';
import '../../domain/chat_limits.dart';
import '../styles/chat_message_field_styles.dart';

/// Both composer layouts use this field, its counter and its Unicode limit.
class ChatMessageField extends StatelessWidget {
  const ChatMessageField({
    required this.controller,
    required this.decoration,
    required this.onSend,
    this.enabled = true,
    this.minLines = 1,
    this.maxLines = 3,
    super.key,
  });
  final TextEditingController controller;
  final InputDecoration decoration;
  final VoidCallback onSend;
  final bool enabled;
  final int minLines;
  final int maxLines;

  @override
  Widget build(BuildContext context) => TextField(
    controller: controller,
    enabled: enabled,
    minLines: minLines,
    maxLines: maxLines,
    maxLength: ChatLimits.messageCharacters,
    maxLengthEnforcement: MaxLengthEnforcement.none,
    inputFormatters: [ChatLimits.inputFormatter],
    textCapitalization: TextCapitalization.sentences,
    textInputAction: TextInputAction.send,
    style: AppTypography.body,
    decoration: ChatMessageFieldStyles.decoration(decoration),
    buildCounter:
        (
          context, {
          required currentLength,
          required isFocused,
          maxLength,
        }) => Text(
          '${ChatLimits.length(controller.text)}/${ChatLimits.messageCharacters}',
          semanticsLabel:
              '${ChatLimits.length(controller.text)} of ${ChatLimits.messageCharacters} characters',
          style: ChatMessageFieldStyles.counter,
        ),
    onSubmitted: (_) {
      if (enabled && ChatLimits.valid(controller.text)) onSend();
    },
  );
}
