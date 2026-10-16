import 'package:flutter/material.dart';
import '../../domain/rider_communication_models.dart';
import '../styles/rider_messaging_design_styles.dart';
import 'rider_conversation_avatar.dart';

class RiderConversationCard extends StatelessWidget {
  const RiderConversationCard({
    required this.conversation,
    required this.onTap,
    super.key,
  });
  final RiderConversation conversation;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => Semantics(
    button: true,
    label:
        '${conversation.party.label} conversation with ${conversation.participantLabel}',
    child: Container(
      decoration: RiderMessagingDesignStyles.card,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: RiderMessagingDesignStyles.radius,
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: Row(
              children: [
                RiderConversationAvatar(conversation: conversation),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        conversation.participantLabel,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: RiderMessagingDesignStyles.title,
                      ),
                      const SizedBox(height: 3),
                      Text(
                        '${conversation.party.label} · Delivery chat',
                        style: RiderMessagingDesignStyles.caption,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        conversation.lastMessagePreview ?? 'No messages yet',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: RiderMessagingDesignStyles.muted,
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                Column(
                  children: [
                    if (conversation.lastActivity case final time?)
                      Text(
                        _timeLabel(time),
                        style: RiderMessagingDesignStyles.caption,
                      ),
                    const SizedBox(height: 12),
                    if (conversation.unreadCount > 0)
                      Container(
                        constraints: const BoxConstraints(
                          minWidth: 24,
                          minHeight: 24,
                        ),
                        padding: const EdgeInsets.all(4),
                        decoration: RiderMessagingDesignStyles.badge,
                        child: Text(
                          '${conversation.unreadCount}',
                          textAlign: TextAlign.center,
                          style: RiderMessagingDesignStyles.badgeText,
                        ),
                      ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    ),
  );
}

String _timeLabel(DateTime time) {
  final difference = DateTime.now().difference(time);
  if (difference.inMinutes < 1) return 'Now';
  if (difference.inHours < 1) return '${difference.inMinutes}m';
  if (difference.inDays < 1) return '${difference.inHours}h';
  return '${difference.inDays}d';
}
