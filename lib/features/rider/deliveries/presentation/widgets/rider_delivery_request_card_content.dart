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
    final priority = riderRequestPriorityStyle(request.priority);
    return RiderSurfaceCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _header(request, priority),
          const SizedBox(height: 12),
          RiderRequestDetailLine(
            icon: Icons.storefront_outlined,
            text: 'Seller: ${request.sellerName}',
          ),
          RiderRequestDetailLine(
            icon: Icons.place_outlined,
            text: 'Pick up from: ${request.pickupLocation.address}',
          ),
          RiderRequestDetailLine(
            icon: Icons.location_on_outlined,
            text: 'Deliver to: ${request.deliveryLocation.address}',
          ),
          RiderRequestDetailLine(
            icon: card.isPickupInsideRegisteredServiceArea
                ? Icons.verified_outlined
                : Icons.location_off_outlined,
            text: card.isPickupInsideRegisteredServiceArea
                ? 'Pickup is inside your registered service area'
                : 'Pickup is outside your registered service area',
          ),
          const SizedBox(height: 9),
          RiderRequestSummaryChips(
            request: request,
            pickupDistanceKm: card.pickupDistanceKm ?? request.routeDistanceKm,
            pickupTravelMinutes:
                card.pickupTravelMinutes ?? request.routeEstimatedTravelMinutes,
            usesRegisteredLocationEstimate: card.usesRegisteredLocationEstimate,
          ),
          if (request.handlingRequirements.isNotEmpty) _handling(request),
          const SizedBox(height: 7),
          Text(_vehicleSummary(request), style: _metaStyle),
          const SizedBox(height: 12),
          _actions(context, request),
          if (card.onHide != null) _hideAction(context),
        ],
      ),
    );
  }

  Widget _header(DeliveryRequest request, RiderRequestPriorityStyle priority) =>
      Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          RiderRequestProductImage(
            url: request.productImageUrl,
            productName: request.productName,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  request.productName,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: RiderDeliveryRequestCardContentStyles.textStyle,
                ),
                const SizedBox(height: 5),
                Text('Order ${request.orderNumber}', style: _metaStyle),
              ],
            ),
          ),
          RiderStatusPill(
            label: priority.label,
            backgroundColor: priority.background,
            foregroundColor: priority.foreground,
          ),
        ],
      );

  Widget _handling(DeliveryRequest request) => Padding(
    padding: const EdgeInsets.only(top: 7),
    child: Text(
      request.handlingRequirements.map((item) => item.type.label).join(' | '),
      style: _metaStyle,
    ),
  );

  Widget _actions(BuildContext context, DeliveryRequest request) => Row(
    children: [
      Expanded(
        child: OutlinedButton(
          onPressed:
              card.onViewDetails ??
              () => showRiderRequestDetails(context, request),
          style: _outlinedStyle,
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
            style: _filledStyle,
            child: Text(card.isAccepting ? 'Processing...' : 'Accept'),
          ),
        ),
      ),
    ],
  );

  Widget _hideAction(BuildContext context) => Align(
    alignment: Alignment.centerRight,
    child: TextButton.icon(
      onPressed: () =>
          showRiderRequestHideDialog(context, onHide: card.onHide!),
      icon: const Icon(Icons.visibility_off_outlined, size: 16),
      label: const Text('Hide this request'),
    ),
  );
}

const _metaStyle = SharedPresentationStyles.mutedCaptionSemibold;

final _outlinedStyle = RiderDeliveryRequestCardContentStyles.buttonStyle;

final _filledStyle = RiderDeliveryRequestCardContentStyles.buttonStyle2;

String _vehicleSummary(DeliveryRequest request) {
  final vehicles = request.requiredVehicleTypes.isEmpty
      ? 'Any compatible vehicle'
      : request.requiredVehicleTypes.map((item) => item.label).join(', ');
  final requiredCapacity = request.requiredCapacityKg ?? request.totalWeightKg;
  final capacity = requiredCapacity == null
      ? 'capacity confirmed'
      : '${requiredCapacity.toStringAsFixed(0)} kg capacity confirmed';
  return 'Vehicle compatible: $vehicles | $capacity';
}
