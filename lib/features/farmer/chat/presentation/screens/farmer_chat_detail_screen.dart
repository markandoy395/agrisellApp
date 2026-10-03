import 'dart:async';

import 'package:flutter/material.dart';

import 'package:agresell_app/features/farmer/chat/presentation/styles/farmer_chat_detail_styles.dart';
import 'package:agresell_app/features/farmer/chat/presentation/widgets/farmer_message_product_preview.dart';
import 'package:agresell_app/features/shared/chat/domain/marketplace_conversation.dart';
import 'package:agresell_app/features/shared/chat/presentation/controllers/marketplace_messaging_controller.dart';
import 'package:agresell_app/features/shared/chat/presentation/models/chat_participant_data.dart';
import 'package:agresell_app/features/shared/chat/presentation/widgets/chat_content_state.dart';
import 'package:agresell_app/features/shared/chat/presentation/widgets/chat_detail_header.dart';
import 'package:agresell_app/features/shared/chat/presentation/widgets/chat_message_bubble.dart';
import 'package:agresell_app/features/shared/chat/presentation/widgets/chat_message_composer.dart';

class FarmerChatDetailScreen extends StatefulWidget {
  const FarmerChatDetailScreen({
    required this.thread,
    required this.controller,
    required this.onBack,
    required this.bottomClearance,
    super.key,
  });

  final MarketplaceConversation thread;
  final MarketplaceMessagingController controller;
  final VoidCallback onBack;
  final double bottomClearance;

  @override
  State<FarmerChatDetailScreen> createState() => _FarmerChatDetailScreenState();
}

class _FarmerChatDetailScreenState extends State<FarmerChatDetailScreen> {
  late final TextEditingController _messageController;
  late final ScrollController _scrollController;

  @override
  void initState() {
    super.initState();
    _messageController = TextEditingController();
    _scrollController = ScrollController();
  }

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _send() async {
    final text = _messageController.text.trim();
    if (text.isEmpty || text.length > 1000) return;
    _messageController.clear();
    unawaited(_scrollAfterFrame());
    final sent = await widget.controller.sendMessage(widget.thread.id, text);
    await _scrollAfterFrame();
    if (!mounted || sent) return;
    final error =
        widget.controller.messageErrorFor(widget.thread.id) ??
        'Your reply was not sent. Tap the message to retry.';
    ScaffoldMessenger.of(context)
      ..clearSnackBars()
      ..showSnackBar(SnackBar(content: Text(error)));
  }

  Future<void> _scrollAfterFrame() async {
    await Future<void>.delayed(Duration.zero);
    if (!mounted || !_scrollController.hasClients) return;
    await _scrollController.animateTo(
      _scrollController.position.maxScrollExtent,
      duration: const Duration(milliseconds: 180),
      curve: Curves.easeOutCubic,
    );
  }

  @override
  Widget build(BuildContext context) {
    final controller = widget.controller;
    final messages = controller.messagesFor(widget.thread.id);
    final loading = controller.isLoadingMessages(widget.thread.id);
    final error = controller.messageErrorFor(widget.thread.id);
    final width = MediaQuery.sizeOf(context).width;
    final padding = FarmerChatDetailStyles.horizontalPadding(width);
    final topInset = MediaQuery.paddingOf(context).top;
    final keyboardInset = MediaQuery.viewInsetsOf(context).bottom;
    final composerBottomPadding = FarmerChatDetailStyles.composerBottomPadding(
      keyboardInset: keyboardInset,
      bottomClearance: widget.bottomClearance,
    );

    return ColoredBox(
      color: FarmerChatDetailStyles.backgroundColor,
      child: Column(
        children: [
          ChatDetailHeader(
            participant: ChatParticipantData(
              name: widget.thread.buyerName,
              initials: widget.thread.initials,
              imageUrl: widget.thread.buyerImageUrl,
              imageSemanticLabel: '${widget.thread.buyerName} profile photo',
            ),
            subtitle: widget.thread.contextLabel,
            onBack: widget.onBack,
            style: FarmerChatDetailStyles.headerStyle(topInset),
          ),
          Expanded(
            child: loading && messages.isEmpty
                ? const ChatLoadingState(
                    semanticLabel: 'Loading messages',
                    color: null,
                  )
                : error != null && messages.isEmpty
                ? ChatContentState(
                    data: const ChatContentStateData(),
                    style: FarmerChatDetailStyles.errorStateStyle,
                    action: SizedBox(
                      height: 36,
                      child: OutlinedButton.icon(
                        onPressed: () => controller.openConversation(
                          widget.thread.id,
                          refresh: true,
                        ),
                        icon: const Icon(Icons.refresh_rounded, size: 17),
                        label: const Text('Load messages'),
                      ),
                    ),
                  )
                : ListView(
                    controller: _scrollController,
                    keyboardDismissBehavior:
                        ScrollViewKeyboardDismissBehavior.onDrag,
                    padding: EdgeInsets.fromLTRB(padding, 14, padding, 14),
                    children: [
                      if (widget.thread.hasProductContext) ...[
                        FarmerMessageProductPreview(thread: widget.thread),
                        const SizedBox(height: 18),
                      ],
                      if (messages.isEmpty)
                        const ChatContentState(
                          data: ChatContentStateData(
                            message:
                                'Reply when you are ready to help this buyer.',
                          ),
                          style: FarmerChatDetailStyles.emptyStateStyle,
                        ),
                      for (final message in messages) ...[
                        ChatMessageBubble(
                          message: message,
                          currentActorRole: MarketplaceActorRole.farmer,
                          style: FarmerChatDetailStyles.bubbleStyle,
                          onRetry:
                              message.state == MarketplaceMessageState.failed
                              ? () => controller.retryMessage(
                                  widget.thread.id,
                                  message,
                                )
                              : null,
                        ),
                        const SizedBox(height: 10),
                      ],
                    ],
                  ),
          ),
          ChatMessageComposer(
            controller: _messageController,
            onSend: _send,
            isSending: controller.isSending(widget.thread.id),
            style: FarmerChatDetailStyles.composerStyle(composerBottomPadding),
          ),
        ],
      ),
    );
  }
}
