import 'package:flutter/material.dart';

import 'package:agresell_app/features/rider/dashboard/presentation/styles/rider_active_batch_summary_styles.dart';
import 'package:agresell_app/features/rider/dashboard/presentation/widgets/rider_active_batch_item_tile.dart';
import 'package:agresell_app/features/rider/deliveries/domain/delivery_request.dart';
import 'package:agresell_app/features/rider/deliveries/domain/rider_batch_delivery.dart';
import 'package:agresell_app/features/rider/presentation/widgets/rider_page_widgets.dart';

class RiderActiveBatchSummary extends StatelessWidget {
  const RiderActiveBatchSummary({
    required this.deliveries,
    required this.plan,
    required this.capacityKg,
    required this.onSelectDelivery,
    super.key,
  });

  final List<DeliveryRequest> deliveries;
  final RiderBatchPlan? plan;
  final double? capacityKg;
  final ValueChanged<String> onSelectDelivery;

  @override
  Widget build(BuildContext context) {
    final currentPlan = plan;
    final next = currentPlan?.stops.firstOrNull;
    final carriedWeight = deliveries.fold<double>(
      0,
      (total, item) => total + (item.totalWeightKg ?? 0),
    );
    final codTotal = deliveries.fold<double>(
      0,
      (total, item) => total + (item.cashOnDelivery?.amountToCollect ?? 0),
    );
    return RiderSurfaceCard(
      padding: RiderActiveBatchSummaryStyles.cardPadding,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(
                Icons.alt_route_rounded,
                color: RiderActiveBatchSummaryStyles.headerIconColor,
                size: RiderActiveBatchSummaryStyles.headerIconSize,
              ),
              RiderActiveBatchSummaryStyles.spacingSmall,
              Expanded(
                child: Text(
                  '${deliveries.length} active deliveries',
                  style: RiderActiveBatchSummaryStyles.headerTitleStyle,
                ),
              ),
            ],
          ),
          RiderActiveBatchSummaryStyles.spacingVertical,
          if (next != null)
            RiderBatchDetail(
              icon: next.type == RiderBatchStopType.pickup
                  ? Icons.storefront_outlined
                  : Icons.location_on_outlined,
              label: 'Next ${next.type.name}',
              value: next.location.address,
            )
          else
            const RiderBatchDetail(
              icon: Icons.route_outlined,
              label: 'Next stop',
              value: 'Open deliveries to review the available route details.',
            ),
          RiderActiveBatchSummaryStyles.spacingVertical,
          Wrap(
            spacing: RiderActiveBatchSummaryStyles.wrapSpacing,
            runSpacing: RiderActiveBatchSummaryStyles.wrapRunSpacing,
            children: [
              Text(
                capacityKg == null
                    ? 'Capacity: unavailable'
                    : 'Capacity: ${carriedWeight.toStringAsFixed(1)} / '
                          '${capacityKg!.toStringAsFixed(1)} kg',
                style: RiderActiveBatchSummaryStyles.metricStyle,
              ),
              Text(
                'COD total: PHP ${codTotal.toStringAsFixed(2)}',
                style: RiderActiveBatchSummaryStyles.metricStyle,
              ),
              if (currentPlan != null)
                Text(
                  'Route: ${currentPlan.totalDistanceKm.toStringAsFixed(1)} km',
                  style: RiderActiveBatchSummaryStyles.metricStyle,
                ),
            ],
          ),
          RiderActiveBatchSummaryStyles.spacingVertical,
          for (final delivery in deliveries)
            RiderActiveBatchItemTile(
              delivery: delivery,
              onTap: () => onSelectDelivery(delivery.id),
            ),
        ],
      ),
    );
  }
}
