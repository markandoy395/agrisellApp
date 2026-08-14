import 'package:agresell_app/features/shared/orders/domain/placed_order.dart';

enum FarmerHistorySection { toShip, completed, feedback, confirm }

extension FarmerHistorySectionDetails on FarmerHistorySection {
  String get label => switch (this) {
    FarmerHistorySection.toShip => 'To Ship',
    FarmerHistorySection.completed => 'Completed',
    FarmerHistorySection.feedback => 'Feedback',
    FarmerHistorySection.confirm => 'Confirm',
  };

  bool matches(PlacedOrder order) => switch (this) {
    FarmerHistorySection.toShip =>
      order.status == PlacedOrderStatus.preparing ||
          order.status == PlacedOrderStatus.readyForPickup,
    FarmerHistorySection.completed =>
      order.status == PlacedOrderStatus.delivered,
    FarmerHistorySection.feedback =>
      order.status == PlacedOrderStatus.delivered &&
          (order.feedback != null ||
              order.items.any((item) => item.feedback != null)),
    FarmerHistorySection.confirm =>
      order.status == PlacedOrderStatus.toShip && !order.isExpired,
  };
}
