import 'package:flutter/material.dart';

import 'package:agresell_app/core/theme/agrisell_colors.dart';
import 'package:agresell_app/features/rider/deliveries/domain/delivery_request.dart';
import 'package:agresell_app/features/rider/deliveries/domain/delivery_stage.dart';
import 'package:agresell_app/features/rider/deliveries/domain/rider_nearby_farm.dart';
import 'package:agresell_app/features/rider/deliveries/presentation/widgets/rider_live_map.dart';

Future<bool> showRiderMapMarkerSheet(
  BuildContext context, {
  required DeliveryRequest request,
  required RiderMapMarkerKind kind,
  required double? distanceKm,
  required int? travelMinutes,
  required bool navigationBlockedByActiveDelivery,
}) async {
  final result = await showModalBottomSheet<bool>(
    context: context,
    showDragHandle: true,
    isScrollControlled: true,
    backgroundColor: AgrisellColors.surface,
    builder: (context) => SafeArea(
      top: false,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  backgroundColor: _color(kind).withValues(alpha: 0.14),
                  foregroundColor: _color(kind),
                  child: Icon(_icon(kind)),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _title(request, kind),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: AgrisellColors.headingGreen,
                          fontSize: 15,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      Text(
                        _subtitle(request, kind),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: AgrisellColors.mutedText,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                _MetricChip(
                  icon: Icons.route_rounded,
                  label: distanceKm == null
                      ? 'Distance unavailable'
                      : '${distanceKm.toStringAsFixed(1)} km away',
                ),
                _MetricChip(
                  icon: Icons.schedule_rounded,
                  label: travelMinutes == null
                      ? 'ETA after routing'
                      : 'About $travelMinutes min',
                ),
                _MetricChip(
                  icon: Icons.local_shipping_outlined,
                  label: request.assignedRiderId == null
                      ? 'No rider assigned'
                      : 'Assigned to you',
                ),
              ],
            ),
            const SizedBox(height: 14),
            _DetailRow(
              label: _locationLabel(request, kind),
              value: _selectedLocation(request, kind).address,
            ),
            if (kind != RiderMapMarkerKind.farmer)
              _DetailRow(
                label: 'Order',
                value: '${request.productName} · ${request.orderNumber}',
              ),
            _DetailRow(label: 'Status', value: request.stage.label),
            if (navigationBlockedByActiveDelivery) ...[
              const SizedBox(height: 8),
              const Text(
                'Your active delivery has navigation priority. Finish or exit '
                'that workflow before routing to this opportunity.',
                style: TextStyle(
                  color: AgrisellColors.statusOrangeText,
                  fontSize: 12,
                  height: 1.35,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: FilledButton.icon(
                onPressed: navigationBlockedByActiveDelivery
                    ? null
                    : () => Navigator.of(context).pop(true),
                icon: const Icon(Icons.navigation_rounded),
                label: Text(
                  navigationBlockedByActiveDelivery
                      ? 'Active delivery has priority'
                      : _navigateLabel(request, kind),
                ),
              ),
            ),
          ],
        ),
      ),
    ),
  );
  return result ?? false;
}

Future<bool> showRiderMapFarmSheet(
  BuildContext context, {
  required RiderNearbyFarm farm,
  required bool navigationBlockedByActiveDelivery,
}) async {
  final result = await showModalBottomSheet<bool>(
    context: context,
    showDragHandle: true,
    backgroundColor: AgrisellColors.surface,
    builder: (context) => SafeArea(
      top: false,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const CircleAvatar(
                  backgroundColor: AgrisellColors.forestSoft,
                  foregroundColor: AgrisellColors.headingGreen,
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
                        style: const TextStyle(
                          color: AgrisellColors.headingGreen,
                          fontSize: 15,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      Text(
                        farm.cropsLabel,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: AgrisellColors.mutedText,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),
            _MetricChip(
              icon: Icons.route_rounded,
              label: '${farm.distanceKm.toStringAsFixed(1)} km away',
            ),
            _DetailRow(label: 'Pickup', value: farm.address),
            const _DetailRow(label: 'Status', value: 'Verified farm'),
            if (navigationBlockedByActiveDelivery) ...[
              const SizedBox(height: 8),
              const Text(
                'Your active delivery has navigation priority.',
                style: TextStyle(
                  color: AgrisellColors.statusOrangeText,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: FilledButton.icon(
                onPressed: navigationBlockedByActiveDelivery
                    ? null
                    : () => Navigator.of(context).pop(true),
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
    ),
  );
  return result ?? false;
}

String _title(DeliveryRequest request, RiderMapMarkerKind kind) =>
    switch (kind) {
      RiderMapMarkerKind.farmer => request.sellerName,
      RiderMapMarkerKind.availableDelivery => request.productName,
      RiderMapMarkerKind.assignedDelivery =>
        request.stage.isDeliveryLeg ? 'Assigned delivery' : 'Assigned pickup',
    };

String _subtitle(DeliveryRequest request, RiderMapMarkerKind kind) =>
    kind == RiderMapMarkerKind.farmer
    ? 'Farm pickup with an eligible delivery opportunity'
    : request.sellerName;

IconData _icon(RiderMapMarkerKind kind) => switch (kind) {
  RiderMapMarkerKind.availableDelivery => Icons.inventory_2_rounded,
  RiderMapMarkerKind.farmer => Icons.agriculture_rounded,
  RiderMapMarkerKind.assignedDelivery => Icons.local_shipping_rounded,
};

Color _color(RiderMapMarkerKind kind) => switch (kind) {
  RiderMapMarkerKind.availableDelivery => AgrisellColors.statusBlueText,
  RiderMapMarkerKind.farmer => AgrisellColors.headingGreen,
  RiderMapMarkerKind.assignedDelivery => AgrisellColors.statusOrangeText,
};

DeliveryLocation _selectedLocation(
  DeliveryRequest request,
  RiderMapMarkerKind kind,
) => kind == RiderMapMarkerKind.assignedDelivery && request.stage.isDeliveryLeg
    ? request.deliveryLocation
    : request.pickupLocation;

String _locationLabel(DeliveryRequest request, RiderMapMarkerKind kind) =>
    kind == RiderMapMarkerKind.assignedDelivery && request.stage.isDeliveryLeg
    ? 'Delivery'
    : 'Pickup';

String _navigateLabel(DeliveryRequest request, RiderMapMarkerKind kind) =>
    kind == RiderMapMarkerKind.assignedDelivery && request.stage.isDeliveryLeg
    ? 'Navigate to delivery'
    : 'Navigate to pickup';

class _MetricChip extends StatelessWidget {
  const _MetricChip({required this.icon, required this.label});
  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) => DecoratedBox(
    decoration: BoxDecoration(
      color: AgrisellColors.homeBackground,
      borderRadius: BorderRadius.circular(18),
    ),
    child: Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 15, color: AgrisellColors.authGreen),
          const SizedBox(width: 5),
          Text(label, style: const TextStyle(fontSize: 12)),
        ],
      ),
    ),
  );
}

class _DetailRow extends StatelessWidget {
  const _DetailRow({required this.label, required this.value});
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(top: 8),
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 58,
          child: Text(
            label,
            style: const TextStyle(
              color: AgrisellColors.mutedText,
              fontSize: 12,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
        Expanded(
          child: Text(
            value,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(fontSize: 12, height: 1.35),
          ),
        ),
      ],
    ),
  );
}
