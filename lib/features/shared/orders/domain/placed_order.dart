import 'package:agresell_app/features/shared/orders/domain/order_dispute.dart';
import 'package:agresell_app/features/shared/orders/domain/order_feedback.dart';
import 'package:agresell_app/features/shared/orders/domain/order_payment.dart';
import 'package:agresell_app/features/shared/orders/domain/placed_order_item.dart';
import 'package:agresell_app/features/shared/orders/domain/placed_order_status.dart';

export 'package:agresell_app/features/shared/orders/domain/placed_order_item.dart';
export 'package:agresell_app/features/shared/orders/domain/placed_order_status.dart';

class PlacedOrder {
  const PlacedOrder({
    required this.id,
    required this.status,
    required this.placedAt,
    required this.deliveryAddress,
    required this.phoneNumber,
    required this.items,
    this.buyerId = '',
    this.buyerName = '',
    this.deliveryLatitude,
    this.deliveryLongitude,
    this.acceptanceExpiresAt,
    this.acceptanceExpiredAt,
    this.isRated = false,
    this.feedback,
    this.deliveryId,
    this.riderRated = false,
    this.cancellationReason,
    this.cancelledBy,
    this.cancelledAt,
    this.dispute,
    OrderPayment? payment,
  }) : payment = payment ?? const OrderPayment.cashOnDelivery();

  final String id;
  final String buyerId;
  final String buyerName;
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
  final String? deliveryId;
  final bool riderRated;
  final String? cancellationReason;
  final String? cancelledBy;
  final DateTime? cancelledAt;
  final OrderDispute? dispute;
  final OrderPayment payment;

  bool get hasDispute => dispute != null;
  bool get canDispute => status == PlacedOrderStatus.delivered && dispute == null;

  bool get canLeaveFeedback {
    if (!status.canLeaveFeedback) return false;
    final hasUnreviewedProduct =
        !isRated && (items.isEmpty || items.any((item) => item.feedback == null));
    final canRateRider = deliveryId != null && !riderRated;
    return hasUnreviewedProduct || canRateRider;
  }

  bool canReviewProduct(String productId) =>
      status.canLeaveFeedback &&
      !isRated &&
      items.any((item) => item.productId == productId && item.feedback == null);

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
    List<PlacedOrderItem>? items,
    String? deliveryId,
    bool? riderRated,
    String? cancellationReason,
    String? cancelledBy,
    DateTime? cancelledAt,
    OrderDispute? dispute,
  }) {
    return PlacedOrder(
      id: id,
      buyerId: buyerId,
      buyerName: buyerName,
      status: status ?? this.status,
      placedAt: placedAt,
      deliveryAddress: deliveryAddress,
      phoneNumber: phoneNumber,
      items: items ?? this.items,
      deliveryLatitude: deliveryLatitude,
      deliveryLongitude: deliveryLongitude,
      acceptanceExpiresAt: acceptanceExpiresAt ?? this.acceptanceExpiresAt,
      acceptanceExpiredAt: acceptanceExpiredAt ?? this.acceptanceExpiredAt,
      isRated: isRated ?? this.isRated,
      feedback: feedback ?? this.feedback,
      deliveryId: deliveryId ?? this.deliveryId,
      riderRated: riderRated ?? this.riderRated,
      cancellationReason: cancellationReason ?? this.cancellationReason,
      cancelledBy: cancelledBy ?? this.cancelledBy,
      cancelledAt: cancelledAt ?? this.cancelledAt,
      dispute: dispute ?? this.dispute,
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
