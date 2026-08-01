import 'package:flutter/material.dart';

import 'package:agresell_app/core/theme/agrisell_colors.dart';
import 'package:agresell_app/features/farmer/chat/presentation/widgets/message_filter_tabs.dart';
import 'package:agresell_app/features/shared/chat/domain/marketplace_conversation.dart';
import 'package:agresell_app/features/shared/chat/presentation/controllers/marketplace_messaging_controller.dart';
import 'package:agresell_app/features/shared/chat/presentation/models/chat_participant_data.dart';
import 'package:agresell_app/features/shared/chat/presentation/widgets/chat_content_state.dart';
import 'package:agresell_app/features/shared/chat/presentation/widgets/chat_inbox_body.dart';
import 'package:agresell_app/features/shared/chat/presentation/widgets/chat_inbox_header.dart';

class FarmerMessageInbox extends StatelessWidget {
  const FarmerMessageInbox({
    required this.searchController,
    required this.activeFilter,
    required this.threads,
    required this.state,
    required this.onQueryChanged,
    required this.onFilterChanged,
    required this.onThreadSelected,
    required this.onRetry,
    super.key,
  });

  final TextEditingController searchController;
  final FarmerMessageFilter activeFilter;
  final List<MarketplaceConversation> threads;
  final MarketplaceMessagingLoadState state;
  final ValueChanged<String> onQueryChanged;
  final ValueChanged<FarmerMessageFilter> onFilterChanged;
  final ValueChanged<MarketplaceConversation> onThreadSelected;
  final Future<void> Function() onRetry;

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;
    final padding = width < 380 ? 12.0 : 14.0;
    return ColoredBox(
      color: AgrisellColors.homeBackground,
      child: Column(
        children: [
          ChatInboxHeader(
            title: 'Chats',
            searchHint: 'Search buyers or products',
            controller: searchController,
            onQueryChanged: onQueryChanged,
          ),
          Padding(
            padding: EdgeInsets.fromLTRB(padding, 14, padding, 0),
            child: MessageFilterTabs(
              activeFilter: activeFilter,
              onChanged: onFilterChanged,
            ),
          ),
          Expanded(
            child: ChatInboxBody(
              state: state,
              conversations: threads,
              dataBuilder: _tileData,
              onConversationSelected: onThreadSelected,
              onRefresh: onRetry,
              avatarTextHeight: 1,
              failureState: ChatContentState(
                data: const ChatContentStateData(
                  icon: Icons.cloud_off_rounded,
                  title: 'Messages are unavailable',
                  message:
                      'Check your connection, then try loading buyer conversations again.',
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
                  title: 'No ${activeFilter.label.toLowerCase()} messages',
                  message:
                      'Buyer conversations connected to products and orders will appear here.',
                ),
                style: const ChatContentStateStyle(
                  titleStyle: TextStyle(
                    color: AgrisellColors.headingGreen,
                    fontSize: 14,
                    height: 1.2,
                    fontWeight: FontWeight.w800,
                  ),
                  messageStyle: TextStyle(
                    color: AgrisellColors.mutedText,
                    fontSize: 12,
                    height: 1.35,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  ChatConversationTileData _tileData(MarketplaceConversation thread) {
    return ChatConversationTileData(
      participant: ChatParticipantData(
        name: thread.buyerName,
        initials: thread.initials,
        imageSemanticLabel: '${thread.buyerName} profile photo',
      ),
      previewText: thread.previewText,
      timeLabel: thread.timeLabel,
      hasUnread: thread.hasUnread,
      semanticLabel: 'Open chat with ${thread.buyerName}',
    );
  }
}
