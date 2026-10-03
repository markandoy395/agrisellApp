import 'package:flutter/material.dart';

import 'package:agresell_app/features/rider/deliveries/domain/rider_nearby_farm.dart';
import 'package:agresell_app/features/rider/deliveries/presentation/styles/rider_map_marker_sheet_styles.dart';
import 'package:agresell_app/features/rider/deliveries/presentation/widgets/rider_map_marker_details.dart';

class RiderFarmMarkerContent extends StatelessWidget {
  const RiderFarmMarkerContent({
    required this.farm,
    required this.navigationBlockedByActiveDelivery,
    required this.onNavigate,
    super.key,
  });

  final RiderNearbyFarm farm;
  final bool navigationBlockedByActiveDelivery;
  final VoidCallback onNavigate;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      child: Padding(
        padding: RiderMapMarkerSheetStyles.sheetPadding,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const CircleAvatar(
                  backgroundColor: RiderMapMarkerSheetStyles.farmAvatarBg,
                  foregroundColor: RiderMapMarkerSheetStyles.farmAvatarFg,
                  child: Icon(Icons.agriculture_rounded),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        farm.name,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: RiderMapMarkerSheetStyles.titleTextStyle,
                      ),
                      Text(
                        farm.cropsLabel,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: RiderMapMarkerSheetStyles.subtitleTextStyle,
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),
            RiderMapMetricChip(
              icon: Icons.route_rounded,
              label: '${farm.distanceKm.toStringAsFixed(1)} km away',
            ),
            RiderMapDetailRow(
              label: 'Pickup',
              value: farm.address,
            ),
            const RiderMapDetailRow(
              label: 'Status',
              value: 'Verified farm',
            ),
            if (navigationBlockedByActiveDelivery) ...[
              const SizedBox(height: 8),
              const Text(
                'Your active delivery has navigation priority.',
                style: RiderMapMarkerSheetStyles.priorityWarningTextStyle,
              ),
            ],
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: FilledButton.icon(
                onPressed: navigationBlockedByActiveDelivery ? null : onNavigate,
                icon: const Icon(Icons.navigation_rounded),
                label: Text(
                  navigationBlockedByActiveDelivery
                      ? 'Active delivery has priority'
                      : 'Navigate to farm',
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
