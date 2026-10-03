import 'package:flutter/material.dart';

import '../styles/support_ticket_detail_styles.dart';
import 'package:agresell_app/features/shared/support/domain/support_ticket.dart';
import '../utils/support_date_time_formatter.dart';
import 'support_ticket_badge.dart';

class SupportTicketDetailHeader extends StatelessWidget {
  const SupportTicketDetailHeader({super.key, required this.ticket});
  final SupportTicket ticket;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: SupportTicketDetailStyles.headerPadding,
      decoration: SupportTicketDetailStyles.header,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              // Category Icon & Label
              Icon(
                ticket.category.icon,
                size: 16,
                color: SupportTicketDetailStyles.muted,
              ),
              const SizedBox(width: 4),
              Text(
                ticket.category.label,
                style: SupportTicketDetailStyles.categoryLabel,
              ),
              const Spacer(),
              SupportTicketBadge.status(ticket.status),
              const SizedBox(width: 6),
              SupportTicketBadge.priority(ticket.priority),
            ],
          ),
          const SizedBox(height: 8),
          Text(ticket.subject, style: SupportTicketDetailStyles.subject),
          const SizedBox(height: 4),
          Text(
            'Created on ${formatSupportDateTime(ticket.createdAt)}',
            style: SupportTicketDetailStyles.caption,
          ),
          if (ticket.resolutionNotes != null &&
              ticket.resolutionNotes!.isNotEmpty) ...[
            const SizedBox(height: 8),
            Container(
              padding: SupportTicketDetailStyles.resolutionPadding,
              decoration: SupportTicketDetailStyles.resolutionNotes,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(
                    Icons.check_circle_outline_rounded,
                    size: 16,
                    color: SupportTicketDetailStyles.green,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Resolution Notes: ${ticket.resolutionNotes}',
                      style: SupportTicketDetailStyles.resolutionText,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}
