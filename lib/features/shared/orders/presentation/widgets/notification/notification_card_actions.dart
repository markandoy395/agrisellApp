import 'package:flutter/material.dart';

class NotificationCardActions extends StatelessWidget {
  const NotificationCardActions({
    required this.title,
    required this.isRead,
    required this.isExpandable,
    required this.isExpanded,
    required this.onToggleRead,
    required this.onDelete,
    required this.onToggleExpanded,
    super.key,
  });

  final String title;
  final bool isRead;
  final bool isExpandable;
  final bool isExpanded;
  final VoidCallback onToggleRead;
  final VoidCallback onDelete;
  final VoidCallback onToggleExpanded;

  @override
  Widget build(BuildContext context) => Column(
    children: [
      PopupMenuButton<_NotificationAction>(
        tooltip: 'Options for $title',
        onSelected: (action) {
          if (action == _NotificationAction.toggleRead) onToggleRead();
          if (action == _NotificationAction.delete) onDelete();
        },
        itemBuilder: (_) => [
          PopupMenuItem(
            value: _NotificationAction.toggleRead,
            child: Text(isRead ? 'Mark as unread' : 'Mark as read'),
          ),
          const PopupMenuItem(
            value: _NotificationAction.delete,
            child: Text('Delete'),
          ),
        ],
        icon: const Icon(Icons.more_vert_rounded, size: 20),
      ),
      if (isExpandable)
        IconButton(
          tooltip: isExpanded ? 'Collapse notification' : 'Expand notification',
          onPressed: onToggleExpanded,
          icon: AnimatedRotation(
            turns: isExpanded ? 0.5 : 0,
            duration: const Duration(milliseconds: 180),
            child: const Icon(Icons.keyboard_arrow_down, size: 24),
          ),
        ),
    ],
  );
}

enum _NotificationAction { toggleRead, delete }
