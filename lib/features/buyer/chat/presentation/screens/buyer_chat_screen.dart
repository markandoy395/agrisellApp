import 'dart:async';

import 'package:flutter/material.dart';

import 'package:agresell_app/core/theme/agrisellColors.dart';
import 'package:agresell_app/features/buyer/chat/presentation/widgets/buyer_chat_header.dart';
import 'package:agresell_app/features/buyer/chat/presentation/widgets/buyer_chat_message_widgets.dart';
import 'package:agresell_app/features/shared/chat/domain/marketplace_conversation.dart';
import 'package:agresell_app/features/shared/chat/presentation/controllers/marketplace_messaging_controller.dart';

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
          BuyerChatHeader(thread: widget.thread, onBack: widget.onBack),
          Expanded(
            child: isLoading && messages.isEmpty
                ? const _ChatLoading()
                : error != null && messages.isEmpty
                ? _ChatLoadError(
                    message: error,
                    onRetry: () => controller.openConversation(
                      widget.thread.id,
                      refresh: true,
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
                      if (messages.isEmpty) const _NoMessagesYet(),
                      for (final message in messages) ...[
                        BuyerChatBubble(
                          message: message,
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
          BuyerMessageComposer(
            controller: _messageController,
            onSend: _sendMessage,
            isSending: controller.isSending(widget.thread.id),
            bottomPadding: widget.bottomPadding,
          ),
        ],
      ),
    );
  }
}

class _ChatLoading extends StatelessWidget {
  const _ChatLoading();

  @override
  Widget build(BuildContext context) => Center(
    child: Semantics(
      label: 'Loading messages',
      child: const CircularProgressIndicator(color: AgrisellColors.authGreen),
    ),
  );
}

class _ChatLoadError extends StatelessWidget {
  const _ChatLoadError({required this.message, required this.onRetry});

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) => Center(
    child: Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.cloud_off_rounded, color: AgrisellColors.authGreen),
          const SizedBox(height: 8),
          Text(
            message,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: AgrisellColors.mutedText,
              fontSize: 12,
            ),
          ),
          const SizedBox(height: 10),
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

class _NoMessagesYet extends StatelessWidget {
  const _NoMessagesYet();

  @override
  Widget build(BuildContext context) => const Padding(
    padding: EdgeInsets.symmetric(vertical: 30),
    child: Column(
      children: [
        Icon(
          Icons.waving_hand_outlined,
          color: AgrisellColors.authGreen,
          size: 30,
        ),
        SizedBox(height: 8),
        Text(
          'Say hello to start the conversation.',
          textAlign: TextAlign.center,
          style: TextStyle(color: AgrisellColors.mutedText, fontSize: 12),
        ),
      ],
    ),
  );
}
