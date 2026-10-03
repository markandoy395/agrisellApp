import 'package:agresell_app/core/theme/shared_presentation_styles.dart';
import 'package:agresell_app/features/farmer/reservations/presentation/styles/farmer_rider_selection_states_styles.dart';
import 'package:agresell_app/features/farmer/reservations/presentation/styles/farmer_rider_request_styles.dart';
import 'package:flutter/material.dart';

import 'package:agresell_app/core/theme/agrisell_colors.dart';
import 'package:agresell_app/features/farmer/reservations/domain/farmer_rider_candidate.dart';

class FarmerRiderDeliverySummary extends StatelessWidget {
  const FarmerRiderDeliverySummary({required this.selection, super.key});
  final FarmerRiderSelectionData selection;

  @override
  Widget build(BuildContext context) => DecoratedBox(
    decoration: SharedPresentationStyles.borderedSurface,
    child: Padding(
      padding: const EdgeInsets.all(12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            selection.delivery.orderId,
            style: SharedPresentationStyles.headingBodyExtraBold,
          ),
          const SizedBox(height: 5),
          Text(
            selection.delivery.goodsSummary,
            style: SharedPresentationStyles.captionBold,
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
              style: SharedPresentationStyles.mutedCaptionLoose,
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
                style: SharedPresentationStyles.extraBold,
              ),
              TextSpan(text: value),
            ],
          ),
          style: SharedPresentationStyles.mutedCaptionLoose,
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
          style: FarmerRiderSelectionStatesStyles.messageText,
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
            style: SharedPresentationStyles.subtitleExtraBold,
          ),
          const SizedBox(height: 5),
          Text(
            message,
            textAlign: TextAlign.center,
            style: FarmerRiderSelectionStatesStyles.messageText2,
          ),
          if (actionLabel != null) ...[
            const SizedBox(height: 12),
            SizedBox(
              height: 38,
              child: FilledButton(
                onPressed: onAction,
                style: FarmerRiderRequestStyles.chooseAnotherButtonStyle,
                child: Text(actionLabel!),
              ),
            ),
          ],
        ],
      ),
    ),
  );
}
