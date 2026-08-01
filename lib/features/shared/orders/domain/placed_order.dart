import 'package:agresell_app/features/shared/orders/domain/basket_cart_item.dart';
import 'package:agresell_app/features/shared/orders/domain/order_feedback.dart';
import 'package:agresell_app/features/shared/orders/domain/order_payment.dart';

enum PlacedOrderStatus {
  toPay,
  toShip,
  preparing,
  readyForPickup,
  shipping,
  delivered,
  cancelled,
}

extension PlacedOrderStatusLabel on PlacedOrderStatus {
  String get label {
    return switch (this) {
      PlacedOrderStatus.toPay => 'To Pay',
      PlacedOrderStatus.toShip => 'Awaiting farmer acceptance',
      PlacedOrderStatus.preparing => 'Farmer is preparing your order',
      PlacedOrderStatus.readyForPickup => 'Ready for rider pickup',
      PlacedOrderStatus.shipping => 'Shipping',
      PlacedOrderStatus.delivered => 'Completed',
      PlacedOrderStatus.cancelled => 'Cancelled',
    };
  }

  bool get canCancel {
    return switch (this) {
      PlacedOrderStatus.toPay || PlacedOrderStatus.toShip => true,
      PlacedOrderStatus.preparing ||
      PlacedOrderStatus.readyForPickup ||
      PlacedOrderStatus.shipping ||
      PlacedOrderStatus.delivered ||
      PlacedOrderStatus.cancelled => false,
    };
  }

  bool get canLeaveFeedback {
    return this == PlacedOrderStatus.delivered;
  }
}

class PlacedOrderItem {
  const PlacedOrderItem({
    required this.productId,
    required this.productName,
    required this.image,
    required this.sellerName,
    required this.pricePerKg,
    required this.unit,
    required this.quantity,
  });

  factory PlacedOrderItem.fromBasketItem(BasketCartItem item) {
    return PlacedOrderItem(
      productId: item.productId,
      productName: item.productName,
      image: item.image,
      sellerName: item.sellerName,
      pricePerKg: item.pricePerKg,
      unit: item.unit,
      quantity: item.quantity,
    );
  }

  final String productId;
  final String productName;
  final String image;
  final String sellerName;
  final double pricePerKg;
  final String unit;
  final int quantity;

  double get total => pricePerKg * quantity;
}

class PlacedOrder {
  const PlacedOrder({
    required this.id,
    required this.status,
    required this.placedAt,
    required this.deliveryAddress,
    required this.phoneNumber,
    required this.items,
    this.deliveryLatitude,
    this.deliveryLongitude,
    this.acceptanceExpiresAt,
    this.acceptanceExpiredAt,
    this.isRated = false,
    this.feedback,
    OrderPayment? payment,
  }) : payment = payment ?? const OrderPayment.cashOnDelivery();

  final String id;
  final PlacedOrderStatus status;
  final DateTime placedAt;
  final String deliveryAddress;
  final String phoneNumber;
  final List<PlacedOrderItem> items;
  final double? deliveryLatitude;
  final double? deliveryLongitude;
  final DateTime? acceptanceExpiresAt;
  final DateTime? acceptanceExpiredAt;
  final bool isRated;
  final OrderFeedback? feedback;
  final OrderPayment payment;

  bool get canLeaveFeedback {
    return status.canLeaveFeedback && !isRated;
  }

  bool get isExpired => acceptanceExpiredAt != null;
  bool get isAcceptanceOverdue {
    final deadline = acceptanceExpiresAt;
    return !isExpired &&
        status == PlacedOrderStatus.toShip &&
        deadline != null &&
        !DateTime.now().isBefore(deadline);
  }

  PlacedOrder copyWith({
    PlacedOrderStatus? status,
    bool? isRated,
    OrderFeedback? feedback,
    OrderPayment? payment,
    DateTime? acceptanceExpiresAt,
    DateTime? acceptanceExpiredAt,
  }) {
    return PlacedOrder(
      id: id,
      status: status ?? this.status,
      placedAt: placedAt,
      deliveryAddress: deliveryAddress,
      phoneNumber: phoneNumber,
      items: items,
      deliveryLatitude: deliveryLatitude,
      deliveryLongitude: deliveryLongitude,
      acceptanceExpiresAt: acceptanceExpiresAt ?? this.acceptanceExpiresAt,
      acceptanceExpiredAt: acceptanceExpiredAt ?? this.acceptanceExpiredAt,
      isRated: isRated ?? this.isRated,
      feedback: feedback ?? this.feedback,
      payment: payment ?? this.payment,
    );
  }

  int get totalQuantity {
    return items.fold<int>(0, (total, item) => total + item.quantity);
  }

  double get total {
    return items.fold<double>(0, (sum, item) => sum + item.total);
  }

  String get title {
    if (items.isEmpty) {
      return 'Order';
    }

    if (items.length == 1) {
      return items.first.productName;
    }

    return '${items.first.productName} + ${items.length - 1} more';
  }

  String get sellerLine {
    final sellers = items.map((item) => item.sellerName).toSet().toList();
    if (sellers.isEmpty) {
      return '';
    }

    return sellers.join(', ');
  }
}
