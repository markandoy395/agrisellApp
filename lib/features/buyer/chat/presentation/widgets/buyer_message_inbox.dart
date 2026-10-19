import 'package:flutter/material.dart';

import 'package:agresell_app/features/shared/chat/domain/marketplace_conversation.dart';
import 'package:agresell_app/features/shared/chat/presentation/controllers/marketplace_messaging_controller.dart';

import 'package:agresell_app/features/shared/chat/presentation/widgets/marketplace_message_inbox.dart';

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
  Widget build(BuildContext context) => MarketplaceMessageInbox(
    actorRole: MarketplaceActorRole.buyer,
    searchController: searchController,
    threads: threads,
    state: state,
    hasQuery: hasQuery,
    onQueryChanged: onQueryChanged,
    onThreadSelected: onThreadSelected,
    onRetry: onRetry,
  );
}
