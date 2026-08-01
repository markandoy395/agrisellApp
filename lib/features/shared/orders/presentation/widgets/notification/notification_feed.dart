import 'package:flutter/material.dart';

import 'package:agresell_app/core/theme/agrisell_colors.dart';
import 'package:agresell_app/core/utils/notification_date_group.dart';
import 'package:agresell_app/features/shared/notifications/domain/notification_category.dart';
import 'package:agresell_app/features/shared/notifications/presentation/widgets/notification_state_view.dart';
import 'package:agresell_app/features/shared/orders/domain/home_notification.dart';
import 'package:agresell_app/features/shared/orders/presentation/controllers/notification_controller.dart';
import 'package:agresell_app/features/shared/orders/presentation/widgets/notification/notification_list_item.dart';

class NotificationFeed extends StatelessWidget {
  const NotificationFeed({
    required this.notifications,
    required this.filter,
    required this.controller,
    required this.onOpen,
    required this.onToggleRead,
    required this.onDelete,
    super.key,
  });

  final List<HomeNotification> notifications;
  final NotificationFilter filter;
  final NotificationController controller;
  final ValueChanged<HomeNotification> onOpen;
  final ValueChanged<HomeNotification> onToggleRead;
  final ValueChanged<HomeNotification> onDelete;

  @override
  Widget build(BuildContext context) {
    final filtered = notifications
        .where((notification) => filter.includes(notification.category))
        .toList(growable: false);
    if (filtered.isEmpty) {
      return NotificationStateView(
        icon: filter == NotificationFilter.all
            ? Icons.notifications_none_rounded
            : Icons.filter_alt_off_outlined,
        title: filter == NotificationFilter.all
            ? 'No notifications yet'
            : 'No ${filter.label.toLowerCase()} updates',
        message: filter == NotificationFilter.all
            ? 'Orders, deliveries, messages, and account updates will appear here.'
            : 'Try another filter or check again later.',
      );
    }
    final groups = _group(filtered);
    final reduceMotion =
        MediaQuery.maybeOf(context)?.disableAnimations ?? false;
    final list = ListView(
      key: ValueKey(filtered.map((item) => item.id).join('|')),
      padding: EdgeInsets.fromLTRB(
        14,
        4,
        14,
        150 + MediaQuery.paddingOf(context).bottom,
      ),
      children: [
        for (final group in NotificationDateGroup.values)
          if (groups[group] case final items? when items.isNotEmpty) ...[
            _GroupHeader(label: group.label),
            for (final item in items) ...[
              NotificationListItem(
                key: ValueKey(item.id),
                item: item,
                isRead: controller.isRead(item),
                onTap: () => onOpen(item),
                onToggleRead: () => onToggleRead(item),
                onDelete: () => onDelete(item),
              ),
              const SizedBox(height: 10),
            ],
          ],
      ],
    );
    if (reduceMotion) return list;
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 180),
      switchInCurve: Curves.easeOutCubic,
      switchOutCurve: Curves.easeInCubic,
      child: list,
    );
  }

  Map<NotificationDateGroup, List<HomeNotification>> _group(
    List<HomeNotification> notifications,
  ) {
    final result = <NotificationDateGroup, List<HomeNotification>>{};
    for (final notification in notifications) {
      final date = notification.createdAt ?? DateTime.now();
      result
          .putIfAbsent(NotificationDateGroup.from(date), () => [])
          .add(notification);
    }
    return result;
  }
}

class _GroupHeader extends StatelessWidget {
  const _GroupHeader({required this.label});
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
