import 'package:flutter_test/flutter_test.dart';

import 'package:agresell_app/features/shared/products/domain/product_availability_date_rules.dart';
import 'package:agresell_app/features/shared/products/domain/product_production_stage.dart';
import 'package:agresell_app/features/shared/products/domain/product_sale_status.dart';

void main() {
  final utcNow = DateTime.utc(2026, 7, 27, 16, 30);

  test('uses the Asia/Manila calendar date', () {
    expect(
      ProductAvailabilityDateRules.philippineToday(utcNow: utcNow),
      DateTime(2026, 7, 28),
    );
  });

  test('ready harvested products do not require an expected date', () {
    final window = ProductAvailabilityDateRules.windowFor(
      productionStage: ProductProductionStage.harvested,
      sellingOption: ProductSaleStatus.readyNow,
      utcNow: utcNow,
    );

    expect(window.isRequired, isFalse);
    expect(window.validationMessage(null), isNull);
  });

  test('harvesting soon requires a date within 1 to 14 days', () {
    final window = ProductAvailabilityDateRules.windowFor(
      productionStage: ProductProductionStage.harvestingSoon,
      sellingOption: ProductSaleStatus.notAcceptingOrders,
      utcNow: utcNow,
    );

    expect(window.minimumDays, 1);
    expect(window.maximumDays, 14);
    expect(window.firstDate, DateTime(2026, 7, 29));
    expect(window.lastDate, DateTime(2026, 8, 11));
  });

  test('pre-order requires a date within 3 to 90 days', () {
    final window = ProductAvailabilityDateRules.windowFor(
      productionStage: ProductProductionStage.harvested,
      sellingOption: ProductSaleStatus.preOrder,
      utcNow: utcNow,
    );

    expect(window.minimumDays, 3);
    expect(window.maximumDays, 90);
  });

  test('harvesting-soon pre-order combines both ranges', () {
    final window = ProductAvailabilityDateRules.windowFor(
      productionStage: ProductProductionStage.harvestingSoon,
      sellingOption: ProductSaleStatus.preOrder,
      utcNow: utcNow,
    );

    expect(window.minimumDays, 3);
    expect(window.maximumDays, 14);
    expect(
      window.validationMessage(DateTime(2026, 7, 29)),
      'Expected availability must be 3\u201314 days from today.',
    );
    expect(window.validationMessage(DateTime(2026, 7, 31)), isNull);
  });
}
