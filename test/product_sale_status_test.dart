import 'package:agresell_app/features/shared/products/domain/product_sale_status.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Product sale status compatibility', () {
    test('every database value round-trips without changing availability', () {
      for (final status in ProductSaleStatus.values) {
        expect(productSaleStatusFromDatabase(status.databaseValue), status);
      }
    });

    for (final value in ['pre_order', 'pre-order', 'growing', ' PRE_ORDER ']) {
      test('recognizes pre-order value "$value"', () {
        expect(
          productSaleStatusFromDatabase(value),
          ProductSaleStatus.preOrder,
        );
      });
    }

    for (final value in [
      'not_accepting_orders',
      'harvesting_soon',
      'harvesting soon',
      'ready for harvest',
      ' NOT_ACCEPTING_ORDERS ',
    ]) {
      test('keeps unavailable legacy value "$value" unavailable', () {
        expect(
          productSaleStatusFromDatabase(value),
          ProductSaleStatus.notAcceptingOrders,
        );
      });
    }

    test('missing and unrecognized values retain the ready-now fallback', () {
      for (final value in [null, '', 'unknown', 42]) {
        expect(
          productSaleStatusFromDatabase(value),
          ProductSaleStatus.readyNow,
        );
      }
    });
  });
}
