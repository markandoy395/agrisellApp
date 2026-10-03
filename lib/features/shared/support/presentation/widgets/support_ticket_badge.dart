import 'package:flutter/material.dart';

import '../styles/support_ticket_detail_styles.dart';
import 'package:agresell_app/features/shared/support/domain/support_ticket.dart';

class SupportTicketBadge extends StatelessWidget {
  const SupportTicketBadge.status(SupportTicketStatus value, {super.key})
    : status = value,
      priority = null;
  const SupportTicketBadge.priority(SupportTicketPriority value, {super.key})
    : priority = value,
      status = null;
  final SupportTicketStatus? status;
  final SupportTicketPriority? priority;

  @override
  Widget build(BuildContext context) => Container(
    padding: status != null
        ? SupportTicketDetailStyles.statusPadding
        : SupportTicketDetailStyles.priorityPadding,
    decoration: status != null
        ? SupportTicketDetailStyles.statusSurface(status!)
        : SupportTicketDetailStyles.prioritySurface(priority!),
    child: Text(
      status?.label ?? priority!.label,
      style: status != null
          ? SupportTicketDetailStyles.statusText(status!)
          : SupportTicketDetailStyles.priorityText(priority!),
    ),
  );
}
