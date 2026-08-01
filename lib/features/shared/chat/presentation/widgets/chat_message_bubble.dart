import 'package:flutter/material.dart';

import 'package:agresell_app/core/theme/agrisellColors.dart';
import 'package:agresell_app/features/shared/chat/domain/marketplace_conversation.dart';

class ChatMessageBubbleStyle {
  const ChatMessageBubbleStyle({
    this.statusTextStyle = const TextStyle(fontSize: 12),
    this.statusMaxLines,
    this.statusOverflow,
  });

  final TextStyle statusTextStyle;
  final int? statusMaxLines;
  final TextOverflow? statusOverflow;
}

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
                  decoration: BoxDecoration(
                    color: background,
                    borderRadius: radius,
                    border: failed
                        ? Border.all(color: AgrisellColors.statusRedText)
                        : null,
                  ),
                  child: Text(
                    message.text,
                    style: TextStyle(
                      color: textColor,
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
                  maxLines: style.statusMaxLines,
                  overflow: style.statusOverflow,
                  style: style.statusTextStyle.copyWith(
                    color: failed
                        ? AgrisellColors.statusRedText
                        : AgrisellColors.mutedText,
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
