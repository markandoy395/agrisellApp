import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:agresell_app/features/buyer/cart/presentation/widgets/basket/basket_suggestions.dart';
import 'package:agresell_app/features/shared/products/data/home_product_repository.dart';
import 'package:agresell_app/features/shared/products/domain/home_product.dart';
import 'package:agresell_app/features/shared/products/presentation/controllers/home_product_catalog_controller.dart';
import 'package:agresell_app/features/shared/products/presentation/widgets/product_thumbnail.dart';
import 'support/home_product_fixture.dart';

void main() {
  testWidgets('basket suggestions use uploaded images and product details', (
    tester,
  ) async {
    const uploadedImageUrl = 'https://example.com/uploaded-pumpkin.jpg';
    final product = _copyWithImageUrl(testHomeProducts.first, uploadedImageUrl);
    final controller = HomeProductCatalogController(
      repository: _ProductRepository([product]),
    );
    addTearDown(controller.dispose);
    await controller.load();

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: BasketSuggestions(
            excludedProductIds: const {},
            catalogController: controller,
          ),
        ),
      ),
    );

    expect(find.text('You may also like'), findsOneWidget);
    expect(find.text('Check other products'), findsNothing);
    expect(find.text(product.name), findsOneWidget);
    expect(find.text(product.sellerName), findsOneWidget);
    expect(find.text('${product.price} ${product.unit}'), findsOneWidget);

    final thumbnail = tester.widget<ProductThumbnail>(
      find.byType(ProductThumbnail),
    );
    expect(thumbnail.imageUrl, uploadedImageUrl);
    expect(thumbnail.asset, product.image);
  });
}

HomeProduct _copyWithImageUrl(HomeProduct source, String imageUrl) =>
    HomeProduct(
      id: source.id,
      name: source.name,
      price: source.price,
      unit: source.unit,
      image: source.image,
      imageUrl: imageUrl,
      harvestDate: source.harvestDate,
      availableWeight: source.availableWeight,
      sellerName: source.sellerName,
      sellerLocation: source.sellerLocation,
      category: source.category,
      isAvailable: source.isAvailable,
    );

class _ProductRepository extends HomeProductRepository {
  const _ProductRepository(this.products);

  final List<HomeProduct> products;

  @override
  Future<List<HomeProduct>> loadProducts() async => products;
}
