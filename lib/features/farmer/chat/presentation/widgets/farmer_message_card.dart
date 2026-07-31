import 'package:flutter/material.dart';

import 'package:agresell_app/core/theme/agrisellColors.dart';
import 'package:agresell_app/features/shared/chat/domain/marketplace_conversation.dart';

class FarmerMessageCard extends StatelessWidget {
  const FarmerMessageCard({
    required this.thread,
    required this.isRead,
    required this.onTap,
    super.key,
  });

  final MarketplaceConversation thread;
  final bool isRead;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final hasUnread = thread.hasUnread && !isRead;
    return Semantics(
      button: true,
      label: 'Open chat with ${thread.buyerName}',
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
                _BuyerAvatar(initials: thread.initials),
                const SizedBox(width: 11),
                Expanded(
                  child: _ConversationSummary(
                    thread: thread,
                    hasUnread: hasUnread,
                  ),
                ),
                const SizedBox(width: 10),
                _ConversationMeta(thread: thread, hasUnread: hasUnread),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _BuyerAvatar extends StatelessWidget {
  const _BuyerAvatar({required this.initials});

  final String initials;

  @override
  Widget build(BuildContext context) => CircleAvatar(
    radius: 23,
    backgroundColor: AgrisellColors.statusGreenBackground,
    child: Text(
      initials,
      maxLines: 1,
      style: const TextStyle(
        color: AgrisellColors.authGreen,
        fontSize: 13,
        height: 1,
        fontWeight: FontWeight.w800,
      ),
    ),
  );
}

class _ConversationSummary extends StatelessWidget {
  const _ConversationSummary({required this.thread, required this.hasUnread});

  final MarketplaceConversation thread;
  final bool hasUnread;

  @override
  Widget build(BuildContext context) => Column(
    mainAxisSize: MainAxisSize.min,
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(
        thread.buyerName,
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
        thread.previewText,
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
  const _ConversationMeta({required this.thread, required this.hasUnread});

  final MarketplaceConversation thread;
  final bool hasUnread;

  @override
  Widget build(BuildContext context) => SizedBox(
    width: 50,
    child: Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Text(
          thread.timeLabel,
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
