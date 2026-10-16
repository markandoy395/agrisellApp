import 'package:flutter/material.dart';

import 'package:agresell_app/features/shared/notifications/presentation/widgets/notification_grouped_list.dart';
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
      return SizedBox.expand(
        child: NotificationStateView(
          icon: filter == NotificationFilter.all
              ? Icons.notifications_none_rounded
              : Icons.filter_alt_off_outlined,
          title: filter == NotificationFilter.all
              ? 'No notifications yet'
              : 'No ${filter.label.toLowerCase()} updates',
          message: filter == NotificationFilter.all
              ? 'Orders, deliveries, messages, and account updates will appear here.'
              : null,
        ),
      );
    }
    final reduceMotion =
        MediaQuery.maybeOf(context)?.disableAnimations ?? false;
    final list = NotificationGroupedList<HomeNotification>(
      key: ValueKey(filter),
      items: filtered,
      dateOf: (item) => item.createdAt,
      padding: const EdgeInsets.fromLTRB(14, 4, 14, 24),
      itemBuilder: (context, item) => NotificationListItem(
        key: ValueKey(item.id),
        item: item,
        isRead: controller.isRead(item),
        onTap: () => onOpen(item),
        onToggleRead: () => onToggleRead(item),
        onDelete: () => onDelete(item),
      ),
    );
    if (reduceMotion) return list;
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 180),
      switchInCurve: Curves.easeOutCubic,
      switchOutCurve: Curves.easeInCubic,
      child: list,
    );
  }
}
