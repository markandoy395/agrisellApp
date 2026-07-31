enum ProductSaleStatus { readyNow, preOrder, notAcceptingOrders }

extension ProductSaleStatusValue on ProductSaleStatus {
  String get databaseValue => switch (this) {
    ProductSaleStatus.readyNow => 'ready_now',
    ProductSaleStatus.preOrder => 'pre_order',
    ProductSaleStatus.notAcceptingOrders => 'not_accepting_orders',
  };

  String get farmerLabel => switch (this) {
    ProductSaleStatus.readyNow => 'Ready for delivery',
    ProductSaleStatus.preOrder => 'Pre-order',
    ProductSaleStatus.notAcceptingOrders => 'Not accepting orders',
  };

  String get buyerLabel => switch (this) {
    ProductSaleStatus.readyNow => 'Ready for delivery',
    ProductSaleStatus.preOrder => 'Pre-order',
    ProductSaleStatus.notAcceptingOrders => 'Not accepting orders',
  };
}

ProductSaleStatus productSaleStatusFromDatabase(Object? value) {
  final normalizedValue = value?.toString().trim().toLowerCase() ?? '';
  return switch (normalizedValue) {
    'pre_order' || 'pre-order' || 'growing' => ProductSaleStatus.preOrder,
    'not_accepting_orders' ||
    'harvesting_soon' ||
    'harvesting soon' ||
    'ready for harvest' => ProductSaleStatus.notAcceptingOrders,
    _ => ProductSaleStatus.readyNow,
  };
}
