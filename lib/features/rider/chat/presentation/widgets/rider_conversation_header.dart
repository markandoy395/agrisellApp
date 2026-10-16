import 'package:flutter/material.dart';
import 'package:agresell_app/core/theme/agrisell_colors.dart';
import '../../domain/rider_communication_models.dart';
import '../styles/rider_messaging_design_styles.dart';
import 'rider_conversation_avatar.dart';

class RiderConversationHeader extends StatelessWidget {
  const RiderConversationHeader({
    required this.conversation,
    required this.onSafety,
    super.key,
  });
  final RiderConversation conversation;
  final VoidCallback onSafety;

  @override
  Widget build(BuildContext context) => SafeArea(
    bottom: false,
    child: Padding(
      padding: const EdgeInsets.fromLTRB(4, 12, 12, 16),
      child: Row(
        children: [
          IconButton(
            tooltip: 'Back',
            onPressed: () => Navigator.of(context).pop(),
            icon: const Icon(
              Icons.arrow_back_ios_new_rounded,
              size: 20,
              color: AgrisellColors.headingGreen,
            ),
          ),
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
                Text(
                  '${conversation.party.label} / Delivery chat',
                  style: RiderMessagingDesignStyles.caption,
                ),
              ],
            ),
          ),
          PopupMenuButton<String>(
            tooltip: 'Conversation options',
            onSelected: (_) => onSafety(),
            icon: const Icon(
              Icons.more_horiz_rounded,
              color: AgrisellColors.headingGreen,
            ),
            itemBuilder: (_) => const [
              PopupMenuItem(value: 'safety', child: Text('Safety and support')),
            ],
          ),
        ],
      ),
    ),
  );
}
