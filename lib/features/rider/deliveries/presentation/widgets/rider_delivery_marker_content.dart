import 'package:flutter/material.dart';

import 'package:agresell_app/features/rider/deliveries/domain/delivery_request.dart';
import 'package:agresell_app/features/rider/deliveries/domain/delivery_stage.dart';
import 'package:agresell_app/features/rider/deliveries/presentation/styles/rider_map_marker_sheet_styles.dart';
import 'package:agresell_app/features/rider/deliveries/presentation/widgets/rider_live_map.dart';
import 'package:agresell_app/features/rider/deliveries/presentation/widgets/rider_map_marker_details.dart';

class RiderDeliveryMarkerContent extends StatelessWidget {
  const RiderDeliveryMarkerContent({
    required this.request,
    required this.kind,
    required this.distanceKm,
    required this.travelMinutes,
    required this.navigationBlockedByActiveDelivery,
    required this.onNavigate,
    super.key,
  });

  final DeliveryRequest request;
  final RiderMapMarkerKind kind;
  final double? distanceKm;
  final int? travelMinutes;
  final bool navigationBlockedByActiveDelivery;
  final VoidCallback onNavigate;

  String get _title => switch (kind) {
    RiderMapMarkerKind.farmer => request.sellerName,
    RiderMapMarkerKind.availableDelivery => request.productName,
    RiderMapMarkerKind.assignedDelivery =>
      request.stage.isDeliveryLeg ? 'Assigned delivery' : 'Assigned pickup',
  };

  String get _subtitle => kind == RiderMapMarkerKind.farmer
      ? 'Farm pickup with an eligible delivery opportunity'
      : request.sellerName;

  DeliveryLocation get _selectedLocation =>
      kind == RiderMapMarkerKind.assignedDelivery && request.stage.isDeliveryLeg
          ? request.deliveryLocation
          : request.pickupLocation;

  String get _locationLabel =>
      kind == RiderMapMarkerKind.assignedDelivery && request.stage.isDeliveryLeg
          ? 'Delivery'
          : 'Pickup';

  String get _navigateLabel =>
      kind == RiderMapMarkerKind.assignedDelivery && request.stage.isDeliveryLeg
          ? 'Navigate to delivery'
          : 'Navigate to pickup';

  @override
  Widget build(BuildContext context) {
    final distanceText = distanceKm == null
        ? 'Distance unavailable'
        : '${distanceKm!.toStringAsFixed(1)} km away';
    final etaText = travelMinutes == null
        ? 'ETA after routing'
        : 'About $travelMinutes min';
    final assignmentText = request.assignedRiderId == null
        ? 'No rider assigned'
        : 'Assigned to you';

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
                CircleAvatar(
                  backgroundColor: RiderMapMarkerSheetStyles.markerAvatarBg(kind),
                  foregroundColor: RiderMapMarkerSheetStyles.markerColor(kind),
                  child: Icon(RiderMapMarkerSheetStyles.markerIcon(kind)),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _title,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: RiderMapMarkerSheetStyles.titleTextStyle,
                      ),
                      Text(
                        _subtitle,
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
            Wrap(
              spacing: RiderMapMarkerSheetStyles.chipSpacing,
              runSpacing: RiderMapMarkerSheetStyles.chipRunSpacing,
              children: [
                RiderMapMetricChip(
                  icon: Icons.route_rounded,
                  label: distanceText,
                ),
                RiderMapMetricChip(
                  icon: Icons.schedule_rounded,
                  label: etaText,
                ),
                RiderMapMetricChip(
                  icon: Icons.local_shipping_outlined,
                  label: assignmentText,
                ),
              ],
            ),
            const SizedBox(height: 14),
            RiderMapDetailRow(
              label: _locationLabel,
              value: _selectedLocation.address,
            ),
            if (kind != RiderMapMarkerKind.farmer)
              RiderMapDetailRow(
                label: 'Order',
                value: '${request.productName} · ${request.orderNumber}',
              ),
            RiderMapDetailRow(
              label: 'Status',
              value: request.stage.label,
            ),
            if (navigationBlockedByActiveDelivery) ...[
              const SizedBox(height: 8),
              const Text(
                'Your active delivery has navigation priority. Finish or exit '
                'that workflow before routing to this opportunity.',
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
                      : _navigateLabel,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
