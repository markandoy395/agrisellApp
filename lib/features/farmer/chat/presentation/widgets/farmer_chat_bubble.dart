import 'package:flutter/material.dart';

import 'package:agresell_app/core/theme/agrisellColors.dart';
import 'package:agresell_app/features/shared/chat/domain/marketplace_conversation.dart';

class FarmerChatBubble extends StatelessWidget {
  const FarmerChatBubble({required this.message, this.onRetry, super.key});

  final MarketplaceMessage message;
  final VoidCallback? onRetry;

  @override
  Widget build(BuildContext context) {
    final isFarmer = message.isFarmer;
    final failed = message.state == MarketplaceMessageState.failed;
    final sending = message.state == MarketplaceMessageState.sending;
    final background = failed
        ? AgrisellColors.statusRedBackground
        : isFarmer
        ? AgrisellColors.authGreen
        : AgrisellColors.fieldFill;
    final textColor = failed
        ? AgrisellColors.statusRedText
        : isFarmer
        ? AgrisellColors.surface
        : AgrisellColors.brandBlack;
    final status = failed
        ? 'Not sent - Tap to retry'
        : sending
        ? 'Sending...'
        : isFarmer
        ? 'Sent ${message.timeLabel}'
        : message.timeLabel;
    final radius = BorderRadius.only(
      topLeft: const Radius.circular(16),
      topRight: const Radius.circular(16),
      bottomLeft: Radius.circular(isFarmer ? 16 : 4),
      bottomRight: Radius.circular(isFarmer ? 4 : 16),
    );

    return Align(
      alignment: isFarmer ? Alignment.centerRight : Alignment.centerLeft,
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxWidth: MediaQuery.sizeOf(context).width * 0.72,
        ),
        child: Semantics(
          button: failed,
          label: failed ? 'Message failed. Tap to retry.' : null,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: isFarmer
                ? CrossAxisAlignment.end
                : CrossAxisAlignment.start,
            children: [
              InkWell(
                onTap: failed ? onRetry : null,
                borderRadius: radius,
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    color: background,
                    borderRadius: radius,
                    border: failed
                        ? Border.all(color: AgrisellColors.statusRedText)
                        : null,
                  ),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 13,
                      vertical: 10,
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
              ),
              const SizedBox(height: 4),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4),
                child: Text(
                  status,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: failed
                        ? AgrisellColors.statusRedText
                        : AgrisellColors.mutedText,
                    fontSize: 12,
                    height: 1,
                    fontWeight: FontWeight.w600,
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
