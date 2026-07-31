import 'package:agresell_app/features/shared/orders/domain/placed_order.dart';
import 'package:agresell_app/features/shared/orders/domain/order_feedback.dart';
import 'package:agresell_app/features/shared/orders/domain/order_payment.dart';

class OrderJsonCodec {
  const OrderJsonCodec._();

  static List<Map<String, Object?>> encodeOrders(
    Iterable<PlacedOrder> orders,
  ) => orders.map(encodeOrder).toList(growable: false);

  static List<PlacedOrder> decodeOrders(Object? value) {
    if (value is! List) return const [];
    return value
        .map(decodeOrder)
        .whereType<PlacedOrder>()
        .toList(growable: false);
  }

  static Map<String, Object?> encodeOrder(PlacedOrder order) => {
    'id': order.id,
    'status': order.status.name,
    'placedAt': order.placedAt.toIso8601String(),
    'deliveryAddress': order.deliveryAddress,
    if (order.deliveryLatitude != null)
      'deliveryLatitude': order.deliveryLatitude,
    if (order.deliveryLongitude != null)
      'deliveryLongitude': order.deliveryLongitude,
    if (order.acceptanceExpiresAt != null)
      'acceptanceExpiresAt': order.acceptanceExpiresAt!.toIso8601String(),
    if (order.acceptanceExpiredAt != null)
      'acceptanceExpiredAt': order.acceptanceExpiredAt!.toIso8601String(),
    'phoneNumber': order.phoneNumber,
    'isRated': order.isRated,
    'payment': {
      'method': order.payment.method.databaseValue,
      'status': order.payment.status.databaseValue,
      'transactionReference': order.payment.transactionReference,
      'refundReference': order.payment.refundReference,
    },
    if (order.feedback case final feedback?)
      'feedback': {
        'rating': feedback.rating,
        'comment': feedback.comment,
        'submittedAt': feedback.submittedAt.toIso8601String(),
      },
    'items': order.items
        .map(
          (item) => {
            'productId': item.productId,
            'productName': item.productName,
            'image': item.image,
            'sellerName': item.sellerName,
            'pricePerKg': item.pricePerKg,
            'unit': item.unit,
            'quantity': item.quantity,
          },
        )
        .toList(growable: false),
  };

  static PlacedOrder? decodeOrder(Object? value) {
    if (value is! Map) return null;
    final json = Map<String, Object?>.from(value);
    final status = _statusFrom(json['status']);
    final placedAt = DateTime.tryParse(json['placedAt'] as String? ?? '');
    if (status == null || placedAt == null) return null;

    final items = (json['items'] as List<Object?>? ?? const [])
        .map(_decodeItem)
        .whereType<PlacedOrderItem>()
        .toList(growable: false);
    final payment = _decodePayment(json['payment']);
    final feedback = _decodeFeedback(json['feedback']);
    return PlacedOrder(
      id: json['id'] as String? ?? '',
      status: status,
      placedAt: placedAt,
      deliveryAddress: json['deliveryAddress'] as String? ?? '',
      deliveryLatitude: (json['deliveryLatitude'] as num?)?.toDouble(),
      deliveryLongitude: (json['deliveryLongitude'] as num?)?.toDouble(),
      acceptanceExpiresAt: _date(json['acceptanceExpiresAt']),
      acceptanceExpiredAt: _date(json['acceptanceExpiredAt']),
      phoneNumber: json['phoneNumber'] as String? ?? '',
      items: items,
      isRated: json['isRated'] as bool? ?? feedback != null,
      feedback: feedback,
      payment: payment,
    );
  }

  static OrderPayment _decodePayment(Object? value) {
    if (value is! Map) return const OrderPayment.cashOnDelivery();
    final json = Map<String, Object?>.from(value);
    return OrderPayment(
      method: OrderPaymentMethodDetails.fromValue(json['method']),
      status: OrderPaymentStatusDetails.fromValue(json['status']),
      transactionReference: json['transactionReference'] as String? ?? '',
      refundReference: json['refundReference'] as String? ?? '',
    );
  }

  static OrderFeedback? _decodeFeedback(Object? value) {
    if (value is! Map) return null;
    final json = Map<String, Object?>.from(value);
    final submittedAt = DateTime.tryParse(json['submittedAt'] as String? ?? '');
    final feedback = OrderFeedback(
      rating: (json['rating'] as num?)?.toInt() ?? 0,
      comment: json['comment'] as String? ?? '',
      submittedAt: submittedAt ?? DateTime.fromMillisecondsSinceEpoch(0),
    );
    return feedback.isValid ? feedback : null;
  }

  static PlacedOrderItem? _decodeItem(Object? value) {
    if (value is! Map) return null;
    final json = Map<String, Object?>.from(value);
    return PlacedOrderItem(
      productId: json['productId'] as String? ?? '',
      productName: json['productName'] as String? ?? '',
      image: json['image'] as String? ?? '',
      sellerName: json['sellerName'] as String? ?? '',
      pricePerKg: (json['pricePerKg'] as num?)?.toDouble() ?? 0,
      unit: json['unit'] as String? ?? '',
      quantity: (json['quantity'] as num?)?.toInt() ?? 0,
    );
  }

  static PlacedOrderStatus? _statusFrom(Object? value) {
    for (final status in PlacedOrderStatus.values) {
      if (status.name == value) return status;
    }
    return null;
  }

  static DateTime? _date(Object? value) {
    final parsed = DateTime.tryParse(value?.toString() ?? '');
    return parsed?.toLocal();
  }
}
