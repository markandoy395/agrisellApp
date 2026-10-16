import 'package:flutter/material.dart';
import 'package:agresell_app/core/theme/app_typography.dart';
import 'package:agresell_app/core/theme/agrisell_colors.dart';
import '../../domain/chat_limits.dart';

abstract final class ChatMessageFieldStyles {
  static final counter = AppTypography.caption.copyWith(
    color: AgrisellColors.mutedText,
  );
  static InputDecoration decoration(InputDecoration base) => base.copyWith(
    helperText:
        '${ChatLimits.messagesPerConversationMinute}/min per chat · ${ChatLimits.messagesPerAccountDay}/day',
    helperMaxLines: 2,
    helperStyle: counter,
    counterStyle: counter,
  );
}
