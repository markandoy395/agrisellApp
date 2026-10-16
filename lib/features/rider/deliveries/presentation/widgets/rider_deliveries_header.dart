import 'package:flutter/material.dart';
import 'package:agresell_app/core/theme/agrisell_colors.dart';
import '../styles/rider_deliveries_design_styles.dart';

class RiderDeliveriesHeader extends StatelessWidget {
  const RiderDeliveriesHeader({
    required this.requestCount,
    required this.activeCount,
    this.onOpenNotifications,
    this.unreadNotifications = 0,
    super.key,
  });
  final int requestCount;
  final int activeCount;
  final VoidCallback? onOpenNotifications;
  final int unreadNotifications;

  @override
  Widget build(BuildContext context) => Container(
    decoration: RiderDeliveriesDesignStyles.header,
    child: SafeArea(
      bottom: false,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(18, 16, 18, 14),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Deliveries',
                        style: RiderDeliveriesDesignStyles.title,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Requests, active trips, and delivery history',
                        style: RiderDeliveriesDesignStyles.caption,
                      ),
                    ],
                  ),
                ),
                if (onOpenNotifications != null)
                  IconButton(
                    tooltip: 'Notifications',
                    onPressed: onOpenNotifications,
                    icon: Badge(
                      isLabelVisible: unreadNotifications > 0,
                      label: Text('$unreadNotifications'),
                      child: const Icon(
                        Icons.notifications_outlined,
                        color: AgrisellColors.headingGreen,
                      ),
                    ),
                  ),
              ],
            ),
          ),
          ColoredBox(
            color: AgrisellColors.surface,
            child: TabBar(
              labelColor: AgrisellColors.authGreen,
              unselectedLabelColor: AgrisellColors.mutedText,
              labelStyle: RiderDeliveriesDesignStyles.label,
              indicatorColor: AgrisellColors.authGreen,
              indicatorSize: TabBarIndicatorSize.tab,
              indicatorWeight: 3,
              tabs: [
                _tab('Requests', requestCount),
                _tab('Active', activeCount),
                const Tab(text: 'History'),
              ],
            ),
          ),
        ],
      ),
    ),
  );

  Widget _tab(String label, int count) => Tab(
    child: FittedBox(
      fit: BoxFit.scaleDown,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(label),
          if (count > 0) ...[
            const SizedBox(width: 5),
            Badge(label: Text('$count')),
          ],
        ],
      ),
    ),
  );
}
