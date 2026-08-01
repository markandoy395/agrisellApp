import 'package:flutter/material.dart';

import 'package:agresell_app/core/theme/agrisell_colors.dart';
import 'package:agresell_app/core/utils/notification_date_label.dart';
import 'package:agresell_app/features/shared/orders/domain/home_notification.dart';
import 'package:agresell_app/features/shared/orders/presentation/widgets/notification/notification_card_actions.dart';
import 'package:agresell_app/features/shared/orders/presentation/widgets/notification/notification_style.dart';

class NotificationListItem extends StatefulWidget {
  const NotificationListItem({
    required this.item,
    required this.isRead,
    required this.onTap,
    required this.onToggleRead,
    required this.onDelete,
    super.key,
  });

  final HomeNotification item;
  final bool isRead;
  final VoidCallback onTap;
  final VoidCallback onToggleRead;
  final VoidCallback onDelete;

  @override
  State<NotificationListItem> createState() => _NotificationListItemState();
}

class _NotificationListItemState extends State<NotificationListItem> {
  var _isExpanded = false;

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
        decoration: BoxDecoration(
          color: widget.isRead ? AgrisellColors.surface : style.background,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: widget.isRead ? AgrisellColors.borderLine : style.color,
            width: widget.isRead ? 1 : 1.2,
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
            onTap: widget.onTap,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(12, 12, 6, 12),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  NotificationTypeIcon(style: style),
                  const SizedBox(width: 11),
                  Expanded(child: _content(style)),
                  NotificationCardActions(
                    title: widget.item.title,
                    isRead: widget.isRead,
                    isExpandable: widget.item.showChevron,
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

  Widget _content(NotificationStyle style) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Row(
        children: [
          Expanded(
            child: Text(
              widget.item.title,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: AgrisellColors.headingGreen,
                fontSize: 13,
                height: 1.25,
                fontWeight: widget.isRead ? FontWeight.w700 : FontWeight.w800,
              ),
            ),
          ),
          if (!widget.isRead) ...[
            const SizedBox(width: 6),
            Semantics(
              label: 'Unread',
              child: Container(
                width: 8,
                height: 8,
                decoration: BoxDecoration(
                  color: style.color,
                  shape: BoxShape.circle,
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
            widget.item.createdAt == null
                ? 'Recently'
                : NotificationDateLabel.format(widget.item.createdAt!),
            style: const TextStyle(
              color: AgrisellColors.mutedText,
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
      const SizedBox(height: 7),
      AnimatedSize(
        duration: const Duration(milliseconds: 180),
        child: Text(
          widget.item.description,
          maxLines: widget.item.showChevron && !_isExpanded ? 3 : null,
          overflow: widget.item.showChevron && !_isExpanded
              ? TextOverflow.ellipsis
              : TextOverflow.visible,
          style: const TextStyle(
            color: AgrisellColors.brandBlack,
            fontSize: 12,
            height: 1.35,
            fontWeight: FontWeight.w400,
          ),
        ),
      ),
    ],
  );
}
