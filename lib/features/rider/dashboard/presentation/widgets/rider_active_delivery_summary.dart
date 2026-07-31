import 'package:flutter/material.dart';
import 'package:agresell_app/core/theme/agrisellColors.dart';
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
      return const RiderSurfaceCard(
        child: _SummaryLine(
          icon: Icons.route_outlined,
          text: 'No active delivery. Your current delivery will appear here.',
        ),
      );
    }
    return RiderSurfaceCard(
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
                    Text(
                      active.productName,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: AgrisellColors.headingGreen,
                        fontSize: 14,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 5),
                    RiderStatusPill(
                      label: active.stage.label,
                      icon: Icons.route_outlined,
                      backgroundColor: AgrisellColors.statusGreenBackground,
                      foregroundColor: AgrisellColors.statusGreenText,
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          _SummaryLine(
            icon: Icons.storefront_outlined,
            text: active.pickupLocation.address,
          ),
          const SizedBox(height: 6),
          _SummaryLine(
            icon: Icons.location_on_outlined,
            text: active.deliveryLocation.address,
          ),
          const SizedBox(height: 8),
          Text(
            'Next: ${_nextAction(active.stage)}',
            style: const TextStyle(
              color: AgrisellColors.headingGreen,
              fontSize: 12,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 3),
          Text(
            'Pickup deadline: ${_deadline(active.pickupDeadline)}',
            style: const TextStyle(
              color: AgrisellColors.mutedText,
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: FilledButton.icon(
                  onPressed: onContinue,
                  icon: const Icon(Icons.arrow_forward_rounded, size: 17),
                  label: const Text('Continue delivery'),
                ),
              ),
              if (_canOpenMap(active)) ...[
                const SizedBox(width: 8),
                OutlinedButton.icon(
                  onPressed: onOpenMap,
                  icon: const Icon(Icons.map_outlined, size: 17),
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

class _SummaryLine extends StatelessWidget {
  const _SummaryLine({required this.icon, required this.text});

  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) => Row(
    children: [
      Icon(icon, size: 18, color: AgrisellColors.mutedText),
      const SizedBox(width: 8),
      Expanded(
        child: Text(
          text,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(
            color: AgrisellColors.mutedText,
            fontSize: 12,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    ],
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
      borderRadius: BorderRadius.circular(10),
      child: SizedBox.square(
        dimension: 56,
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
