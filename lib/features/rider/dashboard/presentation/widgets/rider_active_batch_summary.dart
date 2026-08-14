import 'package:flutter/material.dart';

import 'package:agresell_app/core/theme/agrisell_colors.dart';
import 'package:agresell_app/features/rider/deliveries/domain/delivery_request.dart';
import 'package:agresell_app/features/rider/deliveries/domain/delivery_stage.dart';
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
      padding: const EdgeInsets.all(14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(
                Icons.alt_route_rounded,
                color: AgrisellColors.authGreen,
                size: 20,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  '${deliveries.length} active deliveries',
                  style: const TextStyle(
                    color: AgrisellColors.headingGreen,
                    fontSize: 15,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          if (next != null)
            _BatchDetail(
              icon: next.type == RiderBatchStopType.pickup
                  ? Icons.storefront_outlined
                  : Icons.location_on_outlined,
              label: 'Next ${next.type.name}',
              value: next.location.address,
            )
          else
            const _BatchDetail(
              icon: Icons.route_outlined,
              label: 'Next stop',
              value: 'Open deliveries to review the available route details.',
            ),
          const SizedBox(height: 10),
          Wrap(
            spacing: 12,
            runSpacing: 6,
            children: [
              Text(
                capacityKg == null
                    ? 'Capacity: unavailable'
                    : 'Capacity: ${carriedWeight.toStringAsFixed(1)} / '
                          '${capacityKg!.toStringAsFixed(1)} kg',
                style: _metricStyle,
              ),
              Text(
                'COD total: PHP ${codTotal.toStringAsFixed(2)}',
                style: _metricStyle,
              ),
              if (currentPlan != null)
                Text(
                  'Route: ${currentPlan.totalDistanceKm.toStringAsFixed(1)} km',
                  style: _metricStyle,
                ),
            ],
          ),
          const SizedBox(height: 10),
          for (final delivery in deliveries)
            Padding(
              padding: const EdgeInsets.only(bottom: 6),
              child: InkWell(
                borderRadius: BorderRadius.circular(10),
                onTap: () => onSelectDelivery(delivery.id),
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 8,
                  ),
                  child: Row(
                    children: [
                      Icon(
                        delivery.stage.isDeliveryLeg
                            ? Icons.location_on_outlined
                            : Icons.storefront_outlined,
                        color: AgrisellColors.authGreen,
                        size: 18,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '${delivery.orderNumber} · ${delivery.productName}',
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                color: AgrisellColors.headingGreen,
                                fontSize: 12,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                            Text(
                              '${delivery.stage.isDeliveryLeg ? 'Delivery' : 'Pickup'} · '
                              '${_deadline(delivery)}',
                              style: const TextStyle(
                                color: AgrisellColors.mutedText,
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const Icon(
                        Icons.chevron_right_rounded,
                        color: AgrisellColors.mutedText,
                      ),
                    ],
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _BatchDetail extends StatelessWidget {
  const _BatchDetail({
    required this.icon,
    required this.label,
    required this.value,
  });

  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) => Row(
    children: [
      Icon(icon, color: AgrisellColors.authGreen, size: 18),
      const SizedBox(width: 8),
      Expanded(
        child: Text(
          '$label: $value',
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(
            color: AgrisellColors.headingGreenAlt,
            fontSize: 12,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
    ],
  );
}

const _metricStyle = TextStyle(
  color: AgrisellColors.mutedText,
  fontSize: 12,
  fontWeight: FontWeight.w700,
);

String _deadline(DeliveryRequest request) {
  final value = request.stage.isDeliveryLeg
      ? request.deliveryDeadline ?? request.pickupDeadline
      : request.pickupDeadline;
  final hour = value.hour.toString().padLeft(2, '0');
  final minute = value.minute.toString().padLeft(2, '0');
  return '$hour:$minute deadline';
}
