import 'package:agresell_app/features/shared/support/presentation/styles/support_ticket_card_styles.dart';
import 'package:flutter/material.dart';

import 'package:agresell_app/core/theme/agrisell_colors.dart';
import 'package:agresell_app/features/shared/support/domain/support_ticket.dart';

class SupportTicketCard extends StatelessWidget {
  const SupportTicketCard({
    required this.ticket,
    required this.onTap,
    super.key,
  });

  final SupportTicket ticket;
  final VoidCallback onTap;

  String _formatTimeAgo(DateTime date) {
    final diff = DateTime.now().difference(date);
    if (diff.inSeconds < 60) return 'Just now';
    if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
    if (diff.inHours < 24) return '${diff.inHours}h ago';
    if (diff.inDays < 7) return '${diff.inDays}d ago';
    return '${date.month}/${date.day}/${date.year}';
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      elevation: 0,
      color: AgrisellColors.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: const BorderSide(color: AgrisellColors.borderLine),
      ),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Top Row: Ticket Number & Status Pill
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 3,
                    ),
                    decoration: SupportTicketCardStyles.containerDecoration,
                    child: Text(
                      ticket.ticketNumber,
                      style: SupportTicketCardStyles.textStyle,
                    ),
                  ),
                  const SizedBox(width: 8),
                  // Category Icon & Label
                  Icon(
                    ticket.category.icon,
                    size: 15,
                    color: AgrisellColors.mutedText,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    ticket.category.label,
                    style: SupportTicketCardStyles.textStyle2,
                  ),
                  const Spacer(),
                  // Status Pill
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 4,
                    ),
                    decoration: SupportTicketCardStyles.containerDecoration2(
                      ticket,
                    ),
                    child: Text(
                      ticket.status.label,
                      style: SupportTicketCardStyles.textStyle3(ticket),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),

              // Subject Title
              Text(
                ticket.subject,
                style: SupportTicketCardStyles.textStyle4,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),

              if (ticket.lastMessage != null &&
                  ticket.lastMessage!.isNotEmpty) ...[
                const SizedBox(height: 6),
                Text(
                  ticket.lastMessage!,
                  style: SupportTicketCardStyles.textStyle5,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],

              const SizedBox(height: 12),
              // Bottom Row: Priority & Timestamp
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 2,
                    ),
                    decoration: SupportTicketCardStyles.containerDecoration3(
                      ticket,
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.flag_rounded,
                          size: 12,
                          color: ticket.priority.textColor,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          ticket.priority.label,
                          style: SupportTicketCardStyles.textStyle6(ticket),
                        ),
                      ],
                    ),
                  ),
                  const Spacer(),
                  Icon(
                    Icons.access_time_rounded,
                    size: 13,
                    color: AgrisellColors.mutedText.withValues(alpha: 0.8),
                  ),
                  const SizedBox(width: 4),
                  Text(
                    _formatTimeAgo(ticket.updatedAt),
                    style: SupportTicketCardStyles.textStyle7,
                  ),
                  const SizedBox(width: 6),
                  const Icon(
                    Icons.chevron_right_rounded,
                    size: 18,
                    color: AgrisellColors.mutedText,
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
