import 'package:flutter/material.dart';

import 'package:agresell_app/core/theme/agrisell_colors.dart';
import 'package:agresell_app/core/utils/notification_date_label.dart';
import 'package:agresell_app/features/rider/chat/domain/rider_notification.dart';
import 'package:agresell_app/features/rider/chat/presentation/rider_notification_presentation.dart';
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
    return Semantics(
      button: true,
      label:
          '${widget.notification.title}, ${widget.notification.isRead ? 'read' : 'unread'}',
      hint: 'Opens the related update',
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        decoration: BoxDecoration(
          color: widget.notification.isRead
              ? AgrisellColors.surface
              : style.color.withValues(alpha: 0.07),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: widget.notification.isRead
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
            onTap: widget.onTap,
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
                  _actions(),
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
              style: TextStyle(
                color: AgrisellColors.headingGreen,
                fontSize: 13,
                height: 1.25,
                fontWeight: widget.notification.isRead
                    ? FontWeight.w700
                    : FontWeight.w800,
              ),
            ),
          ),
          if (!widget.notification.isRead)
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
            widget.notification.type.label,
            style: TextStyle(
              color: style.color,
              fontSize: 12,
              fontWeight: FontWeight.w700,
            ),
          ),
          Text(
            NotificationDateLabel.format(widget.notification.createdAt),
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
        curve: Curves.easeOutCubic,
        child: Text(
          _displayedMessage,
          maxLines: _isExpanded ? null : 2,
          overflow: _isExpanded ? TextOverflow.visible : TextOverflow.ellipsis,
          style: const TextStyle(
            color: AgrisellColors.brandBlack,
            fontSize: 12,
            height: 1.35,
          ),
        ),
      ),
    ],
  );

  Widget _actions() => Column(
    mainAxisSize: MainAxisSize.min,
    children: [
      PopupMenuButton<_RiderNotificationAction>(
        tooltip: 'Options for ${widget.notification.title}',
        onSelected: (action) {
          if (action == _RiderNotificationAction.toggleRead) widget.onToggleRead();
          if (action == _RiderNotificationAction.delete) widget.onDelete?.call();
        },
        itemBuilder: (_) => [
          PopupMenuItem(
            value: _RiderNotificationAction.toggleRead,
            child: Text(widget.notification.isRead ? 'Mark as unread' : 'Mark as read'),
          ),
          if (widget.onDelete != null)
            const PopupMenuItem(
              value: _RiderNotificationAction.delete,
              child: Text('Delete'),
            ),
        ],
        icon: const Icon(Icons.more_vert_rounded, size: 20),
      ),
      if (_isExpandable)
        IconButton(
          key: const Key('rider_notification_expand_button'),
          tooltip: _isExpanded ? 'Collapse notification' : 'Expand notification',
          onPressed: () => setState(() => _isExpanded = !_isExpanded),
          visualDensity: VisualDensity.compact,
          icon: AnimatedRotation(
            turns: _isExpanded ? 0.5 : 0,
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

enum _RiderNotificationAction { toggleRead, delete }
