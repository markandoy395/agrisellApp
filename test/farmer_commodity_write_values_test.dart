import 'package:flutter_test/flutter_test.dart';

import 'package:agresell_app/features/farmer/products/data/farmer_commodity_write_values.dart';

void main() {
  test('product updates omit ownership and inventory-managed values', () {
    final source = <String, Object?>{
      'farm_id': 7,
      'category_id': 12,
      'commodity_name': 'Tomato',
      'available_quantity': 50,
      'inventory_date_type': 'fresh_produce',
      'image_url': 'https://example.com/tomato.jpg',
    };

    final update = FarmerCommodityWriteValues.forUpdate(source);

    expect(update, {
      'category_id': 12,
      'commodity_name': 'Tomato',
      'image_url': 'https://example.com/tomato.jpg',
    });
    expect(source['farm_id'], 7);
    expect(source['available_quantity'], 50);
    expect(source['inventory_date_type'], 'fresh_produce');
  });
}
