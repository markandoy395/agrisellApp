import 'dart:async';

import 'package:flutter/material.dart';

import 'package:agresell_app/core/theme/agrisellColors.dart';
import 'package:agresell_app/features/farmer/chat/presentation/widgets/farmer_chat_bubble.dart';
import 'package:agresell_app/features/farmer/chat/presentation/widgets/farmer_chat_header.dart';
import 'package:agresell_app/features/farmer/chat/presentation/widgets/farmer_message_input_bar.dart';
import 'package:agresell_app/features/farmer/chat/presentation/widgets/farmer_message_product_preview.dart';
import 'package:agresell_app/features/shared/chat/domain/marketplace_conversation.dart';
import 'package:agresell_app/features/shared/chat/presentation/controllers/marketplace_messaging_controller.dart';

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
    final padding = width < 380 ? 12.0 : 14.0;

    return ColoredBox(
      color: AgrisellColors.homeBackground,
      child: Column(
        children: [
          FarmerChatHeader(thread: widget.thread, onBack: widget.onBack),
          Expanded(
            child: loading && messages.isEmpty
                ? const Center(child: CircularProgressIndicator())
                : error != null && messages.isEmpty
                ? _LoadError(
                    onRetry: () => controller.openConversation(
                      widget.thread.id,
                      refresh: true,
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
                      if (messages.isEmpty) const _NoMessagesYet(),
                      for (final message in messages) ...[
                        FarmerChatBubble(
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
          FarmerMessageInputBar(
            bottomClearance: widget.bottomClearance,
            controller: _messageController,
            onSend: _send,
            isSending: controller.isSending(widget.thread.id),
          ),
        ],
      ),
    );
  }
}

class _LoadError extends StatelessWidget {
  const _LoadError({required this.onRetry});
  final VoidCallback onRetry;
  @override
  Widget build(BuildContext context) => Center(
    child: SizedBox(
      height: 36,
      child: OutlinedButton.icon(
        onPressed: onRetry,
        icon: const Icon(Icons.refresh_rounded, size: 17),
        label: const Text('Load messages'),
      ),
    ),
  );
}

class _NoMessagesYet extends StatelessWidget {
  const _NoMessagesYet();
  @override
  Widget build(BuildContext context) => const Padding(
    padding: EdgeInsets.symmetric(vertical: 28),
    child: Text(
      'Reply when you are ready to help this buyer.',
      textAlign: TextAlign.center,
      style: TextStyle(color: AgrisellColors.mutedText, fontSize: 12),
    ),
  );
}
