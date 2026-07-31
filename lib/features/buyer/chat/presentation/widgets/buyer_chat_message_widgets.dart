import 'package:flutter/material.dart';

import 'package:agresell_app/core/theme/agrisellColors.dart';
import 'package:agresell_app/features/shared/chat/domain/marketplace_conversation.dart';

class BuyerChatBubble extends StatelessWidget {
  const BuyerChatBubble({required this.message, this.onRetry, super.key});

  final MarketplaceMessage message;
  final VoidCallback? onRetry;

  @override
  Widget build(BuildContext context) {
    final isBuyer = message.isBuyer;
    final failed = message.state == MarketplaceMessageState.failed;
    final sending = message.state == MarketplaceMessageState.sending;
    final radius = BorderRadius.only(
      topLeft: const Radius.circular(16),
      topRight: const Radius.circular(16),
      bottomLeft: Radius.circular(isBuyer ? 16 : 4),
      bottomRight: Radius.circular(isBuyer ? 4 : 16),
    );
    final status = failed
        ? 'Not sent - Tap to retry'
        : sending
        ? 'Sending...'
        : isBuyer
        ? 'Sent ${message.timeLabel}'
        : message.timeLabel;
    return Align(
      alignment: isBuyer ? Alignment.centerRight : Alignment.centerLeft,
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxWidth: MediaQuery.sizeOf(context).width * 0.72,
        ),
        child: Semantics(
          button: failed,
          label: failed ? 'Message failed. Tap to retry.' : null,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: isBuyer
                ? CrossAxisAlignment.end
                : CrossAxisAlignment.start,
            children: [
              InkWell(
                onTap: failed ? onRetry : null,
                borderRadius: radius,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 13,
                    vertical: 10,
                  ),
                  decoration: BoxDecoration(
                    color: failed
                        ? AgrisellColors.statusRedBackground
                        : isBuyer
                        ? AgrisellColors.authGreen
                        : AgrisellColors.fieldFill,
                    borderRadius: radius,
                    border: failed
                        ? Border.all(color: AgrisellColors.statusRedText)
                        : null,
                  ),
                  child: Text(
                    message.text,
                    style: TextStyle(
                      color: failed
                          ? AgrisellColors.statusRedText
                          : isBuyer
                          ? AgrisellColors.surface
                          : AgrisellColors.brandBlack,
                      fontSize: 12,
                      height: 1.32,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 4),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4),
                child: Text(
                  status,
                  style: TextStyle(
                    color: failed
                        ? AgrisellColors.statusRedText
                        : AgrisellColors.mutedText,
                    fontSize: 12,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class BuyerMessageComposer extends StatelessWidget {
  const BuyerMessageComposer({
    required this.controller,
    required this.onSend,
    this.isSending = false,
    this.bottomPadding = 96,
    super.key,
  });

  final TextEditingController controller;
  final VoidCallback onSend;
  final bool isSending;
  final double bottomPadding;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.fromLTRB(12, 8, 12, bottomPadding),
      color: AgrisellColors.surface,
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: controller,
              onSubmitted: (_) => onSend(),
              textInputAction: TextInputAction.send,
              maxLength: 1000,
              style: const TextStyle(fontSize: 13),
              decoration: InputDecoration(
                hintText: 'Write a message',
                counterText: '',
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
          const SizedBox(width: 8),
          IconButton.filled(
            onPressed: isSending ? null : onSend,
            tooltip: 'Send message',
            icon: const Icon(Icons.send_rounded, size: 20),
            style: IconButton.styleFrom(
              backgroundColor: AgrisellColors.authGreen,
              disabledBackgroundColor: AgrisellColors.mutedText,
              foregroundColor: AgrisellColors.surface,
            ),
          ),
        ],
      ),
    );
  }
}
