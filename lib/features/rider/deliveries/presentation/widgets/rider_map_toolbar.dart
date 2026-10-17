import 'package:flutter/material.dart';
import '../styles/rider_map_design_styles.dart';

class RiderMapToolbar extends StatelessWidget {
  const RiderMapToolbar({
    required this.radiusKm,
    required this.onOpenList,
    required this.onRefresh,
    required this.loading,
    this.onOpenNotifications,
    this.unreadNotifications = 0,
    super.key,
  });
  final double radiusKm;
  final VoidCallback onOpenList;
  final VoidCallback onRefresh;
  final bool loading;
  final VoidCallback? onOpenNotifications;
  final int unreadNotifications;

  @override
  Widget build(BuildContext context) => Container(
    decoration: RiderMapDesignStyles.header,
    child: SafeArea(
      bottom: false,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 12, 8, 12),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Map', style: RiderMapDesignStyles.title),
                  const SizedBox(height: 4),
                  Text(
                    'Your location, nearby pickups, and route',
                    style: RiderMapDesignStyles.caption,
                  ),
                ],
              ),
            ),
            IconButton(
              tooltip: 'Search pickups',
              onPressed: onOpenList,
              icon: const Icon(Icons.search),
            ),
            IconButton(
              tooltip: loading ? 'Refreshing map' : 'Refresh map',
              onPressed: loading ? null : onRefresh,
              icon: const Icon(Icons.refresh_rounded),
            ),
            if (onOpenNotifications != null)
              IconButton(
                tooltip: 'Notifications',
                onPressed: onOpenNotifications,
                icon: Badge(
                  isLabelVisible: unreadNotifications > 0,
                  label: Text('$unreadNotifications'),
                  child: const Icon(Icons.notifications_outlined),
                ),
              ),
          ],
        ),
      ),
    ),
  );
}
