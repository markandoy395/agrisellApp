import 'package:flutter_test/flutter_test.dart';

import 'package:agresell_app/features/shared/products/domain/home_product.dart';
import 'package:agresell_app/features/shared/products/domain/product_inventory_lot.dart';

void main() {
  final today = DateTime(2026, 8, 28);

  test('fresh produce requires a non-expired final selling date', () {
    final missingDate = ProductInventoryLotDraft(
      dateType: ProductInventoryDateType.freshProduce,
      harvestedAt: today,
    );
    expect(missingDate.validationErrors(today: today), contains('sellUntil'));

    final valid = ProductInventoryLotDraft(
      dateType: ProductInventoryDateType.freshProduce,
      harvestedAt: today,
      sellUntil: today.add(const Duration(days: 3)),
    );
    expect(valid.validationErrors(today: today), isEmpty);
  });

  test('packaged food requires its printed expiration and lot code', () {
    final missingCode = ProductInventoryLotDraft(
      dateType: ProductInventoryDateType.packagedFood,
      harvestedAt: today,
      expiresAt: today.add(const Duration(days: 30)),
    );
    expect(missingCode.validationErrors(today: today), contains('lotCode'));

    final valid = ProductInventoryLotDraft(
      dateType: ProductInventoryDateType.packagedFood,
      harvestedAt: today,
      expiresAt: today.add(const Duration(days: 30)),
      lotCode: 'LOT-2026-08',
    );
    expect(valid.validationErrors(today: today), isEmpty);
  });

  test('non-perishable inventory does not require an expiration date', () {
    const lot = ProductInventoryLotDraft(
      dateType: ProductInventoryDateType.nonPerishable,
    );
    expect(lot.validationErrors(today: today), isEmpty);
  });

  test('buyer freshness label uses the correct date meaning', () {
    final fresh = _product(
      dateType: ProductInventoryDateType.freshProduce,
      sellUntil: DateTime(2026, 8, 31),
    );
    final packaged = _product(
      dateType: ProductInventoryDateType.packagedFood,
      expiresAt: DateTime(2026, 9, 30),
    );

    expect(fresh.freshnessLabel, 'Sell until Aug 31, 2026');
    expect(packaged.freshnessLabel, 'Expires Sep 30, 2026');
  });
}

HomeProduct _product({
  required ProductInventoryDateType dateType,
  DateTime? sellUntil,
  DateTime? expiresAt,
}) => HomeProduct(
  id: 'product-1',
  name: 'Tomatoes',
  price: 'P50',
  unit: 'per kg',
  image: 'image.png',
  harvestDate: 'August 28, 2026',
  availableWeight: '10 kg',
  sellerName: 'Farmer',
  sellerLocation: 'Bukidnon',
  inventoryDateType: dateType,
  sellUntil: sellUntil,
  expiresAt: expiresAt,
);
