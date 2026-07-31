import 'package:flutter_test/flutter_test.dart';

import 'package:agresell_app/features/farmer/products/domain/farmer_dashboard_product.dart';
import 'package:agresell_app/features/farmer/products/domain/product_edit_options.dart';
import 'package:agresell_app/features/shared/products/domain/product_production_stage.dart';
import 'package:agresell_app/features/shared/products/domain/product_sale_status.dart';

void main() {
  test('editing a product preserves its database identity', () {
    const original = FarmerDashboardProduct(
      commodityId: 42,
      farmId: 8,
      name: 'Tomato',
      price: '\u20B150',
      unit: 'per kg',
      harvestDate: 'July 28, 2026',
      category: 'Vegetables',
      imageAsset: 'assets/images/vege.jpeg',
      availableWeight: '20 kg',
    );

    final edited = ProductEditOptions.editedProduct(
      baseProduct: original,
      name: 'Fresh Tomato',
      price: '55',
      weight: '18',
      day: '28',
      month: 'July',
      year: '2026',
      category: 'Vegetables',
      imageAsset: original.imageAsset,
      imageBytes: null,
      imageUrl: null,
      isSold: false,
      saleStatus: ProductSaleStatus.readyNow,
      productionStage: ProductProductionStage.harvested,
    );

    expect(edited.commodityId, 42);
    expect(edited.farmId, 8);
    expect(edited.name, 'Fresh Tomato');
  });
}
