import 'package:agresell_app/core/theme/shared_presentation_styles.dart';
import 'package:agresell_app/features/rider/deliveries/presentation/styles/rider_batch_delivery_summary_styles.dart';
import 'package:flutter/material.dart';

import 'package:agresell_app/core/theme/agrisell_colors.dart';
import 'package:agresell_app/features/rider/deliveries/domain/delivery_request.dart';
import 'package:agresell_app/features/rider/deliveries/domain/rider_batch_delivery.dart';
import 'package:agresell_app/features/rider/presentation/widgets/rider_page_widgets.dart';

class RiderBatchDeliverySummary extends StatelessWidget {
  const RiderBatchDeliverySummary({
    required this.deliveries,
    required this.plan,
    super.key,
  });

  final List<DeliveryRequest> deliveries;
  final RiderBatchPlan? plan;

  @override
  Widget build(BuildContext context) {
    final currentPlan = plan;
    return RiderSurfaceCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(
                Icons.alt_route_outlined,
                color: AgrisellColors.authGreen,
                size: 20,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  '${deliveries.length}-delivery batch',
                  style: SharedPresentationStyles.headingSubtitleExtraBold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          if (currentPlan == null)
            const Text(
              'Route planning needs verified coordinates and deadlines.',
              style: SharedPresentationStyles.mutedCaption,
            )
          else ...[
            Wrap(
              spacing: 12,
              runSpacing: 6,
              children: [
                _Metric(
                  label: 'Total route',
                  value: '${currentPlan.totalDistanceKm.toStringAsFixed(1)} km',
                ),
                _Metric(
                  label: 'Combined time',
                  value: '${currentPlan.estimatedTravelMinutes} min',
                ),
                _Metric(
                  label: 'Combined earning',
                  value:
                      'PHP ${currentPlan.combinedEarning.toStringAsFixed(2)}',
                ),
                _Metric(
                  label: 'Capacity left',
                  value:
                      '${currentPlan.remainingCapacityKg.toStringAsFixed(1)} kg',
                ),
                _Metric(
                  label: 'COD total',
                  value: 'PHP ${_codTotal(deliveries).toStringAsFixed(2)}',
                ),
              ],
            ),
            const SizedBox(height: 10),
            _StopSequence(title: 'Route order', stops: currentPlan.stops),
            const SizedBox(height: 8),
            _StopSequence(
              title: 'Pickup sequence',
              stops: currentPlan.pickupSequence,
            ),
            const SizedBox(height: 8),
            _StopSequence(
              title: 'Delivery sequence',
              stops: currentPlan.deliverySequence,
            ),
            if (currentPlan.handlingWarnings.isNotEmpty) ...[
              const SizedBox(height: 8),
              Text(
                'Handling: ${currentPlan.handlingWarnings.join(' • ')}',
                style: SharedPresentationStyles.mutedCaptionSemibold,
              ),
            ],
          ],
          const SizedBox(height: 10),
          for (final delivery in deliveries)
            Padding(
              padding: const EdgeInsets.only(bottom: 5),
              child: Text(
                '${delivery.orderNumber} • ${delivery.productName} • '
                '${_deadline(delivery)} • PHP ${delivery.deliveryFee.toStringAsFixed(2)}',
                style: RiderBatchDeliverySummaryStyles.textStyle,
              ),
            ),
        ],
      ),
    );
  }
}

class _Metric extends StatelessWidget {
  const _Metric({required this.label, required this.value});
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) => Semantics(
    label: '$label $value',
    child: Text(
      '$label: $value',
      style: RiderBatchDeliverySummaryStyles.textStyle2,
    ),
  );
}

class _StopSequence extends StatelessWidget {
  const _StopSequence({required this.title, required this.stops});
  final String title;
  final List<RiderBatchStop> stops;

  @override
  Widget build(BuildContext context) => Text(
    '$title: ${stops.isEmpty ? 'None' : stops.map((stop) => '${stop.sequence}. ${stop.location.address}').join('  →  ')}',
    style: RiderBatchDeliverySummaryStyles.textStyle3,
  );
}

String _deadline(DeliveryRequest delivery) {
  final value = delivery.deliveryDeadline ?? delivery.pickupDeadline;
  final hour = value.hour.toString().padLeft(2, '0');
  final minute = value.minute.toString().padLeft(2, '0');
  return 'deadline $hour:$minute';
}

double _codTotal(Iterable<DeliveryRequest> deliveries) => deliveries.fold(
  0,
  (total, delivery) => total + (delivery.cashOnDelivery?.amountToCollect ?? 0),
);
