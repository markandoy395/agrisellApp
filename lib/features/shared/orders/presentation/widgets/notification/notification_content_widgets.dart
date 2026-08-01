import 'package:flutter/material.dart';

import 'package:agresell_app/core/theme/agrisell_colors.dart';

class NotificationHeader extends StatelessWidget {
  const NotificationHeader({required this.unreadCount, super.key});

  final int unreadCount;

  @override
  Widget build(BuildContext context) {
    final topInset = MediaQuery.paddingOf(context).top;
    final width = MediaQuery.sizeOf(context).width;
    return Container(
      width: double.infinity,
      padding: EdgeInsets.fromLTRB(
        width < 380 ? 18 : 24,
        topInset + 16,
        width < 380 ? 18 : 24,
        16,
      ),
      decoration: BoxDecoration(
        color: AgrisellColors.surface,
        borderRadius: const BorderRadius.vertical(bottom: Radius.circular(24)),
        boxShadow: [
          BoxShadow(
            color: AgrisellColors.brandBlack.withValues(alpha: 0.08),
            blurRadius: 14,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              color: AgrisellColors.forestSoft,
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(
              Icons.notifications_none_rounded,
              color: AgrisellColors.authGreen,
              size: 21,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Notification',
                  style: TextStyle(
                    color: AgrisellColors.headingGreen,
                    fontSize: 15,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                Text(
                  unreadCount == 0
                      ? 'You are all caught up'
                      : '$unreadCount unread update${unreadCount == 1 ? '' : 's'}',
                  style: const TextStyle(
                    color: AgrisellColors.mutedText,
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class OrderUpdatesBar extends StatelessWidget {
  const OrderUpdatesBar({
    required this.unreadCount,
    this.onReadAll,
    this.onClearAll,
    super.key,
  });

  static const height = 48.0;
  final int unreadCount;
  final VoidCallback? onReadAll;
  final VoidCallback? onClearAll;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          Expanded(
            child: Text(
              'Order Updates',
              style: const TextStyle(
                color: AgrisellColors.headingGreen,
                fontSize: 13,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          TextButton(
            onPressed: unreadCount == 0 ? null : onReadAll,
            child: const Text('Read All'),
          ),
          PopupMenuButton<_NotificationBulkAction>(
            tooltip: 'Notification options',
            onSelected: (action) {
              if (action == _NotificationBulkAction.clearAll) {
                onClearAll?.call();
              }
            },
            itemBuilder: (_) => const [
              PopupMenuItem(
                value: _NotificationBulkAction.clearAll,
                child: Row(
                  children: [
                    Icon(Icons.delete_sweep_outlined, size: 19),
                    SizedBox(width: 10),
                    Text('Clear all'),
                  ],
                ),
              ),
            ],
            icon: const Icon(Icons.more_horiz_rounded, size: 22),
          ),
        ],
      ),
    );
  }
}

enum _NotificationBulkAction { clearAll }
