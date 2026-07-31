import 'package:agresell_app/features/shared/orders/domain/order_status.dart';

const homeOrderStatuses = [
  OrderStatus(filter: OrderTrackingFilter.toPay),
  OrderStatus(filter: OrderTrackingFilter.toShip),
  OrderStatus(filter: OrderTrackingFilter.toReceive),
  OrderStatus(filter: OrderTrackingFilter.toRate),
  OrderStatus(filter: OrderTrackingFilter.completed),
];
