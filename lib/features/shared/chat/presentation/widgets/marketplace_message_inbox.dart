import 'package:flutter/material.dart';

import 'package:agresell_app/core/theme/agrisell_colors.dart';
import 'package:agresell_app/features/shared/chat/domain/marketplace_conversation.dart';
import 'package:agresell_app/features/shared/chat/presentation/controllers/marketplace_messaging_controller.dart';
import 'package:agresell_app/features/shared/chat/presentation/models/chat_participant_data.dart';
import 'chat_content_state.dart';
import 'chat_inbox_body.dart';
import 'chat_inbox_header.dart';

class MarketplaceMessageInbox extends StatelessWidget {
  const MarketplaceMessageInbox({
    required this.actorRole,
    required this.searchController,
    required this.threads,
    required this.state,
    required this.hasQuery,
    required this.onQueryChanged,
    required this.onThreadSelected,
    required this.onRetry,
    this.filters,
    this.emptyTitle,
    this.emptyMessage,
    super.key,
  });

  final MarketplaceActorRole actorRole;
  final TextEditingController searchController;
  final List<MarketplaceConversation> threads;
  final MarketplaceMessagingLoadState state;
  final bool hasQuery;
  final ValueChanged<String> onQueryChanged;
  final ValueChanged<MarketplaceConversation> onThreadSelected;
  final Future<void> Function() onRetry;
  final Widget? filters;
  final String? emptyTitle;
  final String? emptyMessage;

  bool get _isBuyer => actorRole == MarketplaceActorRole.buyer;

  @override
  Widget build(BuildContext context) => ColoredBox(
    color: AgrisellColors.homeBackground,
    child: Column(
      children: [
        ChatInboxHeader(
          title: 'Chats',
          searchHint: _isBuyer
              ? 'Search farmers or products'
              : 'Search buyers or products',
          controller: searchController,
          onQueryChanged: onQueryChanged,
        ),
        if (filters != null) filters!,
        Expanded(
          // Scaffold includes the floating navigation height in this safe area.
          child: SafeArea(
            top: false,
            left: false,
            right: false,
            child: ClipRect(
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
                    title:
                        emptyTitle ??
                        (hasQuery
                            ? 'No matching conversations'
                            : 'No conversations found'),
                    message:
                        emptyMessage ??
                        (hasQuery
                            ? 'Try a name, farm, product, or message keyword.'
                            : 'Open a farmer profile to start a secure conversation.'),
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    ),
  );

  ChatConversationTileData _tileData(MarketplaceConversation thread) {
    final name = _isBuyer ? thread.farmerName : thread.buyerName;
    return ChatConversationTileData(
      participant: ChatParticipantData(
        name: name,
        initials: marketplaceInitials(name),
        imageUrl: _isBuyer ? thread.farmerImageUrl : thread.buyerImageUrl,
        imageSemanticLabel: '$name profile photo',
      ),
      previewText: thread.previewText,
      timeLabel: thread.timeLabel,
      hasUnread: thread.hasUnread,
      semanticLabel: 'Open chat with $name',
    );
  }
}
