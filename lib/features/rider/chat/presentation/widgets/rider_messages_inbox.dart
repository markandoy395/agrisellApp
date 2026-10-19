import 'package:flutter/material.dart';
import 'package:agresell_app/features/shared/chat/presentation/widgets/chat_loading_skeleton.dart';
import '../../domain/rider_communication_state.dart';
import 'package:agresell_app/core/theme/agrisell_colors.dart';
import '../../domain/rider_communication_models.dart';
import '../controllers/rider_messages_controller.dart';
import '../styles/rider_messages_screen_styles.dart';
import '../styles/rider_messaging_design_styles.dart';
import 'rider_conversation_card.dart';
import 'rider_messages_status.dart';

enum _InboxFilter { all, unread, support }

class RiderMessagesInbox extends StatefulWidget {
  const RiderMessagesInbox({
    required this.controller,
    required this.onOpen,
    required this.onRetry,
    super.key,
  });
  final RiderMessagesController controller;
  final ValueChanged<RiderConversation> onOpen;
  final Future<void> Function() onRetry;

  @override
  State<RiderMessagesInbox> createState() => _RiderMessagesInboxState();
}

class _RiderMessagesInboxState extends State<RiderMessagesInbox> {
  final _search = TextEditingController();
  var _filter = _InboxFilter.all;

  @override
  void dispose() {
    _search.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => AnimatedBuilder(
    animation: widget.controller,
    builder: (context, _) {
      final all = widget.controller.conversations;
      final loading =
          all.isEmpty &&
          widget.controller.state == RiderCommunicationLoadState.loading;
      final query = _search.text.trim().toLowerCase();
      final filtered = all
          .where(
            (conversation) =>
                (_filter != _InboxFilter.unread ||
                    conversation.unreadCount > 0) &&
                (_filter != _InboxFilter.support ||
                    conversation.party == RiderConversationParty.support) &&
                (conversation.participantLabel.toLowerCase().contains(query) ||
                    (conversation.lastMessagePreview ?? '')
                        .toLowerCase()
                        .contains(query)),
          )
          .toList();
      final unread = all
          .where((conversation) => conversation.unreadCount > 0)
          .length;
      return CustomScrollView(
        key: const PageStorageKey('rider-message-inbox'),
        slivers: [
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(18, 4, 18, 0),
            sliver: SliverToBoxAdapter(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  TextField(
                    controller: _search,
                    style: RiderMessagingDesignStyles.body,
                    onChanged: (_) => setState(() {}),
                    decoration: RiderMessagesScreenStyles.inputDecoration,
                  ),
                  const SizedBox(height: 14),
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: [
                        for (final filter in _InboxFilter.values)
                          Padding(
                            padding: const EdgeInsets.only(right: 8),
                            child: ChoiceChip(
                              shape: RiderMessagingDesignStyles.filterShape,
                              label: Text(switch (filter) {
                                _InboxFilter.all => 'All ${all.length}',
                                _InboxFilter.unread => 'Unread $unread',
                                _InboxFilter.support => 'Support',
                              }),
                              selected: _filter == filter,
                              selectedColor: AgrisellColors.authGreen,
                              backgroundColor: AgrisellColors.forestSoft,
                              labelStyle: _filter == filter
                                  ? RiderMessagingDesignStyles.badgeText
                                  : RiderMessagingDesignStyles.caption,
                              showCheckmark: false,
                              onSelected: (_) =>
                                  setState(() => _filter = filter),
                            ),
                          ),
                      ],
                    ),
                  ),
                  if (!loading)
                    RiderMessagesStatus(
                      controller: widget.controller,
                      onRetry: widget.onRetry,
                    ),
                  const SizedBox(height: 18),
                  Text(
                    'RECENT CONVERSATIONS',
                    style: RiderMessagingDesignStyles.section,
                  ),
                  const SizedBox(height: 12),
                  if (filtered.isEmpty && !loading) const RiderMessagesEmpty(),
                ],
              ),
            ),
          ),
          if (loading)
            const SliverFillRemaining(child: ChatLoadingSkeleton())
          else
            SliverPadding(
              padding: const EdgeInsets.symmetric(horizontal: 18),
              sliver: SliverList.builder(
                itemCount: filtered.length,
                itemBuilder: (context, index) => Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: RiderConversationCard(
                    key: ValueKey(filtered[index].id),
                    conversation: filtered[index],
                    onTap: () => widget.onOpen(filtered[index]),
                  ),
                ),
              ),
            ),
        ],
      );
    },
  );
}
