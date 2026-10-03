export 'package:agresell_app/features/shared/chat/presentation/styles/chat_message_bubble_styles.dart';

import 'package:agresell_app/features/shared/chat/presentation/styles/chat_message_bubble_styles.dart';
import 'package:flutter/material.dart';

import 'package:agresell_app/core/theme/agrisell_colors.dart';
import 'package:agresell_app/features/shared/chat/domain/marketplace_conversation.dart';

class ChatMessageBubble extends StatelessWidget {
  const ChatMessageBubble({
    required this.message,
    required this.currentActorRole,
    this.onRetry,
    this.style = const ChatMessageBubbleStyle(),
    super.key,
  });

  final MarketplaceMessage message;
  final MarketplaceActorRole currentActorRole;
  final VoidCallback? onRetry;
  final ChatMessageBubbleStyle style;

  @override
  Widget build(BuildContext context) {
    final isOwnMessage = message.senderRole == currentActorRole;
    final failed = message.state == MarketplaceMessageState.failed;
    final sending = message.state == MarketplaceMessageState.sending;
    final background = failed
        ? AgrisellColors.statusRedBackground
        : isOwnMessage
        ? AgrisellColors.authGreen
        : AgrisellColors.fieldFill;
    final textColor = failed
        ? AgrisellColors.statusRedText
        : isOwnMessage
        ? AgrisellColors.surface
        : AgrisellColors.brandBlack;
    final status = failed
        ? 'Not sent - Tap to retry'
        : sending
        ? 'Sending...'
        : isOwnMessage
        ? 'Sent ${message.timeLabel}'
        : message.timeLabel;
    final radius = BorderRadius.only(
      topLeft: const Radius.circular(16),
      topRight: const Radius.circular(16),
      bottomLeft: Radius.circular(isOwnMessage ? 16 : 4),
      bottomRight: Radius.circular(isOwnMessage ? 4 : 16),
    );

    return Align(
      alignment: isOwnMessage ? Alignment.centerRight : Alignment.centerLeft,
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxWidth: MediaQuery.sizeOf(context).width * 0.72,
        ),
        child: Semantics(
          button: failed,
          label: failed ? 'Message failed. Tap to retry.' : null,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: isOwnMessage
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
                  decoration: ChatMessageBubbleStyles.containerDecoration(
                    background,
                    radius,
                    failed,
                  ),
                  child: Text(
                    message.text,
                    style: ChatMessageBubbleStyles.textStyle(textColor),
                  ),
                ),
              ),
              const SizedBox(height: 4),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4),
                child: Text(
                  status,
                  maxLines: style.statusMaxLines,
                  overflow: style.statusOverflow,
                  style: ChatMessageBubbleStyles.statusText(style, failed),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
