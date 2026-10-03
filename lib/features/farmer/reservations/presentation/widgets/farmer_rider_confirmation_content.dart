import 'package:flutter/material.dart';

import 'package:agresell_app/features/farmer/reservations/domain/farmer_rider_candidate.dart';
import 'package:agresell_app/features/farmer/reservations/presentation/styles/farmer_rider_confirmation_styles.dart';
import 'package:agresell_app/features/farmer/reservations/presentation/widgets/farmer_rider_confirmation_detail_row.dart';

class FarmerRiderConfirmationContent extends StatelessWidget {
  const FarmerRiderConfirmationContent({
    required this.rider,
    required this.delivery,
    super.key,
  });

  final FarmerRiderCandidate rider;
  final FarmerRiderDeliveryDetails delivery;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.maxFinite,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: FarmerRiderConfirmationStyles.riderCardPadding,
            decoration: FarmerRiderConfirmationStyles.riderCardDecoration,
            child: Row(
              children: [
                const CircleAvatar(
                  radius: 22,
                  backgroundColor: Colors.white,
                  child: Icon(
                    Icons.person_outline_rounded,
                    color: FarmerRiderConfirmationStyles.green,
                    size: 27,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'YOUR RIDER',
                        style: FarmerRiderConfirmationStyles.riderHeadingStyle,
                      ),
                      const SizedBox(height: 3),
                      Text(
                        rider.name,
                        style: FarmerRiderConfirmationStyles.riderNameStyle,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          FarmerRiderConfirmationDetailRow(
            icon: Icons.receipt_long_outlined,
            label: 'Order',
            value: delivery.orderId,
          ),
          FarmerRiderConfirmationDetailRow(
            icon: Icons.inventory_2_outlined,
            label: 'Goods',
            value: delivery.goodsSummary,
          ),
          const Divider(
            height: 22,
            color: FarmerRiderConfirmationStyles.dividerColor,
          ),
          FarmerRiderConfirmationDetailRow(
            icon: Icons.trip_origin_rounded,
            label: 'Pickup',
            value: delivery.pickupAddress,
          ),
          FarmerRiderConfirmationDetailRow(
            icon: Icons.location_on_outlined,
            label: 'Destination',
            value: delivery.destination,
          ),
          if (delivery.routeDistanceKm != null)
            Padding(
              padding: FarmerRiderConfirmationStyles.distancePadding,
              child: Text(
                '${delivery.routeDistanceKm!.toStringAsFixed(1)} km pickup to buyer',
                style: FarmerRiderConfirmationStyles.distanceTextStyle,
              ),
            ),
          FarmerRiderConfirmationDetailRow(
            icon: Icons.calendar_month_outlined,
            label: 'Schedule',
            value: MaterialLocalizations.of(
              context,
            ).formatFullDate(delivery.requestedSchedule),
          ),
          Container(
            width: double.infinity,
            padding: FarmerRiderConfirmationStyles.feeContainerPadding,
            decoration: FarmerRiderConfirmationStyles.feeContainerDecoration,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Proposed fee',
                  style: FarmerRiderConfirmationStyles.feeLabelStyle,
                ),
                const SizedBox(height: 3),
                Text(
                  rider.proposedDeliveryFee == null
                      ? 'To be confirmed'
                      : 'PHP ${rider.proposedDeliveryFee!.toStringAsFixed(2)}',
                  style: FarmerRiderConfirmationStyles.feeValueStyle,
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          Container(
            padding: FarmerRiderConfirmationStyles.notePadding,
            decoration: FarmerRiderConfirmationStyles.noteDecoration(
              rider.isOfflineManualCandidate,
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(
                  rider.isOfflineManualCandidate
                      ? Icons.schedule_rounded
                      : Icons.info_outline_rounded,
                  color: FarmerRiderConfirmationStyles.noteIconColor(
                    rider.isOfflineManualCandidate,
                  ),
                  size: 20,
                ),
                const SizedBox(width: 9),
                Expanded(
                  child: Text(
                    rider.isOfflineManualCandidate
                        ? 'This rider is offline. The booking expires in $offlineRiderBookingMinutes minutes unless the rider accepts.'
                        : 'The rider must accept before this order is assigned.',
                    style: FarmerRiderConfirmationStyles.noteTextStyle(
                      rider.isOfflineManualCandidate,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
