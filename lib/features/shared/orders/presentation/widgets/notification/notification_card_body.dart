import 'package:flutter/material.dart';

import 'package:agresell_app/core/utils/notification_date_label.dart';
import 'package:agresell_app/features/shared/orders/domain/home_notification.dart';
import 'package:agresell_app/features/shared/orders/presentation/styles/notification_list_item_styles.dart';
import 'package:agresell_app/features/shared/orders/presentation/widgets/notification/notification_style.dart';

class NotificationCardBody extends StatelessWidget {
  const NotificationCardBody({
    required this.item,
    required this.isRead,
    required this.isExpanded,
    required this.displayedDescription,
    required this.style,
    super.key,
  });

  final HomeNotification item;
  final bool isRead;
  final bool isExpanded;
  final String displayedDescription;
  final NotificationStyle style;

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Row(
        children: [
          Expanded(
            child: Text(
              item.title,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: NotificationListItemStyles.titleStyle(isRead: isRead),
            ),
          ),
          if (!isRead) ...[
            const SizedBox(width: 6),
            Semantics(
              label: 'Unread',
              child: Container(
                width: NotificationListItemStyles.unreadDotSize,
                height: NotificationListItemStyles.unreadDotSize,
                decoration: NotificationListItemStyles.unreadDotDecoration(
                  style.color,
                ),
              ),
            ),
          ],
        ],
      ),
      const SizedBox(height: 5),
      Wrap(
        spacing: 8,
        runSpacing: 4,
        crossAxisAlignment: WrapCrossAlignment.center,
        children: [
          NotificationTypeLabel(style: style),
          Text(
            item.createdAt == null
                ? 'Recently'
                : NotificationDateLabel.format(item.createdAt!),
            style: NotificationListItemStyles.dateStyle,
          ),
        ],
      ),
      const SizedBox(height: 7),
      AnimatedSize(
        duration: const Duration(milliseconds: 180),
        curve: Curves.easeOutCubic,
        child: Text(
          displayedDescription,
          maxLines: isExpanded ? null : 2,
          overflow: isExpanded ? TextOverflow.visible : TextOverflow.ellipsis,
          style: NotificationListItemStyles.descriptionStyle,
        ),
      ),
    ],
  );
}
