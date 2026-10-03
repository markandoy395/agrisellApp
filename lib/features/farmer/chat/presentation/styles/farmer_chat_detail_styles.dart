import 'package:flutter/material.dart';

import 'package:agresell_app/core/theme/agrisell_colors.dart';
import 'package:agresell_app/features/shared/chat/presentation/widgets/chat_avatar.dart';
import 'package:agresell_app/features/shared/chat/presentation/widgets/chat_content_state.dart';
import 'package:agresell_app/features/shared/chat/presentation/widgets/chat_detail_header.dart';
import 'package:agresell_app/features/shared/chat/presentation/widgets/chat_message_bubble.dart';
import 'package:agresell_app/features/shared/chat/presentation/widgets/chat_message_composer.dart';

abstract final class FarmerChatDetailStyles {
  static const Color backgroundColor = AgrisellColors.homeBackground;

  static double horizontalPadding(double screenWidth) =>
      screenWidth < 380 ? 12.0 : 14.0;

  static double composerBottomPadding({
    required double keyboardInset,
    required double bottomClearance,
  }) => keyboardInset > 0 ? 12.0 : bottomClearance;

  static ChatDetailHeaderStyle headerStyle(double topInset) =>
      ChatDetailHeaderStyle(
        padding: EdgeInsets.fromLTRB(
          6,
          (topInset > 0 ? topInset : 24) + 8,
          14,
          12,
        ),
        decoration: BoxDecoration(
          color: AgrisellColors.authGreen,
          boxShadow: [
            BoxShadow(
              color: AgrisellColors.brandBlack.withValues(alpha: 0.14),
              blurRadius: 14,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        avatarStyle: const ChatAvatarStyle(
          diameter: 40,
          backgroundColor: AgrisellColors.surface,
          foregroundColor: AgrisellColors.authGreen,
          textStyle: TextStyle(fontSize: 13, fontWeight: FontWeight.w800),
        ),
        titleStyle: const TextStyle(
          color: AgrisellColors.surface,
          fontSize: 15,
          height: 1.1,
          fontWeight: FontWeight.w800,
        ),
        subtitleStyle: TextStyle(
          color: AgrisellColors.surface.withValues(alpha: 0.88),
          fontSize: 12,
          fontWeight: FontWeight.w600,
        ),
        subtitleSpacing: 4,
      );

  static const ChatMessageBubbleStyle bubbleStyle = ChatMessageBubbleStyle(
    statusTextStyle: TextStyle(
      fontSize: 12,
      height: 1,
      fontWeight: FontWeight.w600,
    ),
    statusMaxLines: 1,
    statusOverflow: TextOverflow.ellipsis,
  );

  static const ChatContentStateStyle emptyStateStyle = ChatContentStateStyle(
    padding: EdgeInsets.symmetric(vertical: 28),
  );

  static const ChatContentStateStyle errorStateStyle = ChatContentStateStyle(
    padding: EdgeInsets.zero,
  );

  static ChatMessageComposerStyle composerStyle(double bottomPadding) =>
      ChatMessageComposerStyle(
        padding: EdgeInsets.fromLTRB(12, 9, 12, bottomPadding),
        decoration: BoxDecoration(
          color: AgrisellColors.surface,
          boxShadow: [
            BoxShadow(
              color: AgrisellColors.brandBlack.withValues(alpha: 0.08),
              blurRadius: 14,
              offset: const Offset(0, -5),
            ),
          ],
        ),
        hintText: 'Type a reply',
        minLines: 1,
        maxLines: 3,
        sendButtonSize: const Size(40, 40),
        inputDecoration: InputDecoration(
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 13,
            vertical: 10,
          ),
          border: _inputBorder(AgrisellColors.borderLine),
          enabledBorder: _inputBorder(AgrisellColors.borderLine),
          focusedBorder: _inputBorder(AgrisellColors.authGreen),
        ),
      );

  static OutlineInputBorder _inputBorder(Color color) => OutlineInputBorder(
    borderRadius: BorderRadius.circular(22),
    borderSide: BorderSide(color: color),
  );
}
