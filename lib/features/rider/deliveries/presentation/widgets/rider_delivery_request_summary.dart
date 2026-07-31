import 'package:flutter/material.dart';

import 'package:agresell_app/features/rider/deliveries/domain/delivery_request.dart';
import 'package:agresell_app/features/rider/deliveries/presentation/widgets/rider_delivery_request_details.dart';

class RiderRequestSummaryChips extends StatelessWidget {
  const RiderRequestSummaryChips({
    required this.request,
    this.pickupDistanceKm,
    this.pickupTravelMinutes,
    this.usesRegisteredLocationEstimate = false,
    super.key,
  });
  final DeliveryRequest request;
  final double? pickupDistanceKm;
  final int? pickupTravelMinutes;
  final bool usesRegisteredLocationEstimate;

  @override
  Widget build(BuildContext context) {
    final localizations = MaterialLocalizations.of(context);
    final deadline = request.pickupDeadline.toLocal();
    return Wrap(
      spacing: 8,
      runSpacing: 6,
      children: [
        RiderRequestMetaChip(
          icon: Icons.route_outlined,
          label: pickupDistanceKm == null
              ? 'Pickup route unavailable'
              : '${pickupDistanceKm!.toStringAsFixed(1)} km to pickup',
        ),
        RiderRequestMetaChip(
          icon: Icons.schedule_outlined,
          label: pickupTravelMinutes == null
              ? 'Pickup ETA unavailable'
              : '$pickupTravelMinutes min to pickup',
        ),
        if (usesRegisteredLocationEstimate)
          const RiderRequestMetaChip(
            icon: Icons.home_work_outlined,
            label: 'Estimated from your registered service location',
          ),
        RiderRequestMetaChip(
          icon: Icons.payments_outlined,
          label: 'PHP ${request.deliveryFee.toStringAsFixed(2)}',
        ),
        if (request.totalTripDistanceKm != null)
          RiderRequestMetaChip(
            icon: Icons.route_rounded,
            label:
                '${request.totalTripDistanceKm!.toStringAsFixed(1)} km total',
          ),
        if (request.totalTripMinutes != null)
          RiderRequestMetaChip(
            icon: Icons.timelapse_rounded,
            label: '${request.totalTripMinutes} min total',
          ),
        RiderRequestMetaChip(
          icon: Icons.event_outlined,
          label:
              '${localizations.formatShortDate(deadline)} '
              '${localizations.formatTimeOfDay(TimeOfDay.fromDateTime(deadline))}',
        ),
        if (request.quantityDescription.isNotEmpty)
          RiderRequestMetaChip(
            icon: Icons.inventory_2_outlined,
            label: request.quantityDescription,
          ),
        if (request.paymentMethod.isNotEmpty)
          RiderRequestMetaChip(
            icon: Icons.account_balance_wallet_outlined,
            label: request.paymentMethod,
          ),
      ],
    );
  }
}
