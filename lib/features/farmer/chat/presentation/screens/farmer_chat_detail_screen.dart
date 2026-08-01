import 'dart:async';

import 'package:flutter/material.dart';

import 'package:agresell_app/core/theme/agrisellColors.dart';
import 'package:agresell_app/features/farmer/chat/presentation/widgets/farmer_message_product_preview.dart';
import 'package:agresell_app/features/shared/chat/domain/marketplace_conversation.dart';
import 'package:agresell_app/features/shared/chat/presentation/controllers/marketplace_messaging_controller.dart';
import 'package:agresell_app/features/shared/chat/presentation/models/chat_participant_data.dart';
import 'package:agresell_app/features/shared/chat/presentation/widgets/chat_avatar.dart';
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
    final padding = width < 380 ? 12.0 : 14.0;
    final topInset = MediaQuery.paddingOf(context).top;
    final keyboardInset = MediaQuery.viewInsetsOf(context).bottom;
    final composerBottomPadding = keyboardInset > 0
        ? 12.0
        : widget.bottomClearance;

    return ColoredBox(
      color: AgrisellColors.homeBackground,
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
            style: ChatDetailHeaderStyle(
              padding: EdgeInsets.fromLTRB(
                6,
                (topInset > 0 ? topInset : 24) + 8,
                14,
                12,
              ),
              decoration: BoxDecoration(
                color: AgrisellColors.authGreen,
                boxShadow: [
                  BoxShadow(
                    color: AgrisellColors.brandBlack.withValues(alpha: 0.14),
                    blurRadius: 14,
                    offset: const Offset(0, 5),
                  ),
                ],
              ),
              avatarStyle: const ChatAvatarStyle(
                diameter: 40,
                backgroundColor: AgrisellColors.surface,
                foregroundColor: AgrisellColors.authGreen,
                textStyle: TextStyle(fontSize: 13, fontWeight: FontWeight.w800),
              ),
              titleStyle: const TextStyle(
                color: AgrisellColors.surface,
                fontSize: 15,
                height: 1.1,
                fontWeight: FontWeight.w800,
              ),
              subtitleStyle: TextStyle(
                color: AgrisellColors.surface.withValues(alpha: 0.88),
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
              subtitleSpacing: 4,
            ),
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
                    style: const ChatContentStateStyle(
                      padding: EdgeInsets.zero,
                    ),
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
                          style: ChatContentStateStyle(
                            padding: EdgeInsets.symmetric(vertical: 28),
                          ),
                        ),
                      for (final message in messages) ...[
                        ChatMessageBubble(
                          message: message,
                          currentActorRole: MarketplaceActorRole.farmer,
                          style: const ChatMessageBubbleStyle(
                            statusTextStyle: TextStyle(
                              fontSize: 12,
                              height: 1,
                              fontWeight: FontWeight.w600,
                            ),
                            statusMaxLines: 1,
                            statusOverflow: TextOverflow.ellipsis,
                          ),
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
            style: ChatMessageComposerStyle(
              padding: EdgeInsets.fromLTRB(12, 9, 12, composerBottomPadding),
              decoration: BoxDecoration(
                color: AgrisellColors.surface,
                boxShadow: [
                  BoxShadow(
                    color: AgrisellColors.brandBlack.withValues(alpha: 0.08),
                    blurRadius: 14,
                    offset: const Offset(0, -5),
                  ),
                ],
              ),
              hintText: 'Type a reply',
              minLines: 1,
              maxLines: 3,
              sendButtonSize: const Size(40, 40),
              inputDecoration: InputDecoration(
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 13,
                  vertical: 10,
                ),
                border: _inputBorder(AgrisellColors.borderLine),
                enabledBorder: _inputBorder(AgrisellColors.borderLine),
                focusedBorder: _inputBorder(AgrisellColors.authGreen),
              ),
            ),
          ),
        ],
      ),
    );
  }

  OutlineInputBorder _inputBorder(Color color) {
    return OutlineInputBorder(
      borderRadius: BorderRadius.circular(22),
      borderSide: BorderSide(color: color),
    );
  }
}
