import 'package:flutter/material.dart';

import 'package:agresell_app/core/theme/agrisellColors.dart';
import 'package:agresell_app/core/utils/notification_date_group.dart';
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
    final groups = _groupNotifications(notifications);
    return ListView(
      padding: const EdgeInsets.fromLTRB(14, 4, 14, 30),
      children: [
        for (final group in NotificationDateGroup.values)
          if (groups[group] case final items? when items.isNotEmpty) ...[
            _GroupLabel(label: group.label),
            for (final notification in items) ...[
              RiderNotificationCard(
                key: ValueKey(notification.id),
                notification: notification,
                onTap: () => onOpen(notification),
                onToggleRead: () => onToggleRead(notification),
                onDelete: notification.canDelete && onDelete != null
                    ? () => onDelete!(notification)
                    : null,
              ),
              const SizedBox(height: 10),
            ],
          ],
      ],
    );
  }

  Map<NotificationDateGroup, List<RiderNotification>> _groupNotifications(
    List<RiderNotification> items,
  ) {
    final result = <NotificationDateGroup, List<RiderNotification>>{};
    for (final item in items) {
      result
          .putIfAbsent(NotificationDateGroup.from(item.createdAt), () => [])
          .add(item);
    }
    return result;
  }
}

class _GroupLabel extends StatelessWidget {
  const _GroupLabel({required this.label});
  final String label;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.fromLTRB(4, 14, 4, 8),
    child: Text(
      label,
      style: const TextStyle(
        color: AgrisellColors.headingGreen,
        fontSize: 13,
        fontWeight: FontWeight.w800,
      ),
    ),
  );
}
