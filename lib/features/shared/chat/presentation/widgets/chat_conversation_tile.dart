import 'package:agresell_app/features/shared/chat/presentation/styles/chat_conversation_tile_styles.dart';
import 'package:flutter/material.dart';

import 'package:agresell_app/core/theme/agrisell_colors.dart';
import 'package:agresell_app/features/shared/chat/presentation/models/chat_participant_data.dart';
import 'package:agresell_app/features/shared/chat/presentation/widgets/chat_avatar.dart';

class ChatConversationTile extends StatelessWidget {
  const ChatConversationTile({
    required this.data,
    required this.onTap,
    this.avatarTextHeight,
    super.key,
  });

  final ChatConversationTileData data;
  final VoidCallback onTap;
  final double? avatarTextHeight;

  @override
  Widget build(BuildContext context) {
    final hasUnread = data.hasUnread;
    return Semantics(
      button: true,
      label: data.semanticLabel,
      child: Material(
        color: hasUnread
            ? AgrisellColors.forestSoft.withValues(alpha: 0.42)
            : AgrisellColors.surface,
        child: InkWell(
          onTap: onTap,
          child: Container(
            padding: const EdgeInsets.fromLTRB(14, 10, 14, 10),
            decoration: ChatConversationTileStyles.containerDecoration,
            child: Row(
              children: [
                ChatAvatar(
                  participant: data.participant,
                  style: ChatAvatarStyle(
                    diameter: 46,
                    backgroundColor: AgrisellColors.statusGreenBackground,
                    foregroundColor: AgrisellColors.authGreen,
                    textStyle: ChatConversationTileStyles.textStyle(
                      avatarTextHeight,
                    ),
                  ),
                ),
                const SizedBox(width: 11),
                Expanded(
                  child: _ConversationSummary(data: data, hasUnread: hasUnread),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _ConversationSummary extends StatelessWidget {
  const _ConversationSummary({required this.data, required this.hasUnread});

  final ChatConversationTileData data;
  final bool hasUnread;

  @override
  Widget build(BuildContext context) => Column(
    mainAxisSize: MainAxisSize.min,
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      LayoutBuilder(
        builder: (context, constraints) => Row(
          children: [
            Expanded(
              child: Text(
                data.participant.name,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: ChatConversationTileStyles.textStyle2(hasUnread),
              ),
            ),
            const SizedBox(width: 10),
            ConstrainedBox(
              constraints: BoxConstraints(
                maxWidth: constraints.maxWidth * 0.75,
              ),
              child: Text(
                data.timeLabel,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: ChatConversationTileStyles.textStyle4(hasUnread),
              ),
            ),
          ],
        ),
      ),
      const SizedBox(height: 3),
      Row(
        children: [
          Expanded(
            child: Text(
              data.previewText,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: ChatConversationTileStyles.textStyle3(hasUnread),
            ),
          ),
          if (hasUnread) ...[
            const SizedBox(width: 10),
            const CircleAvatar(
              radius: 4,
              backgroundColor: AgrisellColors.authGreen,
            ),
          ],
        ],
      ),
    ],
  );
}
