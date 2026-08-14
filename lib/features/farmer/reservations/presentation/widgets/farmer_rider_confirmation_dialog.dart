import 'package:flutter/material.dart';

import 'package:agresell_app/core/theme/agrisell_colors.dart';
import 'package:agresell_app/features/farmer/reservations/domain/farmer_rider_candidate.dart';

Future<bool> showFarmerRiderConfirmationDialog(
  BuildContext context, {
  required FarmerRiderCandidate rider,
  required FarmerRiderDeliveryDetails delivery,
}) async {
  return await showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text(
            'Confirm rider request',
            style: TextStyle(fontSize: 15, fontWeight: FontWeight.w800),
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _line('Rider', rider.name),
                _line('Order', delivery.orderId),
                _line('Goods', delivery.goodsSummary),
                _line('Pickup', delivery.pickupAddress),
                _line('Destination', delivery.destination),
                if (delivery.routeDistanceKm != null)
                  _line(
                    'Route',
                    '${delivery.routeDistanceKm!.toStringAsFixed(1)} km pickup to buyer',
                  ),
                _line(
                  'Schedule',
                  MaterialLocalizations.of(
                    context,
                  ).formatFullDate(delivery.requestedSchedule),
                ),
                _line(
                  'Proposed fee',
                  rider.proposedDeliveryFee == null
                      ? 'To be confirmed'
                      : 'PHP ${rider.proposedDeliveryFee!.toStringAsFixed(2)}',
                ),
                const SizedBox(height: 8),
                Text(
                  rider.isOfflineManualCandidate
                      ? 'This rider is offline. The booking expires in '
                            '$offlineRiderBookingMinutes minutes unless the '
                            'rider accepts.'
                      : 'The rider must accept before this order is assigned.',
                  style: const TextStyle(
                    color: AgrisellColors.mutedText,
                    fontSize: 12,
                    height: 1.35,
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('Back'),
            ),
            FilledButton(
              onPressed: () => Navigator.of(context).pop(true),
              style: FilledButton.styleFrom(
                backgroundColor: AgrisellColors.authGreen,
              ),
              child: const Text('Send request'),
            ),
          ],
        ),
      ) ??
      false;
}

Widget _line(String label, String value) => Padding(
  padding: const EdgeInsets.only(bottom: 7),
  child: Text.rich(
    TextSpan(
      children: [
        TextSpan(
          text: '$label: ',
          style: const TextStyle(fontWeight: FontWeight.w800),
        ),
        TextSpan(text: value),
      ],
    ),
    style: const TextStyle(fontSize: 12, height: 1.35),
  ),
);
