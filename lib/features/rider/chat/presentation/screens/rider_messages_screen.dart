import 'package:agresell_app/features/rider/chat/presentation/styles/rider_messages_screen_styles.dart';
import 'package:agresell_app/core/theme/shared_presentation_styles.dart';
import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import 'package:agresell_app/core/theme/agrisell_colors.dart';
import 'package:agresell_app/core/utils/agrisell_page_route.dart';
import 'package:agresell_app/features/rider/chat/domain/rider_communication_models.dart';
import 'package:agresell_app/features/rider/chat/domain/rider_communication_state.dart';
import 'package:agresell_app/features/rider/chat/domain/rider_conversation_access.dart';
import 'package:agresell_app/features/rider/chat/presentation/controllers/rider_messages_controller.dart';
import 'package:agresell_app/features/rider/chat/presentation/widgets/rider_chat_panel.dart';
import 'package:agresell_app/features/rider/chat/presentation/widgets/rider_conversation_list.dart';
import 'package:agresell_app/features/rider/presentation/widgets/rider_offline_state_card.dart';
import 'package:agresell_app/features/rider/presentation/widgets/rider_page_widgets.dart';
import 'package:agresell_app/features/rider/presentation/widgets/rider_state_cards.dart';

class RiderMessagesScreen extends StatefulWidget {
  const RiderMessagesScreen({
    this.riderId = '',
    this.controller,
    this.onAction,
    this.onAttachmentRequested,
    this.access = const RiderConversationAccess(),
    super.key,
  });

  final String riderId;
  final RiderMessagesController? controller;
  final RiderCommunicationActionCallback? onAction;
  final RiderCommunicationAttachmentCallback? onAttachmentRequested;
  final RiderConversationAccess access;

  @override
  State<RiderMessagesScreen> createState() => _RiderMessagesScreenState();
}

class _RiderMessagesScreenState extends State<RiderMessagesScreen> {
  late final RiderMessagesController _controller;
  late final bool _ownsController;
  final _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _ownsController = widget.controller == null;
    _controller = widget.controller ?? RiderMessagesController();
    unawaited(_controller.load(riderId: widget.riderId, access: widget.access));
  }

  @override
  void didUpdateWidget(covariant RiderMessagesScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.riderId == widget.riderId &&
        oldWidget.access.supportAuthorized == widget.access.supportAuthorized &&
        setEquals(
          oldWidget.access.activeDeliveryIds,
          widget.access.activeDeliveryIds,
        ) &&
        setEquals(
          oldWidget.access.historyDeliveryIds,
          widget.access.historyDeliveryIds,
        )) {
      return;
    }
    unawaited(_controller.load(riderId: widget.riderId, access: widget.access));
  }

  @override
  void dispose() {
    _searchController.dispose();
    if (_ownsController) _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => ColoredBox(
    color: AgrisellColors.homeBackground,
    child: Column(
      children: [
        const RiderPageHeader(
          title: 'Messages',
          subtitle: 'Protected delivery chat and customer support',
        ),
        Expanded(
          child: AnimatedBuilder(
            animation: _controller,
            builder: (context, _) => ListView(
              padding: const EdgeInsets.fromLTRB(14, 14, 14, 156),
              children: [
                TextField(
                  controller: _searchController,
                  onChanged: (_) => setState(() {}),
                  decoration: RiderMessagesScreenStyles.inputDecoration,
                ),
                const SizedBox(height: 4),
                ..._content(),
                const SizedBox(height: 12),
                const Text(
                  'Contact details remain private. Use protected in-app delivery chat.',
                  textAlign: TextAlign.center,
                  style: SharedPresentationStyles.mutedCaptionSemiboldLoose,
                ),
              ],
            ),
          ),
        ),
      ],
    ),
  );

  List<Widget> _content() {
    return switch (_controller.state) {
      RiderCommunicationLoadState.loading => const [
        SizedBox(height: 14),
        RiderLoadingStateCard(
          title: 'Loading conversations',
          message: 'Connecting your protected delivery conversations.',
        ),
      ],
      RiderCommunicationLoadState.offline => const [
        SizedBox(height: 14),
        RiderOfflineStateCard(
          title: 'Messages are offline',
          message: 'Reconnect to receive protected delivery messages.',
        ),
      ],
      RiderCommunicationLoadState.error => [
        const SizedBox(height: 14),
        RiderErrorStateCard(
          title: 'Messages unavailable',
          message: _controller.errorMessage ?? 'Please try again.',
          retryLabel: 'Retry',
          onRetry: () => unawaited(
            _controller.load(riderId: widget.riderId, access: widget.access),
          ),
        ),
      ],
      RiderCommunicationLoadState.ready => [
        RiderConversationList(
          conversations: _filteredConversations,
          onOpenConversation: _openConversation,
        ),
      ],
    };
  }

  List<RiderConversation> get _filteredConversations {
    final query = _searchController.text.trim().toLowerCase();
    if (query.isEmpty) return _controller.conversations;
    return _controller.conversations
        .where(
          (conversation) =>
              conversation.participantLabel.toLowerCase().contains(query) ||
              (conversation.lastMessagePreview ?? '').toLowerCase().contains(
                query,
              ),
        )
        .toList(growable: false);
  }

  Future<void> _openConversation(RiderConversation conversation) async {
    await _controller.selectConversation(conversation);
    if (!mounted) return;
    await Navigator.of(context).push(
      agrisellPageRoute<void>(
        builder: (_) => RiderConversationPanel(
          controller: _controller,
          quickReplies: RiderQuickReply.defaults,
          onAction: widget.onAction,
          onAttachmentRequested: widget.onAttachmentRequested,
        ),
      ),
    );
    _controller.closeConversation();
  }
}
