import 'package:flutter/material.dart';

import '../styles/support_ticket_detail_styles.dart';
import 'package:agresell_app/features/shared/support/domain/support_ticket.dart';

class SupportReplyComposer extends StatelessWidget {
  const SupportReplyComposer({
    super.key,
    required this.ticket,
    required this.replyController,
    required this.isSending,
    required this.onSend,
  });
  final SupportTicket ticket;
  final TextEditingController replyController;
  final bool isSending;
  final VoidCallback onSend;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: SupportTicketDetailStyles.composer,
      child: SafeArea(
        top: false,
        child: Padding(
          padding: SupportTicketDetailStyles.composerPadding,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (ticket.status.isTerminal)
                Padding(
                  padding: SupportTicketDetailStyles.reopenPadding,
                  child: Row(
                    children: const [
                      Icon(
                        Icons.info_outline_rounded,
                        size: 13,
                        color: SupportTicketDetailStyles.reopenColor,
                      ),
                      SizedBox(width: 4),
                      Text(
                        'Replying will automatically re-open this ticket.',
                        style: SupportTicketDetailStyles.reopenNote,
                      ),
                    ],
                  ),
                ),
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: replyController,
                      maxLines: 4,
                      minLines: 1,
                      textCapitalization: TextCapitalization.sentences,
                      decoration: SupportTicketDetailStyles.replyInput,
                      onSubmitted: (_) => onSend(),
                    ),
                  ),
                  const SizedBox(width: 8),
                  IconButton.filled(
                    onPressed: isSending ? null : onSend,
                    style: SupportTicketDetailStyles.sendButton,
                    icon: isSending
                        ? const SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(
                              color: SupportTicketDetailStyles.white,
                              strokeWidth: 2,
                            ),
                          )
                        : const Icon(Icons.send_rounded, size: 20),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
