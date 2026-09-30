import 'package:flutter/material.dart';
import 'package:agresell_app/core/theme/agrisell_colors.dart';
import 'package:agresell_app/features/rider/deliveries/domain/delivery_request.dart';
import 'package:agresell_app/features/rider/deliveries/domain/delivery_stage.dart';
import 'package:agresell_app/features/rider/presentation/widgets/rider_page_widgets.dart';
import 'package:agresell_app/features/rider/presentation/widgets/rider_status_pills.dart';

class RiderActiveDeliverySummary extends StatelessWidget {
  const RiderActiveDeliverySummary({
    required this.delivery,
    required this.onContinue,
    required this.onOpenMap,
    super.key,
  });

  final DeliveryRequest? delivery;
  final VoidCallback onContinue, onOpenMap;

  @override
  Widget build(BuildContext context) {
    final active = delivery;
    if (active == null) {
      return RiderSurfaceCard(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const _IconBadge(
                  icon: Icons.route_outlined,
                  backgroundColor: AgrisellColors.statusBlueBackground,
                  foregroundColor: AgrisellColors.statusBlueText,
                ),
                const SizedBox(width: 12),
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'No active delivery',
                        style: TextStyle(
                          color: AgrisellColors.headingGreen,
                          fontSize: 15,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                      SizedBox(height: 4),
                      Text(
                        'Accepted jobs and route progress will appear here.',
                        style: TextStyle(
                          color: AgrisellColors.mutedText,
                          fontSize: 12,
                          height: 1.3,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: onContinue,
                icon: const Icon(Icons.local_shipping_outlined, size: 18),
                label: const Text('Browse delivery requests'),
              ),
            ),
          ],
        ),
      );
    }
    return RiderSurfaceCard(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _ProductImage(path: active.productImageUrl),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            active.productName,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              color: AgrisellColors.headingGreen,
                              fontSize: 15,
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          active.orderNumber,
                          style: const TextStyle(
                            color: AgrisellColors.mutedText,
                            fontSize: 12,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 7),
                    Wrap(
                      spacing: 7,
                      runSpacing: 7,
                      children: [
                        RiderStatusPill(
                          label: active.stage.label,
                          icon: Icons.route_outlined,
                          backgroundColor: AgrisellColors.statusGreenBackground,
                          foregroundColor: AgrisellColors.statusGreenText,
                        ),
                        if (active.deliveryFee > 0)
                          RiderStatusPill(
                            label:
                                'PHP ${active.deliveryFee.toStringAsFixed(2)}',
                            icon: Icons.payments_outlined,
                            backgroundColor:
                                AgrisellColors.statusBlueBackground,
                            foregroundColor: AgrisellColors.statusBlueText,
                          ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          _RouteStop(
            icon: Icons.storefront_outlined,
            label: 'Pickup',
            value: active.pickupLocation.address,
          ),
          const SizedBox(height: 8),
          _RouteStop(
            icon: Icons.location_on_outlined,
            label: 'Drop-off',
            value: active.deliveryLocation.address,
          ),
          const SizedBox(height: 12),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AgrisellColors.pageBackground,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AgrisellColors.borderLine),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Next: ${_nextAction(active.stage)}',
                  style: const TextStyle(
                    color: AgrisellColors.headingGreen,
                    fontSize: 12,
                    height: 1.25,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Pickup deadline: ${_deadline(active.pickupDeadline)}',
                  style: const TextStyle(
                    color: AgrisellColors.mutedText,
                    fontSize: 12,
                    height: 1.25,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              Expanded(
                child: FilledButton.icon(
                  onPressed: onContinue,
                  icon: const Icon(Icons.arrow_forward_rounded, size: 18),
                  label: const Text('Continue delivery'),
                ),
              ),
              if (_canOpenMap(active)) ...[
                const SizedBox(width: 8),
                OutlinedButton.icon(
                  onPressed: onOpenMap,
                  icon: const Icon(Icons.map_outlined, size: 18),
                  label: const Text('Map'),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }
}

class _RouteStop extends StatelessWidget {
  const _RouteStop({
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
      Container(
        width: 30,
        height: 30,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: AgrisellColors.forestSoft,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(icon, size: 17, color: AgrisellColors.authGreen),
      ),
      const SizedBox(width: 10),
      Expanded(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: const TextStyle(
                color: AgrisellColors.mutedText,
                fontSize: 12,
                height: 1.1,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              value,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                color: AgrisellColors.headingGreen,
                fontSize: 12,
                height: 1.25,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
      ),
    ],
  );
}

class _IconBadge extends StatelessWidget {
  const _IconBadge({
    required this.icon,
    required this.backgroundColor,
    required this.foregroundColor,
  });

  final IconData icon;
  final Color backgroundColor;
  final Color foregroundColor;

  @override
  Widget build(BuildContext context) => Container(
    width: 48,
    height: 48,
    alignment: Alignment.center,
    decoration: BoxDecoration(
      color: backgroundColor,
      borderRadius: BorderRadius.circular(14),
    ),
    child: Icon(icon, color: foregroundColor, size: 24),
  );
}

class _ProductImage extends StatelessWidget {
  const _ProductImage({this.path});

  final String? path;

  @override
  Widget build(BuildContext context) {
    final value = path;
    final image = value == null || value.isEmpty
        ? null
        : Uri.tryParse(value)?.hasScheme ?? false
        ? Image.network(value, fit: BoxFit.cover, errorBuilder: _errorBuilder)
        : Image.asset(value, fit: BoxFit.cover, errorBuilder: _errorBuilder);
    return ClipRRect(
      borderRadius: BorderRadius.circular(14),
      child: SizedBox.square(
        dimension: 62,
        child: image ?? _errorBuilder(context, Object(), null),
      ),
    );
  }

  Widget _errorBuilder(BuildContext context, Object error, StackTrace? stack) {
    return const ColoredBox(
      color: AgrisellColors.deliveryGray,
      child: Icon(Icons.inventory_2_outlined, color: AgrisellColors.mutedText),
    );
  }
}

bool _canOpenMap(DeliveryRequest request) =>
    request.pickupLocation.hasCoordinates ||
    request.deliveryLocation.hasCoordinates;

String _deadline(DateTime value) {
  final hour = value.hour % 12 == 0 ? 12 : value.hour % 12;
  final minute = value.minute.toString().padLeft(2, '0');
  final suffix = value.hour < 12 ? 'AM' : 'PM';
  return '${value.month}/${value.day} $hour:$minute $suffix';
}

String _nextAction(DeliveryStage stage) => switch (stage) {
  DeliveryStage.accepted => 'Start the route to pickup',
  DeliveryStage.goingToPickup => 'Navigate to the pickup location',
  DeliveryStage.arrivedAtPickup => 'Confirm pickup when the product is ready',
  DeliveryStage.pickedUp => 'Start the route to the buyer',
  DeliveryStage.goingToDelivery => 'Navigate to the delivery location',
  DeliveryStage.arrivedAtDelivery => 'Confirm the buyer handoff',
  DeliveryStage.delivered => 'Complete the delivery record',
  _ => 'Open the delivery for the next available action',
};
