import 'package:agresell_app/features/shared/orders/presentation/styles/notification_content_widgets_styles.dart';
import 'package:agresell_app/core/theme/shared_presentation_styles.dart';
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
      decoration: NotificationContentWidgetsStyles.containerDecoration,
      child: Row(
        children: [
          Container(
            width: 38,
            height: 38,
            decoration: NotificationContentWidgetsStyles.containerDecoration2,
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
                  style: SharedPresentationStyles.headingTitleExtraBold,
                ),
                Text(
                  unreadCount == 0
                      ? 'You are all caught up'
                      : '$unreadCount unread update${unreadCount == 1 ? '' : 's'}',
                  style: SharedPresentationStyles.mutedCaptionMedium,
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
      child: LayoutBuilder(
        builder: (context, constraints) {
          final title = Text(
            'Order Updates',
            style: SharedPresentationStyles.headingBodyBold,
          );
          final actions = Wrap(
            alignment: WrapAlignment.end,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              TextButton(
                style: NotificationContentWidgetsStyles.readAllButton,
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
          );
          if (constraints.maxWidth < 340 ||
              MediaQuery.textScalerOf(context).scale(14) > 20) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                title,
                Align(alignment: Alignment.centerRight, child: actions),
              ],
            );
          }
          return Row(
            children: [
              Expanded(child: title),
              actions,
            ],
          );
        },
      ),
    );
  }
}

enum _NotificationBulkAction { clearAll }
