import 'package:flutter/material.dart';

import 'package:agresell_app/core/theme/agrisell_colors.dart';
import 'package:agresell_app/features/farmer/reservations/domain/farmer_rider_candidate.dart';

class FarmerRiderDeliverySummary extends StatelessWidget {
  const FarmerRiderDeliverySummary({required this.selection, super.key});
  final FarmerRiderSelectionData selection;

  @override
  Widget build(BuildContext context) => DecoratedBox(
    decoration: BoxDecoration(
      color: AgrisellColors.surface,
      borderRadius: BorderRadius.circular(12),
      border: Border.all(color: AgrisellColors.borderLine),
    ),
    child: Padding(
      padding: const EdgeInsets.all(12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            selection.delivery.orderId,
            style: const TextStyle(
              color: AgrisellColors.headingGreen,
              fontSize: 13,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 5),
          Text(
            selection.delivery.goodsSummary,
            style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 4),
          _RouteLine(
            icon: Icons.storefront_outlined,
            label: 'Pickup',
            value: selection.delivery.pickupAddress,
          ),
          const SizedBox(height: 4),
          _RouteLine(
            icon: Icons.location_on_outlined,
            label: 'Delivery',
            value: selection.delivery.destination,
          ),
          if (selection.delivery.routeDistanceKm != null ||
              selection.delivery.estimatedDeliveryMinutes != null) ...[
            const SizedBox(height: 4),
            Text(
              [
                if (selection.delivery.routeDistanceKm != null)
                  '${selection.delivery.routeDistanceKm!.toStringAsFixed(1)} km route',
                if (selection.delivery.estimatedDeliveryMinutes != null)
                  '~${selection.delivery.estimatedDeliveryMinutes} min delivery',
              ].join(' - '),
              style: const TextStyle(
                color: AgrisellColors.mutedText,
                fontSize: 12,
                height: 1.35,
              ),
            ),
          ],
        ],
      ),
    ),
  );
}

class _RouteLine extends StatelessWidget {
  const _RouteLine({
    required this.icon,
    required this.label,
    required this.value,
  });

  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) => Row(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Icon(icon, size: 15, color: AgrisellColors.authGreen),
      const SizedBox(width: 5),
      Expanded(
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
          style: const TextStyle(
            color: AgrisellColors.mutedText,
            fontSize: 12,
            height: 1.35,
          ),
        ),
      ),
    ],
  );
}

class FarmerRiderGroupNotice extends StatelessWidget {
  const FarmerRiderGroupNotice({
    required this.icon,
    required this.message,
    super.key,
  });
  final IconData icon;
  final String message;

  @override
  Widget build(BuildContext context) => Row(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Icon(icon, size: 17, color: AgrisellColors.authGreen),
      const SizedBox(width: 7),
      Expanded(
        child: Text(
          message,
          style: const TextStyle(
            color: AgrisellColors.headingGreen,
            fontSize: 12,
            height: 1.35,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
    ],
  );
}

class FarmerRiderSelectionStateView extends StatelessWidget {
  const FarmerRiderSelectionStateView({
    required this.icon,
    required this.title,
    required this.message,
    this.actionLabel,
    this.onAction,
    this.isLoading = false,
    super.key,
  });
  final IconData icon;
  final String title;
  final String message;
  final String? actionLabel;
  final VoidCallback? onAction;
  final bool isLoading;

  @override
  Widget build(BuildContext context) => Center(
    child: Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (isLoading)
            const CircularProgressIndicator(color: AgrisellColors.authGreen)
          else
            Icon(icon, size: 42, color: AgrisellColors.authGreen),
          const SizedBox(height: 12),
          Text(
            title,
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 5),
          Text(
            message,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: AgrisellColors.mutedText,
              fontSize: 12,
              height: 1.4,
            ),
          ),
          if (actionLabel != null) ...[
            const SizedBox(height: 12),
            SizedBox(
              height: 38,
              child: FilledButton(
                onPressed: onAction,
                style: FilledButton.styleFrom(
                  backgroundColor: AgrisellColors.authGreen,
                ),
                child: Text(actionLabel!),
              ),
            ),
          ],
        ],
      ),
    ),
  );
}
