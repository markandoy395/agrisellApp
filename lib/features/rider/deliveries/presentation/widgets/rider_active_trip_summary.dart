import 'package:flutter/material.dart';
import 'package:agresell_app/core/theme/agrisell_colors.dart';
import '../../domain/delivery_request.dart';
import '../../domain/rider_batch_delivery.dart';
import '../styles/rider_deliveries_design_styles.dart';
import 'rider_batch_delivery_summary.dart';

class RiderActiveTripSummary extends StatelessWidget {
  const RiderActiveTripSummary({
    required this.deliveries,
    this.plan,
    this.capacityKg,
    super.key,
  });
  final List<DeliveryRequest> deliveries;
  final RiderBatchPlan? plan;
  final double? capacityKg;

  @override
  Widget build(BuildContext context) {
    final hasWeights = deliveries.every((item) => item.totalWeightKg != null);
    final weight = deliveries.fold<double>(
      0,
      (sum, item) => sum + (item.totalWeightKg ?? 0),
    );
    final cod = deliveries.fold<double>(
      0,
      (sum, item) => sum + (item.cashOnDelivery?.amountToCollect ?? 0),
    );
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Container(
          decoration: RiderDeliveriesDesignStyles.inset,
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              const Icon(
                Icons.inventory_2_outlined,
                color: AgrisellColors.authGreen,
                size: 28,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${deliveries.length} active ${deliveries.length == 1 ? 'delivery' : 'deliveries'}',
                      style: RiderDeliveriesDesignStyles.title,
                    ),
                    Text(
                      'Complete your current trips',
                      style: RiderDeliveriesDesignStyles.caption,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 10),
        Container(
          decoration: RiderDeliveriesDesignStyles.card,
          padding: const EdgeInsets.all(14),
          child: Wrap(
            spacing: 20,
            runSpacing: 10,
            children: [
              _metric(
                'Total load',
                hasWeights
                    ? '${weight.toStringAsFixed(0)}${capacityKg == null ? '' : ' / ${capacityKg!.toStringAsFixed(0)}'} kg'
                    : 'Not available',
              ),
              _metric('COD total', 'PHP ${cod.toStringAsFixed(2)}'),
              _metric(
                'Route',
                plan == null
                    ? 'Not planned'
                    : '${plan!.totalDistanceKm.toStringAsFixed(1)} km',
              ),
            ],
          ),
        ),
        if (plan != null)
          ExpansionTile(
            key: const PageStorageKey<String>('rider-active-route-details'),
            title: Text(
              'Route and handling details',
              style: RiderDeliveriesDesignStyles.label,
            ),
            children: [
              RiderBatchDeliverySummary(deliveries: deliveries, plan: plan),
            ],
          ),
      ],
    );
  }

  Widget _metric(String label, String value) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(value, style: RiderDeliveriesDesignStyles.label),
      Text(label, style: RiderDeliveriesDesignStyles.caption),
    ],
  );
}
