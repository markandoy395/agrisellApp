import 'dart:async';
import 'dart:collection';
import 'package:flutter/material.dart';
import 'package:agresell_app/features/auth/domain/signUpAccountData.dart';
import 'package:agresell_app/features/shared/orders/data/order_notification_factory.dart';
import 'package:agresell_app/features/shared/orders/domain/basket_cart_item.dart';
import 'package:agresell_app/features/shared/orders/domain/home_notification.dart';
import 'package:agresell_app/features/shared/orders/domain/order_filter_lookup.dart';
import 'package:agresell_app/features/shared/orders/domain/order_status.dart';
import 'package:agresell_app/features/shared/orders/domain/order_feedback.dart';
import 'package:agresell_app/features/shared/orders/domain/order_payment.dart';
import 'package:agresell_app/features/shared/orders/domain/order_acceptance_policy.dart';
import 'package:agresell_app/features/shared/orders/data/cached_order_repository.dart';
import 'package:agresell_app/features/shared/orders/data/order_repository.dart';
import 'package:agresell_app/features/shared/orders/domain/placed_order.dart';

part 'order_controller_mutations.dart';
part 'order_controller_persistence.dart';
part 'order_controller_placement.dart';
part 'order_controller_reviews.dart';
part 'order_controller_payments.dart';

class OrderController extends ChangeNotifier {
  OrderController({OrderRepository? repository})
    : _repository = repository ?? CachedOrderRepository();
  static final OrderController instance = OrderController();
  final OrderRepository _repository;
  String? _accountId;
  var _loadGeneration = 0;
  Future<void> _pendingPersistence = Future<void>.value();
  final List<PlacedOrder> _orders = <PlacedOrder>[];
  final List<HomeNotification> _orderNotifications = <HomeNotification>[];
  final Set<String> _readNotificationIds = <String>{};
  late final List<PlacedOrder> _ordersView = UnmodifiableListView(_orders);
  late final List<HomeNotification> _orderNotificationsView =
      UnmodifiableListView(_orderNotifications);
  final Map<PlacedOrderStatus, List<PlacedOrder>> _statusCache = {};
  final Map<OrderTrackingFilter, List<PlacedOrder>> _filterCache = {};
  List<PlacedOrder> get orders => _ordersView;
  List<HomeNotification> get orderNotifications => _orderNotificationsView;
  bool isNotificationRead(HomeNotification notification) {
    return notification.isRead ||
        _readNotificationIds.contains(notification.id);
  }

  void markNotificationRead(HomeNotification notification) {
    if (isNotificationRead(notification)) return;
    final index = _orderNotifications.indexWhere(
      (item) => item.id == notification.id,
    );
    if (index != -1) {
      _orderNotifications[index] = _orderNotifications[index].copyWith(
        isRead: true,
      );
    } else if (notification.id.isNotEmpty) {
      _readNotificationIds.add(notification.id);
    }
    notifyListeners();
  }

  void markAllNotificationsRead(Iterable<HomeNotification> notifications) {
    var changed = false;
    for (final notification in notifications) {
      if (isNotificationRead(notification)) continue;
      final index = _orderNotifications.indexWhere(
        (item) => item.id == notification.id,
      );
      if (index != -1) {
        _orderNotifications[index] = _orderNotifications[index].copyWith(
          isRead: true,
        );
      } else if (notification.id.isNotEmpty) {
        _readNotificationIds.add(notification.id);
      }
      changed = true;
    }
    if (changed) notifyListeners();
  }

  List<PlacedOrder> get toShipOrders {
    return ordersForFilter(OrderTrackingFilter.toShip);
  }

  List<PlacedOrder> ordersForStatus(PlacedOrderStatus status) {
    return _statusCache.putIfAbsent(
      status,
      () => List<PlacedOrder>.unmodifiable(
        _orders.where((order) => order.status == status),
      ),
    );
  }

  int countForStatus(PlacedOrderStatus status) {
    return ordersForStatus(status).length;
  }

  List<PlacedOrder> ordersForFilter(OrderTrackingFilter filter) {
    return _filterCache.putIfAbsent(
      filter,
      () => List<PlacedOrder>.unmodifiable(_orders.where(filter.matches)),
    );
  }

  int countForFilter(OrderTrackingFilter filter) {
    return ordersForFilter(filter).length;
  }

  int countForLabel(String label) {
    final filter = orderFilterForLabel(label);
    return filter == null ? 0 : countForFilter(filter);
  }

  int get activeFarmerReservationCount {
    return _orders.where((order) {
      return order.status != PlacedOrderStatus.delivered &&
          (order.status != PlacedOrderStatus.cancelled ||
              order.payment.needsFarmerReview ||
              order.payment.status == OrderPaymentStatus.refundRequired);
    }).length;
  }

  List<PlacedOrder> ordersForLabel(String label) {
    final filter = orderFilterForLabel(label);
    return filter == null ? const <PlacedOrder>[] : ordersForFilter(filter);
  }

  void _addOrderNotification({
    required PlacedOrder order,
    required String title,
    required String description,
    Set<AuthRole> visibleTo = const {AuthRole.buyer, AuthRole.farmer},
  }) {
    _orderNotifications.insert(
      0,
      orderNotification(
        order: order,
        title: title,
        description: description,
        visibleTo: visibleTo,
      ),
    );
  }

  void _commitChange({bool persist = true}) {
    _statusCache.clear();
    _filterCache.clear();
    notifyListeners();
    if (persist) unawaited(_persistOrdersSilently());
  }
}
