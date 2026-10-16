part of 'rider_delivery_request_card.dart';

class RiderDeliveryRequestCardContent extends StatelessWidget {
  const RiderDeliveryRequestCardContent({
    required this.card,
    required this.acceptanceOpen,
    required this.onAccept,
    super.key,
  });
  final RiderDeliveryRequestCard card;
  final bool acceptanceOpen;
  final VoidCallback onAccept;

  @override
  Widget build(BuildContext context) {
    final request = card.request;
    return Container(
      decoration: RiderDeliveriesDesignStyles.card,
      padding: const EdgeInsets.all(14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          RiderDeliveryCardHeader(
            request: request,
            showPriority: true,
            pickupDistanceKm: card.pickupDistanceKm ?? request.routeDistanceKm,
            pickupTravelMinutes:
                card.pickupTravelMinutes ?? request.routeEstimatedTravelMinutes,
          ),
          const SizedBox(height: 14),
          RiderDeliveryAddressPair(request: request),
          const Divider(height: 24),
          Wrap(
            spacing: 16,
            runSpacing: 8,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'PHP ${request.deliveryFee.toStringAsFixed(2)}',
                    style: RiderDeliveriesDesignStyles.earning,
                  ),
                  Text(
                    'Est. earning',
                    style: RiderDeliveriesDesignStyles.caption,
                  ),
                ],
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    card.isPickupInsideRegisteredServiceArea
                        ? 'Pickup in service area'
                        : 'Pickup outside service area',
                    style: RiderDeliveriesDesignStyles.label,
                  ),
                  Text(
                    _vehicleSummary(request),
                    style: RiderDeliveriesDesignStyles.caption,
                  ),
                ],
              ),
            ],
          ),
          if (card.usesRegisteredLocationEstimate)
            Text(
              'Estimated from your registered service location',
              style: RiderDeliveriesDesignStyles.caption,
            ),
          if (request.handlingRequirements.isNotEmpty)
            Text(
              request.handlingRequirements
                  .map((item) => item.type.label)
                  .join(' | '),
              style: RiderDeliveriesDesignStyles.caption,
            ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed:
                      card.onViewDetails ??
                      () => showRiderRequestDetails(context, request),
                  style: RiderDeliveriesDesignStyles.secondary,
                  child: const Text('View details'),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Tooltip(
                  message: card.canAccept
                      ? 'Review and confirm this delivery.'
                      : 'You must be Online, Available, and have current GPS to accept.',
                  child: FilledButton(
                    onPressed:
                        card.canAccept &&
                            card.onAccept != null &&
                            !card.isAccepting &&
                            !acceptanceOpen
                        ? onAccept
                        : null,
                    style: RiderDeliveriesDesignStyles.primary,
                    child: Text(card.isAccepting ? 'Processing...' : 'Accept'),
                  ),
                ),
              ),
            ],
          ),
          if (card.onHide != null)
            Align(
              alignment: Alignment.centerRight,
              child: TextButton.icon(
                onPressed: () =>
                    showRiderRequestHideDialog(context, onHide: card.onHide!),
                icon: const Icon(Icons.visibility_off_outlined, size: 16),
                label: const Text('Hide this request'),
              ),
            ),
        ],
      ),
    );
  }
}

String _vehicleSummary(DeliveryRequest request) {
  final vehicles = request.requiredVehicleTypes.isEmpty
      ? 'Any compatible vehicle'
      : request.requiredVehicleTypes.map((item) => item.label).join(', ');
  final capacity = request.requiredCapacityKg ?? request.totalWeightKg;
  return capacity == null
      ? vehicles
      : '$vehicles | ${capacity.toStringAsFixed(0)} kg';
}
