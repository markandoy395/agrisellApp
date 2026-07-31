import 'package:agresell_app/features/buyer/home/data/farmer_shop_products.dart';
import 'package:agresell_app/features/shared/products/domain/home_product.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('database product can open its farm shop by farm ID', () {
    const product = HomeProduct(
      id: '24',
      name: 'Tomatoes',
      price: '₱60/kg',
      unit: 'kg',
      image: 'assets/images/vege.jpeg',
      harvestDate: 'Today',
      availableWeight: '10 kg',
      sellerName: 'Maria Santos',
      sellerLocation: 'Bukidnon',
      farmId: 24,
      rating: 4.8,
    );

    final farmer = farmerForProduct(product);

    expect(farmer, isNotNull);
    expect(farmer!.farmId, 24);
    expect(farmer.name, 'Maria Santos');
  });
}
