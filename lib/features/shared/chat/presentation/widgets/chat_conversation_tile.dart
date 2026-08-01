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
            decoration: const BoxDecoration(
              border: Border(
                bottom: BorderSide(color: AgrisellColors.borderLine),
              ),
            ),
            child: Row(
              children: [
                ChatAvatar(
                  participant: data.participant,
                  style: ChatAvatarStyle(
                    diameter: 46,
                    backgroundColor: AgrisellColors.statusGreenBackground,
                    foregroundColor: AgrisellColors.authGreen,
                    textStyle: TextStyle(
                      fontSize: 13,
                      height: avatarTextHeight,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
                const SizedBox(width: 11),
                Expanded(
                  child: _ConversationSummary(data: data, hasUnread: hasUnread),
                ),
                const SizedBox(width: 10),
                _ConversationMeta(data: data, hasUnread: hasUnread),
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
      Text(
        data.participant.name,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: TextStyle(
          color: AgrisellColors.headingGreen,
          fontSize: 14,
          fontWeight: hasUnread ? FontWeight.w800 : FontWeight.w700,
        ),
      ),
      const SizedBox(height: 3),
      Text(
        data.previewText,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: TextStyle(
          color: hasUnread
              ? AgrisellColors.brandBlack
              : AgrisellColors.mutedText,
          fontSize: 12,
          height: 1.2,
          fontWeight: hasUnread ? FontWeight.w700 : FontWeight.w500,
        ),
      ),
    ],
  );
}

class _ConversationMeta extends StatelessWidget {
  const _ConversationMeta({required this.data, required this.hasUnread});

  final ChatConversationTileData data;
  final bool hasUnread;

  @override
  Widget build(BuildContext context) => SizedBox(
    width: 50,
    child: Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Text(
          data.timeLabel,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
            color: hasUnread
                ? AgrisellColors.authGreen
                : AgrisellColors.mutedText,
            fontSize: 12,
            fontWeight: hasUnread ? FontWeight.w700 : FontWeight.w500,
          ),
        ),
        const SizedBox(height: 8),
        if (hasUnread)
          const CircleAvatar(
            radius: 4,
            backgroundColor: AgrisellColors.authGreen,
          ),
      ],
    ),
  );
}
