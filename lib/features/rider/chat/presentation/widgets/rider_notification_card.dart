import 'package:flutter/material.dart';

import 'package:agresell_app/core/utils/notification_date_label.dart';
import 'package:agresell_app/features/rider/chat/domain/rider_notification.dart';
import 'package:agresell_app/features/rider/chat/presentation/rider_notification_presentation.dart';
import 'package:agresell_app/features/rider/chat/presentation/styles/rider_notification_card_styles.dart';
import 'package:agresell_app/features/rider/chat/presentation/widgets/rider_notification_card_actions.dart';
import 'package:agresell_app/features/rider/chat/presentation/widgets/rider_notification_style.dart';

class RiderNotificationCard extends StatefulWidget {
  const RiderNotificationCard({
    required this.notification,
    required this.onTap,
    required this.onToggleRead,
    this.onDelete,
    this.maxTextLength = defaultMaxTextLength,
    super.key,
  });

  static const int defaultMaxTextLength = 80;

  final RiderNotification notification;
  final VoidCallback onTap;
  final VoidCallback onToggleRead;
  final VoidCallback? onDelete;
  final int maxTextLength;

  @override
  State<RiderNotificationCard> createState() => _RiderNotificationCardState();
}

class _RiderNotificationCardState extends State<RiderNotificationCard> {
  var _isExpanded = false;

  bool get _isExpandable {
    final text = widget.notification.message.trim();
    return text.length > widget.maxTextLength || text.contains('\n');
  }

  String get _displayedMessage {
    final text = widget.notification.message.trim();
    if (!_isExpandable || _isExpanded) return widget.notification.message;
    if (text.length > widget.maxTextLength) {
      final cut = text.substring(0, widget.maxTextLength);
      final lastSpace = cut.lastIndexOf(' ');
      if (lastSpace > widget.maxTextLength * 0.7) {
        return '${cut.substring(0, lastSpace).trimRight()}...';
      }
      return '${cut.trimRight()}...';
    }
    return text;
  }

  @override
  Widget build(BuildContext context) {
    final style = riderNotificationStyleFor(widget.notification.type);
    final isRead = widget.notification.isRead;
    return Semantics(
      button: true,
      label:
          '${widget.notification.title}, ${isRead ? 'read' : 'unread'}',
      hint: 'Opens the related update',
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        decoration: RiderNotificationCardStyles.cardDecoration(
          isRead: isRead,
          styleColor: style.color,
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            borderRadius: BorderRadius.circular(
              RiderNotificationCardStyles.borderRadiusValue,
            ),
            onTap: widget.onTap,
            child: Padding(
              padding: RiderNotificationCardStyles.padding,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: RiderNotificationCardStyles.iconContainerSize,
                    height: RiderNotificationCardStyles.iconContainerSize,
                    decoration: RiderNotificationCardStyles.iconDecoration(
                      style.color,
                    ),
                    child: Icon(
                      style.icon,
                      color: style.color,
                      size: RiderNotificationCardStyles.iconSize,
                    ),
                  ),
                  const SizedBox(width: 11),
                  Expanded(child: _content(style)),
                  RiderNotificationCardActions(
                    notification: widget.notification,
                    onToggleRead: widget.onToggleRead,
                    onDelete: widget.onDelete,
                    isExpandable: _isExpandable,
                    isExpanded: _isExpanded,
                    onToggleExpand: () =>
                        setState(() => _isExpanded = !_isExpanded),
                  ),
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
              widget.notification.title,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: RiderNotificationCardStyles.titleStyle(
                widget.notification.isRead,
              ),
            ),
          ),
          if (!widget.notification.isRead)
            Container(
              width: RiderNotificationCardStyles.unreadDotSize,
              height: RiderNotificationCardStyles.unreadDotSize,
              decoration: RiderNotificationCardStyles.unreadDotDecoration(
                style.color,
              ),
            ),
        ],
      ),
      const SizedBox(height: 5),
      Wrap(
        spacing: 8,
        children: [
          Text(
            widget.notification.type.label,
            style: RiderNotificationCardStyles.typeLabelStyle(style.color),
          ),
          Text(
            NotificationDateLabel.format(widget.notification.createdAt),
            style: RiderNotificationCardStyles.dateLabelStyle,
          ),
        ],
      ),
      const SizedBox(height: 7),
      AnimatedSize(
        duration: const Duration(milliseconds: 180),
        curve: Curves.easeOutCubic,
        child: Text(
          _displayedMessage,
          maxLines: _isExpanded ? null : 2,
          overflow: _isExpanded ? TextOverflow.visible : TextOverflow.ellipsis,
          style: RiderNotificationCardStyles.messageStyle,
        ),
      ),
    ],
  );
}
