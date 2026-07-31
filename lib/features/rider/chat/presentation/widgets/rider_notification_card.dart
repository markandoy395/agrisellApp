import 'package:flutter/material.dart';

import 'package:agresell_app/core/theme/agrisellColors.dart';
import 'package:agresell_app/core/utils/notification_date_label.dart';
import 'package:agresell_app/features/rider/chat/domain/rider_notification.dart';
import 'package:agresell_app/features/rider/chat/presentation/rider_notification_presentation.dart';
import 'package:agresell_app/features/rider/chat/presentation/widgets/rider_notification_style.dart';

class RiderNotificationCard extends StatelessWidget {
  const RiderNotificationCard({
    required this.notification,
    required this.onTap,
    required this.onToggleRead,
    this.onDelete,
    super.key,
  });

  final RiderNotification notification;
  final VoidCallback onTap;
  final VoidCallback onToggleRead;
  final VoidCallback? onDelete;

  @override
  Widget build(BuildContext context) {
    final style = riderNotificationStyleFor(notification.type);
    return Semantics(
      button: true,
      label:
          '${notification.title}, ${notification.isRead ? 'read' : 'unread'}',
      hint: 'Opens the related update',
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        decoration: BoxDecoration(
          color: notification.isRead
              ? AgrisellColors.surface
              : style.color.withValues(alpha: 0.07),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: notification.isRead
                ? AgrisellColors.borderLine
                : style.color,
          ),
          boxShadow: [
            BoxShadow(
              color: AgrisellColors.brandBlack.withValues(alpha: 0.055),
              blurRadius: 12,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            borderRadius: BorderRadius.circular(16),
            onTap: onTap,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(12, 12, 6, 12),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 42,
                    height: 42,
                    decoration: BoxDecoration(
                      color: style.color.withValues(alpha: 0.13),
                      borderRadius: BorderRadius.circular(13),
                    ),
                    child: Icon(style.icon, color: style.color, size: 21),
                  ),
                  const SizedBox(width: 11),
                  Expanded(child: _content(style)),
                  _menu(),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _content(RiderNotificationStyle style) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Row(
        children: [
          Expanded(
            child: Text(
              notification.title,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: AgrisellColors.headingGreen,
                fontSize: 13,
                height: 1.25,
                fontWeight: notification.isRead
                    ? FontWeight.w700
                    : FontWeight.w800,
              ),
            ),
          ),
          if (!notification.isRead)
            Container(
              width: 8,
              height: 8,
              decoration: BoxDecoration(
                color: style.color,
                shape: BoxShape.circle,
              ),
            ),
        ],
      ),
      const SizedBox(height: 5),
      Wrap(
        spacing: 8,
        children: [
          Text(
            notification.type.label,
            style: TextStyle(
              color: style.color,
              fontSize: 12,
              fontWeight: FontWeight.w700,
            ),
          ),
          Text(
            NotificationDateLabel.format(notification.createdAt),
            style: const TextStyle(
              color: AgrisellColors.mutedText,
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
      const SizedBox(height: 7),
      Text(
        notification.message,
        maxLines: 3,
        overflow: TextOverflow.ellipsis,
        style: const TextStyle(
          color: AgrisellColors.brandBlack,
          fontSize: 12,
          height: 1.35,
        ),
      ),
    ],
  );

  Widget _menu() => PopupMenuButton<_RiderNotificationAction>(
    tooltip: 'Options for ${notification.title}',
    onSelected: (action) {
      if (action == _RiderNotificationAction.toggleRead) onToggleRead();
      if (action == _RiderNotificationAction.delete) onDelete?.call();
    },
    itemBuilder: (_) => [
      PopupMenuItem(
        value: _RiderNotificationAction.toggleRead,
        child: Text(notification.isRead ? 'Mark as unread' : 'Mark as read'),
      ),
      if (onDelete != null)
        const PopupMenuItem(
          value: _RiderNotificationAction.delete,
          child: Text('Delete'),
        ),
    ],
    icon: const Icon(Icons.more_vert_rounded, size: 20),
  );
}

enum _RiderNotificationAction { toggleRead, delete }
