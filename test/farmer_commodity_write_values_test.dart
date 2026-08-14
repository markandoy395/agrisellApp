import 'package:flutter_test/flutter_test.dart';

import 'package:agresell_app/features/farmer/products/data/farmer_commodity_write_values.dart';

void main() {
  test('product updates omit immutable farm ownership', () {
    final source = <String, Object?>{
      'farm_id': 7,
      'category_id': 12,
      'commodity_name': 'Tomato',
      'available_quantity': 50,
    };

    final update = FarmerCommodityWriteValues.forUpdate(source);

    expect(update, {'category_id': 12, 'commodity_name': 'Tomato'});
    expect(source['farm_id'], 7);
    expect(source['available_quantity'], 50);
  });
}
