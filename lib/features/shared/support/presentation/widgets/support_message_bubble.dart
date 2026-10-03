import 'package:flutter/material.dart';

import '../styles/support_ticket_detail_styles.dart';
import 'package:agresell_app/features/shared/support/domain/support_message.dart';
import '../utils/support_date_time_formatter.dart';

class SupportMessageBubble extends StatelessWidget {
  const SupportMessageBubble({super.key, required this.message});
  final SupportMessage message;

  @override
  Widget build(BuildContext context) {
    final msg = message;
    if (msg.senderRole.isSystem) {
      return Padding(
        padding: SupportTicketDetailStyles.systemMargin,
        child: Center(
          child: Container(
            padding: SupportTicketDetailStyles.systemPadding,
            decoration: SupportTicketDetailStyles.systemBubble,
            child: Text(
              msg.body,
              style: SupportTicketDetailStyles.systemMessage,
              textAlign: TextAlign.center,
            ),
          ),
        ),
      );
    }

    final isUser = msg.senderRole.isFromCustomer;

    return Padding(
      padding: SupportTicketDetailStyles.messageMargin,
      child: Row(
        mainAxisAlignment: isUser
            ? MainAxisAlignment.end
            : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (!isUser) ...[
            CircleAvatar(
              radius: 16,
              backgroundColor: SupportTicketDetailStyles.avatarBackground,
              child: const Icon(
                Icons.support_agent_rounded,
                size: 18,
                color: SupportTicketDetailStyles.green,
              ),
            ),
            const SizedBox(width: 8),
          ],
          Flexible(
            child: Column(
              crossAxisAlignment: isUser
                  ? CrossAxisAlignment.end
                  : CrossAxisAlignment.start,
              children: [
                if (!isUser)
                  Padding(
                    padding: SupportTicketDetailStyles.senderPadding,
                    child: Text(
                      msg.senderName,
                      style: SupportTicketDetailStyles.senderName,
                    ),
                  ),
                Container(
                  padding: SupportTicketDetailStyles.bubblePadding,
                  decoration: isUser
                      ? SupportTicketDetailStyles.userBubble
                      : SupportTicketDetailStyles.supportBubble,
                  child: Text(
                    msg.body,
                    style: isUser
                        ? SupportTicketDetailStyles.userMessage
                        : SupportTicketDetailStyles.supportMessage,
                  ),
                ),
                Padding(
                  padding: SupportTicketDetailStyles.timestampPadding,
                  child: Text(
                    formatSupportDateTime(msg.createdAt),
                    style: SupportTicketDetailStyles.messageTime,
                  ),
                ),
              ],
            ),
          ),
          if (isUser) const SizedBox(width: 4),
        ],
      ),
    );
  }
}
