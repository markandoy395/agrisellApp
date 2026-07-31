import 'package:flutter/material.dart';

import 'package:agresell_app/core/theme/agrisellColors.dart';
import 'package:agresell_app/features/farmer/chat/presentation/widgets/farmer_message_card.dart';
import 'package:agresell_app/features/farmer/chat/presentation/widgets/farmer_message_empty_state.dart';
import 'package:agresell_app/features/farmer/chat/presentation/widgets/farmer_message_header.dart';
import 'package:agresell_app/features/farmer/chat/presentation/widgets/message_filter_tabs.dart';
import 'package:agresell_app/features/shared/chat/domain/marketplace_conversation.dart';
import 'package:agresell_app/features/shared/chat/presentation/controllers/marketplace_messaging_controller.dart';

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
          FarmerMessageHeader(
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
          Expanded(child: _content()),
        ],
      ),
    );
  }

  Widget _content() => switch (state) {
    MarketplaceMessagingLoadState.initial ||
    MarketplaceMessagingLoadState.loading => const Center(
      child: CircularProgressIndicator(color: AgrisellColors.authGreen),
    ),
    MarketplaceMessagingLoadState.error => _InboxFailure(onRetry: onRetry),
    MarketplaceMessagingLoadState.ready =>
      threads.isEmpty
          ? FarmerMessageEmptyState(filter: activeFilter)
          : RefreshIndicator(
              color: AgrisellColors.authGreen,
              onRefresh: onRetry,
              child: ListView.separated(
                physics: const AlwaysScrollableScrollPhysics(),
                keyboardDismissBehavior:
                    ScrollViewKeyboardDismissBehavior.onDrag,
                padding: const EdgeInsets.fromLTRB(0, 4, 0, 112),
                itemCount: threads.length,
                separatorBuilder: (_, _) => const SizedBox.shrink(),
                itemBuilder: (context, index) {
                  final thread = threads[index];
                  return FarmerMessageCard(
                    thread: thread,
                    isRead: !thread.hasUnread,
                    onTap: () => onThreadSelected(thread),
                  );
                },
              ),
            ),
  };
}

class _InboxFailure extends StatelessWidget {
  const _InboxFailure({required this.onRetry});
  final Future<void> Function() onRetry;

  @override
  Widget build(BuildContext context) => Center(
    child: Padding(
      padding: const EdgeInsets.fromLTRB(24, 24, 24, 100),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(
            Icons.cloud_off_rounded,
            color: AgrisellColors.authGreen,
            size: 34,
          ),
          const SizedBox(height: 10),
          const Text(
            'Messages are unavailable',
            style: TextStyle(
              color: AgrisellColors.headingGreen,
              fontSize: 14,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 5),
          const Text(
            'Check your connection, then try loading buyer conversations again.',
            textAlign: TextAlign.center,
            style: TextStyle(color: AgrisellColors.mutedText, fontSize: 12),
          ),
          const SizedBox(height: 12),
          SizedBox(
            height: 36,
            child: OutlinedButton(
              onPressed: onRetry,
              child: const Text('Try again'),
            ),
          ),
        ],
      ),
    ),
  );
}
