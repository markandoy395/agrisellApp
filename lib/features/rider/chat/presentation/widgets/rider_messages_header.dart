import 'package:flutter/material.dart';
import 'package:agresell_app/core/theme/agrisell_colors.dart';
import '../styles/rider_messaging_design_styles.dart';

class RiderMessagesHeader extends StatelessWidget {
  const RiderMessagesHeader({
    this.onNotifications,
    this.unreadCount = 0,
    super.key,
  });
  final VoidCallback? onNotifications;
  final int unreadCount;

  @override
  Widget build(BuildContext context) => SafeArea(
    bottom: false,
    child: Padding(
      padding: const EdgeInsets.fromLTRB(20, 18, 20, 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(
                Icons.chat_bubble_outline_rounded,
                color: AgrisellColors.authGreen,
                size: 28,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  'Messages',
                  style: RiderMessagingDesignStyles.heading,
                ),
              ),
              if (onNotifications != null)
                IconButton(
                  tooltip: 'Notifications',
                  onPressed: onNotifications,
                  icon: Badge(
                    isLabelVisible: unreadCount > 0,
                    label: Text('$unreadCount'),
                    child: const Icon(
                      Icons.notifications_outlined,
                      color: AgrisellColors.headingGreen,
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            'Protected delivery chat and customer support',
            style: RiderMessagingDesignStyles.muted,
          ),
        ],
      ),
    ),
  );
}
