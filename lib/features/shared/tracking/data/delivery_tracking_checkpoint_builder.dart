import 'package:agresell_app/features/shared/orders/domain/placed_order.dart';
import 'package:agresell_app/features/shared/tracking/domain/delivery_tracking_models.dart';

/// Builds sequential progress checkpoints for delivery tracking.
abstract final class DeliveryTrackingCheckpointBuilder {
  static List<DeliveryTrackingCheckpoint> build({
    required PlacedOrder order,
    required DateTime now,
    double? riderLat,
    double? riderLng,
  }) {
    final status = order.status;
    return [
      DeliveryTrackingCheckpoint(
        id: 'placed',
        label: 'Order Placed',
        isCompleted: true,
        timestamp: order.placedAt,
        notes: 'Order received and confirmed',
      ),
      DeliveryTrackingCheckpoint(
        id: 'accepted',
        label: 'Order Accepted',
        isCompleted: status != PlacedOrderStatus.toPay &&
            status != PlacedOrderStatus.toShip,
        isActive: status == PlacedOrderStatus.toShip,
        timestamp: status != PlacedOrderStatus.toPay &&
                status != PlacedOrderStatus.toShip
            ? order.placedAt.add(const Duration(minutes: 10))
            : null,
        notes: 'Farmer verified and accepted order',
      ),
      DeliveryTrackingCheckpoint(
        id: 'preparing',
        label: 'Preparing Produce',
        isCompleted: status != PlacedOrderStatus.toPay &&
            status != PlacedOrderStatus.toShip &&
            status != PlacedOrderStatus.preparing,
        isActive: status == PlacedOrderStatus.preparing,
        timestamp: status == PlacedOrderStatus.readyForPickup ||
                status == PlacedOrderStatus.shipping ||
                status == PlacedOrderStatus.delivered
            ? order.placedAt.add(const Duration(minutes: 35))
            : null,
        notes: 'Produce harvested, weighed, and packed',
      ),
      DeliveryTrackingCheckpoint(
        id: 'ready',
        label: 'Ready for Pickup',
        isCompleted: status == PlacedOrderStatus.readyForPickup ||
            status == PlacedOrderStatus.shipping ||
            status == PlacedOrderStatus.delivered,
        isActive: status == PlacedOrderStatus.readyForPickup,
        timestamp: status == PlacedOrderStatus.shipping ||
                status == PlacedOrderStatus.delivered
            ? order.placedAt.add(const Duration(minutes: 50))
            : null,
        notes: 'Packed and waiting at farm for rider handover',
      ),
      DeliveryTrackingCheckpoint(
        id: 'shipping',
        label: 'Rider In Transit',
        isCompleted: status == PlacedOrderStatus.delivered,
        isActive: status == PlacedOrderStatus.shipping,
        timestamp: status == PlacedOrderStatus.shipping ||
                status == PlacedOrderStatus.delivered
            ? order.placedAt.add(const Duration(minutes: 65))
            : null,
        notes: 'Rider on the road en route to destination',
        latitude: riderLat,
        longitude: riderLng,
      ),
      DeliveryTrackingCheckpoint(
        id: 'delivered',
        label: 'Delivered',
        isCompleted: status == PlacedOrderStatus.delivered,
        isActive: false,
        timestamp: status == PlacedOrderStatus.delivered
            ? order.placedAt.add(const Duration(minutes: 90))
            : null,
        notes: 'Successfully delivered to buyer',
      ),
    ];
  }
}
