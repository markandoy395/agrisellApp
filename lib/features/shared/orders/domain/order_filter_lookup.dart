import 'package:agresell_app/features/shared/orders/domain/order_status.dart';
import 'package:agresell_app/features/shared/orders/domain/placed_order.dart';

OrderTrackingFilter? orderFilterForLabel(String label) {
  for (final filter in OrderTrackingFilter.values) {
    if (filter.label == label) return filter;
  }
  return label == PlacedOrderStatus.shipping.label
      ? OrderTrackingFilter.toReceive
      : null;
}
