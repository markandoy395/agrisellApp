class OrderSnapshotMerger {
  const OrderSnapshotMerger._();

  static List<Map<String, Object?>> merge(
    Object? orders, {
    Object? payments,
    Object? reviews,
    Object? expirations,
    Object? cancellations,
    Object? refunds,
    Object? disputes,
  }) {
    final paymentByOrder = _byOrderId(payments);
    final reviewByOrder = _byOrderId(reviews);
    final expirationByOrder = _byOrderId(expirations);
    final cancellationByOrder = _byOrderId(cancellations);
    final refundByOrder = _byOrderId(refunds);
    final disputeByOrder = _byOrderId(disputes);
    if (orders is! List) return const [];

    return orders
        .whereType<Map>()
        .map((row) {
          final order = Map<String, Object?>.from(row);
          final id = order['id']?.toString() ?? '';
          final payment = paymentByOrder[id];
          final review = reviewByOrder[id];
          final expiration = expirationByOrder[id];
          final cancellation = cancellationByOrder[id];
          final refund = refundByOrder[id];
          final dispute = disputeByOrder[id];
          if (dispute != null) order['dispute'] = dispute;
          if (payment != null) order['payment'] = payment;
          if (refund != null) {
            final currentPayment = Map<String, Object?>.from(
              (order['payment'] as Map?) ?? const {},
            );
            if (refund['refundReference'] != null &&
                (refund['refundReference'] as String).isNotEmpty) {
              currentPayment['refundReference'] = refund['refundReference'];
            }
            if (refund['amount'] != null) {
              currentPayment['refundAmount'] = refund['amount'];
            }
            if (refund['completedAt'] != null) {
              currentPayment['refundedAt'] = refund['completedAt'];
            }
            if (refund['reason'] != null) {
              currentPayment['refundReason'] = refund['reason'];
            }
            if (refund['refundStatus'] != null) {
              currentPayment['refundStatus'] = refund['refundStatus'];
            }
            order['payment'] = currentPayment;
          }
          if (review != null) {
            final itemReviews = review['itemReviews'];
            if (itemReviews is List) {
              final byProduct = <String, Map<String, Object?>>{
                for (final row in itemReviews.whereType<Map>())
                  if (row['productId'] != null)
                    '${row['productId']}': Map<String, Object?>.from(row),
              };
              final items = order['items'];
              if (items is List) {
                order['items'] = items
                    .whereType<Map>()
                    .map((row) {
                      final item = Map<String, Object?>.from(row);
                      final feedback = byProduct['${item['productId']}'];
                      if (feedback != null) item['feedback'] = feedback;
                      return item;
                    })
                    .toList(growable: false);
                order['isRated'] = byProduct.length == items.length;
              }
              order['deliveryId'] = review['deliveryId'];
              order['riderRated'] = review['riderRated'] == true;
            } else {
              order['feedback'] = review;
              order['isRated'] = true;
            }
          }
          if (expiration != null) {
            order.addAll(expiration);
            if (expiration['acceptanceExpiredAt'] != null) {
              order['status'] = 'cancelled';
            }
          }
          if (cancellation != null) order.addAll(cancellation);
          return order;
        })
        .toList(growable: false);
  }

  static Map<String, Map<String, Object?>> _byOrderId(Object? value) {
    if (value is! List) return const {};
    final result = <String, Map<String, Object?>>{};
    for (final row in value.whereType<Map>()) {
      final snapshot = Map<String, Object?>.from(row);
      final id = snapshot.remove('orderId')?.toString() ?? '';
      if (id.isNotEmpty) result[id] = snapshot;
    }
    return result;
  }
}
