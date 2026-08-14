import 'package:agresell_app/features/shared/products/data/home_product_repository.dart';
import 'package:agresell_app/features/shared/products/domain/product_sale_status.dart';
import 'package:agresell_app/features/shared/products/domain/product_production_stage.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('maps a commodity row into a buyer-home product', () {
    final product = HomeProductRepository.productFromRow(
      {
        'commodity_id': 24,
        'commodity_name': 'Fresh tomatoes',
        'description': 'Vine-ripened tomatoes picked this morning.',
        'price_per_unit': 48.5,
        'unit_type': 'kg',
        'image_url': 'https://example.com/tomatoes.jpg',
        'harvest_date': '2026-07-22',
        'available_quantity': 18,
        'commodity_status': 'available',
        'categories': {'category_name': 'Vegetables'},
      },
      farm: {'farmer_name': 'Maria Santos', 'farm_location': 'Bukidnon'},
    );

    expect(product.id, '24');
    expect(product.price, '\u20B148.50');
    expect(product.unit, 'per kg');
    expect(product.imageUrl, 'https://example.com/tomatoes.jpg');
    expect(product.harvestDate, 'July 22, 2026');
    expect(product.category, 'Vegetables');
    expect(product.sellerName, 'Maria Santos');
    expect(product.description, 'Vine-ripened tomatoes picked this morning.');
    expect(product.isAvailable, isTrue);
    expect(product.saleStatus, ProductSaleStatus.readyNow);
    expect(product.isSold, isFalse);
  });

  test('marks sold or empty commodities unavailable', () {
    final product = HomeProductRepository.productFromRow({
      'commodity_id': 25,
      'commodity_name': 'Sold squash',
      'price_per_unit': 40,
      'available_quantity': 0,
      'commodity_status': 'sold',
    });

    expect(product.isAvailable, isFalse);
    expect(product.imageUrl, isNull);
  });

  test(
    'does not expose a non-active commodity even when stock is positive',
    () {
      final product = HomeProductRepository.productFromRow({
        'commodity_id': 27,
        'commodity_name': 'Archived squash',
        'price_per_unit': 40,
        'available_quantity': 12,
        'commodity_status': 'out_of_stock',
      });

      expect(product.isAvailable, isFalse);
      expect(product.canOrder, isFalse);
    },
  );

  test('maps a pre-order commodity with a harvest countdown', () {
    final harvestDate = DateTime.now().add(const Duration(days: 9));
    final product = HomeProductRepository.productFromRow({
      'commodity_id': 26,
      'commodity_name': 'Growing carrots',
      'price_per_unit': 55,
      'available_quantity': 25,
      'harvest_date': harvestDate.toIso8601String().substring(0, 10),
      'commodity_status': 'available',
      'availability_status': 'pre_order',
      'production_status': 'growing',
    });

    expect(product.saleStatus, ProductSaleStatus.preOrder);
    expect(product.productionStage, ProductProductionStage.growing);
    expect(product.buyerStatusLabel, 'Pre-order');
    expect(product.harvestCountdown, 'Harvest in 9 days');
  });

  test('defaults a missing sale status to ready for delivery', () {
    expect(productSaleStatusFromDatabase(null), ProductSaleStatus.readyNow);
  });
}
