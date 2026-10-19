import 'package:flutter/material.dart';

import 'package:agresell_app/features/farmer/chat/presentation/widgets/message_filter_tabs.dart';
import 'package:agresell_app/features/shared/chat/domain/marketplace_conversation.dart';
import 'package:agresell_app/features/shared/chat/presentation/controllers/marketplace_messaging_controller.dart';

import 'package:agresell_app/features/shared/chat/presentation/widgets/marketplace_message_inbox.dart';

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
    final padding = MediaQuery.sizeOf(context).width < 380 ? 12.0 : 14.0;
    return MarketplaceMessageInbox(
      actorRole: MarketplaceActorRole.farmer,
      searchController: searchController,
      threads: threads,
      state: state,
      hasQuery: searchController.text.trim().isNotEmpty,
      onQueryChanged: onQueryChanged,
      onThreadSelected: onThreadSelected,
      onRetry: onRetry,
      filters: Padding(
        padding: EdgeInsets.fromLTRB(padding, 14, padding, 12),
        child: MessageFilterTabs(
          activeFilter: activeFilter,
          onChanged: onFilterChanged,
        ),
      ),
      emptyTitle: 'No ${activeFilter.label.toLowerCase()} messages',
      emptyMessage:
          'Buyer conversations connected to products and orders will appear here.',
    );
  }
}
