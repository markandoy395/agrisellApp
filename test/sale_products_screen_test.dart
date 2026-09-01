import 'package:agresell_app/core/theme/agrisell_theme.dart';
import 'package:agresell_app/features/buyer/home/presentation/screens/sale_products_screen.dart';
import 'package:agresell_app/features/shared/products/data/home_product_repository.dart';
import 'package:agresell_app/features/shared/products/domain/home_product.dart';
import 'package:agresell_app/features/shared/products/presentation/widgets/home_product_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('loads every eligible product for the selected campaign', (
    tester,
  ) async {
    final products = List<HomeProduct>.generate(20, _saleProduct);
    final repository = _CampaignProductRepository(products);

    await tester.pumpWidget(
      MaterialApp(
        theme: AgrisellTheme.light,
        home: SaleProductsScreen(
          title: 'Harvest campaign',
          campaignSaleId: 55,
          productRepository: repository,
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(repository.loadedSaleId, 55);
    expect(find.text('20 products on sale'), findsOneWidget);

    await tester.enterText(
      find.byKey(const ValueKey('sale-products-search')),
      'Product 19',
    );
    await tester.pump();

    expect(find.text('1 product on sale'), findsOneWidget);
    expect(
      find.descendant(
        of: find.byType(HomeProductCard),
        matching: find.text('Product 19'),
      ),
      findsWidgets,
    );
  });
}

class _CampaignProductRepository extends HomeProductRepository {
  _CampaignProductRepository(this.products);

  final List<HomeProduct> products;
  int? loadedSaleId;

  @override
  Future<List<HomeProduct>> loadSaleCampaignProducts({
    required int saleId,
  }) async {
    loadedSaleId = saleId;
    return products;
  }
}

HomeProduct _saleProduct(int index) => HomeProduct(
  id: 'campaign-product-$index',
  name: 'Product $index',
  price: '\u20B1100',
  salePrice: '\u20B175',
  unit: 'per kg',
  image: 'assets/images/vege.jpeg',
  harvestDate: 'August 27, 2026',
  availableWeight: '10 kg',
  sellerName: 'Campaign Farm',
  sellerLocation: 'Lianga',
);
