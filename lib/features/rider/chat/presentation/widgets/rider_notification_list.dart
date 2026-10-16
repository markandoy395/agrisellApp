import 'package:flutter/material.dart';

import 'package:agresell_app/features/shared/notifications/presentation/widgets/notification_grouped_list.dart';
import 'package:agresell_app/features/rider/chat/domain/rider_notification.dart';
import 'package:agresell_app/features/rider/chat/presentation/widgets/rider_notification_card.dart';
import 'package:agresell_app/features/shared/notifications/presentation/widgets/notification_state_view.dart';

class RiderNotificationList extends StatelessWidget {
  const RiderNotificationList({
    required this.notifications,
    required this.onOpen,
    required this.onToggleRead,
    this.onDelete,
    super.key,
  });

  final List<RiderNotification> notifications;
  final ValueChanged<RiderNotification> onOpen;
  final ValueChanged<RiderNotification> onToggleRead;
  final ValueChanged<RiderNotification>? onDelete;

  @override
  Widget build(BuildContext context) {
    if (notifications.isEmpty) {
      return const NotificationStateView(
        icon: Icons.notifications_none_rounded,
        title: 'No notifications yet',
        message:
            'Delivery requests, messages, payments, and account updates will appear here.',
      );
    }
    return NotificationGroupedList<RiderNotification>(
      items: notifications,
      dateOf: (item) => item.createdAt,
      padding: const EdgeInsets.fromLTRB(14, 4, 14, 30),
      itemBuilder: (context, notification) => RiderNotificationCard(
        key: ValueKey(notification.id),
        notification: notification,
        onTap: () => onOpen(notification),
        onToggleRead: () => onToggleRead(notification),
        onDelete: notification.canDelete && onDelete != null
            ? () => onDelete!(notification)
            : null,
      ),
    );
  }
}
