import 'package:agresell_app/core/theme/shared_presentation_styles.dart';
import 'package:flutter/material.dart';

import 'package:agresell_app/core/theme/agrisell_colors.dart';
import 'package:agresell_app/features/shared/chat/domain/marketplace_conversation.dart';
import 'package:agresell_app/features/shared/chat/presentation/models/chat_participant_data.dart';
import 'package:agresell_app/features/shared/chat/presentation/widgets/chat_avatar.dart';

class BuyerChatProductContext extends StatelessWidget {
  const BuyerChatProductContext({required this.thread, super.key});

  final MarketplaceConversation thread;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: SharedPresentationStyles.borderedSurface,
      child: Row(
        children: [
          ChatAvatar(
            participant: ChatParticipantData(
              name: thread.farmerName,
              initials: marketplaceInitials(thread.farmerName),
              imageUrl: thread.farmerImageUrl,
              imageSemanticLabel: '${thread.farmerName} profile photo',
            ),
            style: const ChatAvatarStyle(
              diameter: 44,
              backgroundColor: AgrisellColors.fieldFill,
              foregroundColor: AgrisellColors.headingGreen,
              textStyle: SharedPresentationStyles.titleBold,
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Talking about',
                  style: SharedPresentationStyles.mutedCaption,
                ),
                Text(
                  thread.contextLabel,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: SharedPresentationStyles.headingBodyBold,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
