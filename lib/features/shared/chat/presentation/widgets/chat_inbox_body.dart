import 'package:flutter/material.dart';

import 'package:agresell_app/core/theme/agrisell_colors.dart';
import 'package:agresell_app/features/shared/chat/domain/marketplace_conversation.dart';
import 'package:agresell_app/features/shared/chat/presentation/controllers/marketplace_messaging_controller.dart';
import 'package:agresell_app/features/shared/chat/presentation/models/chat_participant_data.dart';
import 'package:agresell_app/features/shared/chat/presentation/widgets/chat_content_state.dart';
import 'package:agresell_app/features/shared/chat/presentation/widgets/chat_conversation_tile.dart';

typedef ChatConversationTileDataBuilder =
    ChatConversationTileData Function(MarketplaceConversation conversation);

class ChatInboxBody extends StatelessWidget {
  const ChatInboxBody({
    required this.state,
    required this.conversations,
    required this.dataBuilder,
    required this.onConversationSelected,
    required this.onRefresh,
    required this.emptyState,
    required this.failureState,
    this.avatarTextHeight,
    super.key,
  });

  final MarketplaceMessagingLoadState state;
  final List<MarketplaceConversation> conversations;
  final ChatConversationTileDataBuilder dataBuilder;
  final ValueChanged<MarketplaceConversation> onConversationSelected;
  final Future<void> Function() onRefresh;
  final Widget emptyState;
  final Widget failureState;
  final double? avatarTextHeight;

  @override
  Widget build(BuildContext context) => switch (state) {
    MarketplaceMessagingLoadState.initial ||
    MarketplaceMessagingLoadState.loading => const ChatLoadingState(
      semanticLabel: 'Loading conversations',
    ),
    MarketplaceMessagingLoadState.error => failureState,
    MarketplaceMessagingLoadState.ready =>
      conversations.isEmpty
          ? emptyState
          : RefreshIndicator(
              color: AgrisellColors.authGreen,
              onRefresh: onRefresh,
              child: ListView.separated(
                physics: const AlwaysScrollableScrollPhysics(),
                keyboardDismissBehavior:
                    ScrollViewKeyboardDismissBehavior.onDrag,
                padding: const EdgeInsets.fromLTRB(0, 4, 0, 112),
                itemCount: conversations.length,
                separatorBuilder: (_, _) => const SizedBox.shrink(),
                itemBuilder: (context, index) {
                  final conversation = conversations[index];
                  return ChatConversationTile(
                    data: dataBuilder(conversation),
                    avatarTextHeight: avatarTextHeight,
                    onTap: () => onConversationSelected(conversation),
                  );
                },
              ),
            ),
  };
}
