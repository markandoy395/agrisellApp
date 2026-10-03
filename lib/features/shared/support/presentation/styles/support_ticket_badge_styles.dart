import 'package:flutter/material.dart';

import 'package:agresell_app/features/shared/support/domain/support_ticket.dart';

abstract final class SupportTicketBadgeStyles {
  static final _statusSurfaces = {
    for (final status in SupportTicketStatus.values)
      status: BoxDecoration(
        color: status.backgroundColor,
        borderRadius: BorderRadius.circular(16),
      ),
  };

  static final _prioritySurfaces = {
    for (final priority in SupportTicketPriority.values)
      priority: BoxDecoration(
        color: priority.backgroundColor,
        borderRadius: BorderRadius.circular(6),
      ),
  };

  static final _statusText = {
    for (final status in SupportTicketStatus.values)
      status: TextStyle(
        fontSize: 12,
        fontWeight: FontWeight.w700,
        color: status.textColor,
      ),
  };

  static final _priorityText = {
    for (final priority in SupportTicketPriority.values)
      priority: TextStyle(
        fontSize: 12,
        fontWeight: FontWeight.w700,
        color: priority.textColor,
      ),
  };

  static BoxDecoration statusSurface(SupportTicketStatus status) =>
      _statusSurfaces[status]!;
  static BoxDecoration prioritySurface(SupportTicketPriority priority) =>
      _prioritySurfaces[priority]!;
  static TextStyle statusText(SupportTicketStatus status) =>
      _statusText[status]!;
  static TextStyle priorityText(SupportTicketPriority priority) =>
      _priorityText[priority]!;
}
