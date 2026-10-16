import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:agresell_app/core/utils/agrisell_page_route.dart';
import '../../domain/rider_communication_models.dart';
import '../../domain/rider_conversation_access.dart';
import '../controllers/rider_messages_controller.dart';
import '../styles/rider_messaging_design_styles.dart';
import '../widgets/rider_chat_panel.dart';
import '../widgets/rider_messages_header.dart';
import '../widgets/rider_messages_inbox.dart';

class RiderMessagesScreen extends StatefulWidget {
  const RiderMessagesScreen({
    this.riderId = '',
    this.controller,
    this.onAction,
    this.onOpenNotifications,
    this.unreadNotifications = 0,
    this.access = const RiderConversationAccess(),
    super.key,
  });
  final String riderId;
  final RiderMessagesController? controller;
  final RiderCommunicationActionCallback? onAction;
  final VoidCallback? onOpenNotifications;
  final int unreadNotifications;
  final RiderConversationAccess access;

  @override
  State<RiderMessagesScreen> createState() => _RiderMessagesScreenState();
}

class _RiderMessagesScreenState extends State<RiderMessagesScreen> {
  late final RiderMessagesController _controller;
  late final bool _ownsController;

  @override
  void initState() {
    super.initState();
    _ownsController = widget.controller == null;
    _controller = widget.controller ?? RiderMessagesController();
    unawaited(_reload());
  }

  Future<void> _reload() =>
      _controller.load(riderId: widget.riderId, access: widget.access);

  @override
  void didUpdateWidget(covariant RiderMessagesScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.riderId != widget.riderId ||
        oldWidget.access.supportAuthorized != widget.access.supportAuthorized ||
        !setEquals(
          oldWidget.access.activeDeliveryIds,
          widget.access.activeDeliveryIds,
        ) ||
        !setEquals(
          oldWidget.access.historyDeliveryIds,
          widget.access.historyDeliveryIds,
        )) {
      unawaited(_reload());
    }
  }

  @override
  void dispose() {
    if (_ownsController) _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => ColoredBox(
    color: RiderMessagingDesignStyles.background,
    child: Column(
      children: [
        RiderMessagesHeader(
          onNotifications: widget.onOpenNotifications,
          unreadCount: widget.unreadNotifications,
        ),
        Expanded(
          child: RiderMessagesInbox(
            controller: _controller,
            onOpen: _openConversation,
            onRetry: _reload,
          ),
        ),
      ],
    ),
  );

  Future<void> _openConversation(RiderConversation conversation) async {
    await _controller.selectConversation(conversation);
    if (!mounted || _controller.selectedConversation?.id != conversation.id)
      return;
    await Navigator.of(context).push(
      agrisellPageRoute<void>(
        builder: (_) => RiderConversationPanel(
          controller: _controller,
          quickReplies: RiderQuickReply.defaults,
          onAction: widget.onAction,
        ),
      ),
    );
    if (mounted) _controller.closeConversation();
  }
}
