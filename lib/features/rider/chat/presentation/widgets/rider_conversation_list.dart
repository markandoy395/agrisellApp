import 'package:flutter/material.dart';

import 'package:agresell_app/core/theme/agrisellColors.dart';
import 'package:agresell_app/features/rider/chat/domain/rider_communication_models.dart';
import 'package:agresell_app/features/rider/presentation/widgets/rider_page_widgets.dart';
import 'package:agresell_app/features/rider/presentation/widgets/rider_state_cards.dart';

class RiderConversationList extends StatelessWidget {
  const RiderConversationList({
    required this.conversations,
    required this.onOpenConversation,
    super.key,
  });

  final List<RiderConversation> conversations;
  final ValueChanged<RiderConversation> onOpenConversation;

  @override
  Widget build(BuildContext context) {
    if (conversations.isEmpty) {
      return const Padding(
        padding: EdgeInsets.only(top: 14),
        child: RiderEmptyStateCard(
          title: 'No delivery conversations',
          message:
              'Messages from sellers, buyers, and support will appear here when chat is connected.',
          icon: Icons.chat_bubble_outline_rounded,
        ),
      );
    }
    return ListView.separated(
      padding: const EdgeInsets.only(top: 14),
      physics: const NeverScrollableScrollPhysics(),
      shrinkWrap: true,
      itemCount: conversations.length,
      separatorBuilder: (_, _) => const SizedBox(height: 10),
      itemBuilder: (context, index) {
        return _ConversationCard(
          conversation: conversations[index],
          onTap: () => onOpenConversation(conversations[index]),
        );
      },
    );
  }
}

class _ConversationCard extends StatelessWidget {
  const _ConversationCard({required this.conversation, required this.onTap});

  final RiderConversation conversation;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final hasUnread = conversation.unreadCount > 0;
    return Semantics(
      button: true,
      label:
          '${conversation.party.label} conversation with ${conversation.participantLabel}',
      child: RiderSurfaceCard(
        padding: EdgeInsets.zero,
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                _PartyAvatar(party: conversation.party),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              conversation.participantLabel,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                color: AgrisellColors.headingGreen,
                                fontSize: 14,
                                fontWeight: hasUnread
                                    ? FontWeight.w800
                                    : FontWeight.w700,
                              ),
                            ),
                          ),
                          if (conversation.lastActivity case final activity?)
                            Text(
                              _timeLabel(activity),
                              style: const TextStyle(
                                color: AgrisellColors.mutedText,
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                        ],
                      ),
                      const SizedBox(height: 3),
                      Text(
                        conversation.lastMessagePreview ?? 'No messages yet',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: AgrisellColors.mutedText,
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
                if (hasUnread) ...[
                  const SizedBox(width: 8),
                  Container(
                    constraints: const BoxConstraints(minWidth: 20),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 5,
                      vertical: 3,
                    ),
                    decoration: const BoxDecoration(
                      color: AgrisellColors.authGreen,
                      borderRadius: BorderRadius.all(Radius.circular(10)),
                    ),
                    child: Text(
                      '${conversation.unreadCount}',
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        color: AgrisellColors.surface,
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _PartyAvatar extends StatelessWidget {
  const _PartyAvatar({required this.party});

  final RiderConversationParty party;

  @override
  Widget build(BuildContext context) {
    final icon = switch (party) {
      RiderConversationParty.seller => Icons.storefront_outlined,
      RiderConversationParty.buyer => Icons.person_outline_rounded,
      RiderConversationParty.support => Icons.support_agent_rounded,
    };
    return Container(
      width: 40,
      height: 40,
      decoration: const BoxDecoration(
        color: AgrisellColors.forestSoft,
        shape: BoxShape.circle,
      ),
      child: Icon(icon, color: AgrisellColors.authGreen, size: 20),
    );
  }
}

String _timeLabel(DateTime time) {
  final difference = DateTime.now().difference(time);
  if (difference.inMinutes < 1) return 'Now';
  if (difference.inHours < 1) return '${difference.inMinutes}m';
  if (difference.inDays < 1) return '${difference.inHours}h';
  return '${difference.inDays}d';
}
