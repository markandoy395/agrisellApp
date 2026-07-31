class OrderSnapshotMerger {
  const OrderSnapshotMerger._();

  static List<Map<String, Object?>> merge(
    Object? orders, {
    Object? payments,
    Object? reviews,
    Object? expirations,
  }) {
    final paymentByOrder = _byOrderId(payments);
    final reviewByOrder = _byOrderId(reviews);
    final expirationByOrder = _byOrderId(expirations);
    if (orders is! List) return const [];

    return orders
        .whereType<Map>()
        .map((row) {
          final order = Map<String, Object?>.from(row);
          final id = order['id']?.toString() ?? '';
          final payment = paymentByOrder[id];
          final review = reviewByOrder[id];
          final expiration = expirationByOrder[id];
          if (payment != null) order['payment'] = payment;
          if (review != null) {
            order['feedback'] = review;
            order['isRated'] = true;
          }
          if (expiration != null) {
            order.addAll(expiration);
            if (expiration['acceptanceExpiredAt'] != null) {
              order['status'] = 'cancelled';
            }
          }
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
