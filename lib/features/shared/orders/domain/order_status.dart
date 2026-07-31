import 'package:flutter/material.dart';

import 'package:agresell_app/features/shared/orders/domain/placed_order.dart';

enum OrderTrackingFilter {
  toPay,
  toShip,
  toReceive,
  toRate,
  completed,
  cancelled,
}

extension OrderTrackingFilterDetails on OrderTrackingFilter {
  String get label {
    return switch (this) {
      OrderTrackingFilter.toPay => 'To Pay',
      OrderTrackingFilter.toShip => 'To Ship',
      OrderTrackingFilter.toReceive => 'To Receive',
      OrderTrackingFilter.toRate => 'To Rate',
      OrderTrackingFilter.completed => 'Completed',
      OrderTrackingFilter.cancelled => 'Cancelled',
    };
  }

  IconData get icon {
    return switch (this) {
      OrderTrackingFilter.toPay => Icons.account_balance_wallet_outlined,
      OrderTrackingFilter.toShip => Icons.inventory_2_outlined,
      OrderTrackingFilter.toReceive => Icons.local_shipping_outlined,
      OrderTrackingFilter.toRate => Icons.star_outline_rounded,
      OrderTrackingFilter.completed => Icons.task_alt_outlined,
      OrderTrackingFilter.cancelled => Icons.cancel_outlined,
    };
  }

  bool matches(PlacedOrder order) {
    return switch (this) {
      OrderTrackingFilter.toPay => order.status == PlacedOrderStatus.toPay,
      OrderTrackingFilter.toShip =>
        order.status == PlacedOrderStatus.toShip ||
            order.status == PlacedOrderStatus.preparing ||
            order.status == PlacedOrderStatus.readyForPickup,
      OrderTrackingFilter.toReceive =>
        order.status == PlacedOrderStatus.shipping,
      OrderTrackingFilter.toRate => order.canLeaveFeedback,
      OrderTrackingFilter.completed =>
        order.status == PlacedOrderStatus.delivered && order.isRated,
      OrderTrackingFilter.cancelled =>
        order.status == PlacedOrderStatus.cancelled,
    };
  }
}

class OrderStatus {
  const OrderStatus({required this.filter});

  final OrderTrackingFilter filter;

  String get label => filter.label;
  IconData get icon => filter.icon;
}
