import 'package:flutter_test/flutter_test.dart';
import 'package:agresell_app/features/farmer/products/data/farmer_commodity_mapper.dart';
import 'package:agresell_app/features/farmer/products/data/farmer_commodity_format.dart';

void main() {
  const row = <String, dynamic>{
    'commodity_id': 17,
    'category_id': 3,
    'commodity_name': 'Tomato',
    'price_per_unit': 50,
    'available_quantity': 12,
  };

  test('products without sale metadata load without inventing a sale ID', () {
    for (final data in [
      row,
      {...row, 'active_sale_id': null},
    ]) {
      final product = FarmerCommodityMapper.productFromRow(data, {
        3: 'Vegetables',
      }, 7);
      expect(product.commodityId, 17);
      expect(product.category, 'Vegetables');
      expect(product.activeSaleId, isNull);
      expect(product.isInActiveSale, false);
    }
  });

  test('active sales retain both numeric and serialized IDs', () {
    for (final id in [501, '501']) {
      final product = FarmerCommodityMapper.productFromRow(
        {...row, 'active_sale_id': id, 'active_sale_name': 'Harvest sale'},
        {3: 'Vegetables'},
        7,
      );
      expect(product.activeSaleId, 501);
      expect(product.isInActiveSale, true);
    }
  });

  test('uncategorized products tolerate a missing category', () {
    final product = FarmerCommodityMapper.productFromRow(
      {...row, 'category_id': null},
      {3: 'Vegetables'},
      7,
    );
    expect(product.category, 'Uncategorized');
  });

  test('optional integers reject invalid IDs; required IDs stay strict', () {
    for (final value in [null, '', 'null', 'invalid', '1.5']) {
      expect(FarmerCommodityFormat.optionalInteger(value), isNull);
    }
    expect(() => FarmerCommodityFormat.integer(null), throwsFormatException);
    expect(FarmerCommodityFormat.optionalInteger(' 12 '), 12);
  });
}
