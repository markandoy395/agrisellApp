import 'package:flutter/material.dart';

import 'package:agresell_app/core/theme/agrisell_colors.dart';
import 'package:agresell_app/features/shared/chat/domain/marketplace_conversation.dart';
import 'package:agresell_app/features/shared/chat/presentation/controllers/marketplace_messaging_controller.dart';
import 'package:agresell_app/features/shared/chat/presentation/models/chat_participant_data.dart';
import 'package:agresell_app/features/shared/chat/presentation/widgets/chat_content_state.dart';
import 'package:agresell_app/features/shared/chat/presentation/widgets/chat_inbox_body.dart';
import 'package:agresell_app/features/shared/chat/presentation/widgets/chat_inbox_header.dart';

class BuyerMessageInbox extends StatelessWidget {
  const BuyerMessageInbox({
    required this.searchController,
    required this.threads,
    required this.state,
    required this.hasQuery,
    required this.onQueryChanged,
    required this.onThreadSelected,
    required this.onRetry,
    super.key,
  });

  final TextEditingController searchController;
  final List<MarketplaceConversation> threads;
  final MarketplaceMessagingLoadState state;
  final bool hasQuery;
  final ValueChanged<String> onQueryChanged;
  final ValueChanged<MarketplaceConversation> onThreadSelected;
  final Future<void> Function() onRetry;

  @override
  Widget build(BuildContext context) => ColoredBox(
    color: AgrisellColors.homeBackground,
    child: Column(
      children: [
        ChatInboxHeader(
          title: 'Chats',
          searchHint: 'Search farmers or products',
          controller: searchController,
          onQueryChanged: onQueryChanged,
        ),
        Expanded(
          child: ChatInboxBody(
            state: state,
            conversations: threads,
            dataBuilder: _tileData,
            onConversationSelected: onThreadSelected,
            onRefresh: onRetry,
            failureState: ChatContentState(
              data: const ChatContentStateData(
                icon: Icons.cloud_off_rounded,
                title: 'Messages are unavailable',
                message:
                    'Check your connection, then try loading your conversations again.',
              ),
              action: SizedBox(
                height: 36,
                child: OutlinedButton(
                  onPressed: onRetry,
                  child: const Text('Try again'),
                ),
              ),
            ),
            emptyState: ChatContentState(
              data: ChatContentStateData(
                icon: Icons.forum_outlined,
                title: hasQuery
                    ? 'No matching conversations'
                    : 'No conversations found',
                message: hasQuery
                    ? 'Try a farmer, farm, product, or message keyword.'
                    : 'Open a farmer profile to start a secure conversation.',
              ),
            ),
          ),
        ),
      ],
    ),
  );

  ChatConversationTileData _tileData(MarketplaceConversation thread) {
    return ChatConversationTileData(
      participant: ChatParticipantData(
        name: thread.farmerName,
        initials: marketplaceInitials(thread.farmerName),
        imageUrl: thread.farmerImageUrl,
        imageSemanticLabel: '${thread.farmerName} profile photo',
      ),
      previewText: thread.previewText,
      timeLabel: thread.timeLabel,
      hasUnread: thread.hasUnread,
      semanticLabel: 'Open chat with ${thread.farmerName}',
    );
  }
}
