import 'dart:async';

import 'package:flutter/material.dart';

import 'package:agresell_app/core/theme/agrisell_colors.dart';
import 'package:agresell_app/features/buyer/chat/presentation/widgets/buyer_chat_product_context.dart';
import 'package:agresell_app/features/shared/chat/domain/marketplace_conversation.dart';
import 'package:agresell_app/features/shared/chat/presentation/controllers/marketplace_messaging_controller.dart';
import 'package:agresell_app/features/shared/chat/presentation/models/chat_participant_data.dart';
import 'package:agresell_app/features/shared/chat/presentation/widgets/chat_avatar.dart';
import 'package:agresell_app/features/shared/chat/presentation/widgets/chat_content_state.dart';
import 'package:agresell_app/features/shared/chat/presentation/widgets/chat_detail_header.dart';
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
    final messages = controller.messagesFor(widget.thread.id);
    final isLoading = controller.isLoadingMessages(widget.thread.id);
    final error = controller.messageErrorFor(widget.thread.id);

    return ColoredBox(
      color: AgrisellColors.homeBackground,
      child: Column(
        children: [
          ChatDetailHeader(
            participant: ChatParticipantData(
              name: widget.thread.farmerName,
              initials: marketplaceInitials(widget.thread.farmerName),
              imageUrl: widget.thread.farmerImageUrl,
              imageSemanticLabel: '${widget.thread.farmerName} profile photo',
            ),
            subtitle: widget.thread.farmName,
            onBack: widget.onBack,
            style: ChatDetailHeaderStyle(
              padding: EdgeInsets.fromLTRB(
                4,
                MediaQuery.paddingOf(context).top + 8,
                14,
                10,
              ),
              decoration: const BoxDecoration(color: AgrisellColors.authGreen),
              avatarStyle: const ChatAvatarStyle(
                diameter: 40,
                backgroundColor: AgrisellColors.surface,
                foregroundColor: AgrisellColors.authGreen,
                textStyle: TextStyle(fontSize: 13, fontWeight: FontWeight.w800),
              ),
              titleStyle: const TextStyle(
                color: AgrisellColors.surface,
                fontSize: 15,
                fontWeight: FontWeight.w800,
              ),
              subtitleStyle: const TextStyle(
                color: AgrisellColors.surface,
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
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
                      BuyerChatProductContext(thread: widget.thread),
                      const SizedBox(height: 18),
                      if (messages.isEmpty)
                        const ChatContentState(
                          data: ChatContentStateData(
                            icon: Icons.waving_hand_outlined,
                            message: 'Say hello to start the conversation.',
                          ),
                          style: ChatContentStateStyle(
                            padding: EdgeInsets.symmetric(vertical: 30),
                            iconSize: 30,
                            iconSpacing: 8,
                          ),
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
          ChatMessageComposer(
            controller: _messageController,
            onSend: _sendMessage,
            isSending: controller.isSending(widget.thread.id),
            style: ChatMessageComposerStyle(
              padding: EdgeInsets.fromLTRB(12, 8, 12, widget.bottomPadding),
              decoration: const BoxDecoration(color: AgrisellColors.surface),
              hintText: 'Write a message',
              inputDecoration: InputDecoration(
                hintStyle: const TextStyle(fontSize: 13),
                isDense: true,
                filled: true,
                fillColor: AgrisellColors.fieldFill,
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 11,
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(22),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
