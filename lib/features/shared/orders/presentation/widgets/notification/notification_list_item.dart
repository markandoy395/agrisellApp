import 'package:flutter/material.dart';

import 'package:agresell_app/features/shared/orders/domain/home_notification.dart';
import 'package:agresell_app/features/shared/orders/presentation/styles/notification_list_item_styles.dart';
import 'package:agresell_app/features/shared/orders/presentation/widgets/notification/notification_card_actions.dart';
import 'package:agresell_app/features/shared/orders/presentation/widgets/notification/notification_card_body.dart';
import 'package:agresell_app/features/shared/orders/presentation/widgets/notification/notification_style.dart';

class NotificationListItem extends StatefulWidget {
  const NotificationListItem({
    required this.item,
    required this.isRead,
    required this.onTap,
    required this.onToggleRead,
    required this.onDelete,
    this.maxTextLength = defaultMaxTextLength,
    super.key,
  });

  static const int defaultMaxTextLength = 80;

  final HomeNotification item;
  final bool isRead;
  final VoidCallback onTap;
  final VoidCallback onToggleRead;
  final VoidCallback onDelete;
  final int maxTextLength;

  @override
  State<NotificationListItem> createState() => _NotificationListItemState();
}

class _NotificationListItemState extends State<NotificationListItem> {
  var _isExpanded = false;

  bool get _isExpandable {
    final text = widget.item.description.trim();
    return text.length > widget.maxTextLength || text.contains('\n');
  }

  String get _displayedDescription {
    final text = widget.item.description.trim();
    if (!_isExpandable || _isExpanded) return widget.item.description;
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
    final style = notificationStyleFor(widget.item.type);
    final reduceMotion =
        MediaQuery.maybeOf(context)?.disableAnimations ?? false;
    final card = Semantics(
      button: true,
      label: '${widget.item.title}, ${widget.isRead ? 'read' : 'unread'}',
      hint: 'Opens the related update',
      child: AnimatedContainer(
        duration: reduceMotion
            ? Duration.zero
            : const Duration(milliseconds: 180),
        curve: Curves.easeOutCubic,
        decoration: NotificationListItemStyles.cardDecoration(
          isRead: widget.isRead,
          style: style,
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            borderRadius: NotificationListItemStyles.cardRadius,
            onTap: widget.onTap,
            child: Padding(
              padding: NotificationListItemStyles.cardPadding,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  NotificationTypeIcon(style: style),
                  const SizedBox(width: 11),
                  Expanded(
                    child: NotificationCardBody(
                      item: widget.item,
                      isRead: widget.isRead,
                      isExpanded: _isExpanded,
                      displayedDescription: _displayedDescription,
                      style: style,
                    ),
                  ),
                  NotificationCardActions(
                    title: widget.item.title,
                    isRead: widget.isRead,
                    isExpandable: _isExpandable,
                    isExpanded: _isExpanded,
                    onToggleRead: widget.onToggleRead,
                    onDelete: widget.onDelete,
                    onToggleExpanded: () =>
                        setState(() => _isExpanded = !_isExpanded),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
    if (reduceMotion) return card;
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: 1),
      duration: const Duration(milliseconds: 240),
      curve: Curves.easeOutCubic,
      builder: (_, value, child) => Opacity(
        opacity: value,
        child: Transform.translate(
          offset: Offset(0, 8 * (1 - value)),
          child: child,
        ),
      ),
      child: card,
    );
  }
}
