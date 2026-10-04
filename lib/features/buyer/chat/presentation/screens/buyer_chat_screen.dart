import 'dart:async';

import 'package:flutter/material.dart';

import 'package:agresell_app/features/buyer/chat/presentation/widgets/buyer_chat_product_context.dart';
import 'package:agresell_app/features/shared/chat/domain/marketplace_conversation.dart';
import 'package:agresell_app/features/shared/chat/presentation/controllers/marketplace_messaging_controller.dart';
import 'package:agresell_app/features/shared/chat/presentation/models/chat_participant_data.dart';
import 'package:agresell_app/features/shared/chat/presentation/widgets/chat_content_state.dart';
import 'package:agresell_app/features/shared/chat/presentation/widgets/chat_detail_header.dart';
import 'package:agresell_app/features/shared/chat/presentation/widgets/chat_profile_intro.dart';
import 'package:agresell_app/features/shared/chat/presentation/styles/chat_reference_styles.dart';
import 'package:agresell_app/features/shared/chat/presentation/widgets/chat_message_bubble.dart';
import 'package:agresell_app/features/shared/chat/presentation/widgets/chat_message_composer.dart';

part 'buyer_chat_screen_send.dart';

class BuyerChatScreen extends StatefulWidget {
  const BuyerChatScreen({
    required this.thread,
    required this.controller,
    required this.onBack,
    this.bottomPadding = 96,
    super.key,
  });

  final MarketplaceConversation thread;
  final MarketplaceMessagingController controller;
  final VoidCallback onBack;
  final double bottomPadding;

  @override
  State<BuyerChatScreen> createState() => _BuyerChatScreenState();
}

class _BuyerChatScreenState extends State<BuyerChatScreen> {
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

  @override
  Widget build(BuildContext context) {
    final controller = widget.controller;
    final participant = ChatParticipantData(
      name: widget.thread.farmerName,
      initials: marketplaceInitials(widget.thread.farmerName),
      imageUrl: widget.thread.farmerImageUrl,
      imageSemanticLabel: '${widget.thread.farmerName} profile photo',
    );
    final messages = controller.messagesFor(widget.thread.id);
    final isLoading = controller.isLoadingMessages(widget.thread.id);
    final error = controller.messageErrorFor(widget.thread.id);
    final keyboardIsOpen = MediaQuery.viewInsetsOf(context).bottom > 0;
    final composerBottomPadding = keyboardIsOpen ? 12.0 : widget.bottomPadding;

    return ColoredBox(
      color: ChatReferenceStyles.background,
      child: Column(
        children: [
          ChatDetailHeader(
            participant: participant,
            isEmpty: messages.isEmpty,
            subtitle: widget.thread.location,
            onBack: widget.onBack,
            style: ChatReferenceStyles.header(
              MediaQuery.paddingOf(context).top,
            ),
          ),
          Expanded(
            child: isLoading && messages.isEmpty
                ? const ChatLoadingState(semanticLabel: 'Loading messages')
                : error != null && messages.isEmpty
                ? ChatContentState(
                    data: ChatContentStateData(
                      icon: Icons.cloud_off_rounded,
                      message: error,
                    ),
                    style: const ChatContentStateStyle(
                      padding: EdgeInsets.all(24),
                      iconSize: 24,
                      iconSpacing: 8,
                      actionSpacing: 10,
                    ),
                    action: SizedBox(
                      height: 36,
                      child: OutlinedButton(
                        onPressed: () => controller.openConversation(
                          widget.thread.id,
                          refresh: true,
                        ),
                        child: const Text('Try again'),
                      ),
                    ),
                  )
                : ListView(
                    controller: _scrollController,
                    keyboardDismissBehavior:
                        ScrollViewKeyboardDismissBehavior.onDrag,
                    padding: const EdgeInsets.fromLTRB(14, 14, 14, 12),
                    children: [
                      if (messages.isNotEmpty)
                        BuyerChatProductContext(thread: widget.thread),
                      const SizedBox(height: 18),
                      if (messages.isEmpty)
                        ChatProfileIntro(
                          participant: participant,
                          subtitle: widget.thread.location,
                        ),
                      for (final message in messages) ...[
                        ChatMessageBubble(
                          message: message,
                          currentActorRole: MarketplaceActorRole.buyer,
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
          ChatSuggestedReplies(
            replies: const ['Hello!', 'Thank you', 'Any updates?'],
            onSelected: controller.isSending(widget.thread.id)
                ? null
                : (text) {
                    _messageController.text = text;
                    _sendMessage();
                  },
          ),
          ChatMessageComposer(
            controller: _messageController,
            onSend: _sendMessage,
            isSending: controller.isSending(widget.thread.id),
            style: ChatReferenceStyles.composer(
              composerBottomPadding,
              'Write a message',
            ),
          ),
        ],
      ),
    );
  }
}
