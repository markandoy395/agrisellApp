import 'package:flutter/material.dart';

import 'package:agresell_app/core/theme/agrisellColors.dart';
import 'package:agresell_app/features/buyer/chat/presentation/widgets/buyer_message_card.dart';
import 'package:agresell_app/features/buyer/chat/presentation/widgets/buyer_message_header.dart';
import 'package:agresell_app/features/shared/chat/domain/marketplace_conversation.dart';
import 'package:agresell_app/features/shared/chat/presentation/controllers/marketplace_messaging_controller.dart';

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
  Widget build(BuildContext context) {
    return ColoredBox(
      color: AgrisellColors.homeBackground,
      child: Column(
        children: [
          BuyerMessageHeader(
            controller: searchController,
            onQueryChanged: onQueryChanged,
          ),
          Expanded(
            child: switch (state) {
              MarketplaceMessagingLoadState.initial ||
              MarketplaceMessagingLoadState.loading => const _InboxLoading(),
              MarketplaceMessagingLoadState.error => _InboxFailure(
                onRetry: onRetry,
              ),
              MarketplaceMessagingLoadState.ready =>
                threads.isEmpty
                    ? _EmptyMessages(hasQuery: hasQuery)
                    : RefreshIndicator(
                        color: AgrisellColors.authGreen,
                        onRefresh: onRetry,
                        child: ListView.separated(
                          physics: const AlwaysScrollableScrollPhysics(),
                          keyboardDismissBehavior:
                              ScrollViewKeyboardDismissBehavior.onDrag,
                          padding: EdgeInsets.fromLTRB(0, 4, 0, 112),
                          itemCount: threads.length,
                          separatorBuilder: (_, _) => const SizedBox.shrink(),
                          itemBuilder: (context, index) {
                            final thread = threads[index];
                            return BuyerMessageCard(
                              thread: thread,
                              isRead: !thread.hasUnread,
                              onTap: () => onThreadSelected(thread),
                            );
                          },
                        ),
                      ),
            },
          ),
        ],
      ),
    );
  }
}

class _InboxLoading extends StatelessWidget {
  const _InboxLoading();

  @override
  Widget build(BuildContext context) => Center(
    child: Semantics(
      label: 'Loading conversations',
      child: const CircularProgressIndicator(color: AgrisellColors.authGreen),
    ),
  );
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
            'Check your connection, then try loading your conversations again.',
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

class _EmptyMessages extends StatelessWidget {
  const _EmptyMessages({required this.hasQuery});
  final bool hasQuery;

  @override
  Widget build(BuildContext context) => Center(
    child: Padding(
      padding: const EdgeInsets.fromLTRB(24, 24, 24, 100),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(
            Icons.forum_outlined,
            color: AgrisellColors.authGreen,
            size: 34,
          ),
          const SizedBox(height: 10),
          Text(
            hasQuery ? 'No matching conversations' : 'No conversations found',
            style: const TextStyle(
              color: AgrisellColors.headingGreen,
              fontSize: 14,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 5),
          Text(
            hasQuery
                ? 'Try a farmer, farm, product, or message keyword.'
                : 'Open a farmer profile to start a secure conversation.',
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: AgrisellColors.mutedText,
              fontSize: 12,
            ),
          ),
        ],
      ),
    ),
  );
}
