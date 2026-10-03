import 'package:flutter/material.dart';

import 'package:agresell_app/core/theme/agrisell_colors.dart';
import 'package:agresell_app/features/rider/chat/domain/rider_notification.dart';

enum RiderNotificationAction { toggleRead, delete }

class RiderNotificationCardActions extends StatelessWidget {
  const RiderNotificationCardActions({
    required this.notification,
    required this.onToggleRead,
    required this.isExpandable,
    required this.isExpanded,
    required this.onToggleExpand,
    this.onDelete,
    super.key,
  });

  final RiderNotification notification;
  final VoidCallback onToggleRead;
  final VoidCallback? onDelete;
  final bool isExpandable;
  final bool isExpanded;
  final VoidCallback onToggleExpand;

  @override
  Widget build(BuildContext context) => Column(
    mainAxisSize: MainAxisSize.min,
    children: [
      PopupMenuButton<RiderNotificationAction>(
        tooltip: 'Options for ${notification.title}',
        onSelected: (action) {
          if (action == RiderNotificationAction.toggleRead) onToggleRead();
          if (action == RiderNotificationAction.delete) onDelete?.call();
        },
        itemBuilder: (_) => [
          PopupMenuItem(
            value: RiderNotificationAction.toggleRead,
            child: Text(notification.isRead ? 'Mark as unread' : 'Mark as read'),
          ),
          if (onDelete != null)
            const PopupMenuItem(
              value: RiderNotificationAction.delete,
              child: Text('Delete'),
            ),
        ],
        icon: const Icon(Icons.more_vert_rounded, size: 20),
      ),
      if (isExpandable)
        IconButton(
          key: const Key('rider_notification_expand_button'),
          tooltip: isExpanded ? 'Collapse notification' : 'Expand notification',
          onPressed: onToggleExpand,
          visualDensity: VisualDensity.compact,
          icon: AnimatedRotation(
            turns: isExpanded ? 0.5 : 0,
            duration: const Duration(milliseconds: 180),
            child: const Icon(
              Icons.keyboard_arrow_down,
              size: 24,
              color: AgrisellColors.mutedText,
            ),
          ),
        ),
    ],
  );
}
