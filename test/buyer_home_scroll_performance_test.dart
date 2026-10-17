import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:agresell_app/features/buyer/home/presentation/widgets/catalog/buyer_catalog_card.dart';
import 'package:agresell_app/features/buyer/home/presentation/widgets/catalog/buyer_catalog_grid.dart';
import 'package:agresell_app/features/buyer/home/presentation/widgets/home/home_catalog_pagination.dart';
import 'package:agresell_app/features/shared/products/domain/home_product.dart';
import 'support/home_product_fixture.dart';

void main() {
  testWidgets('large buyer catalog builds only nearby cards while scrolling', (
    tester,
  ) async {
    final sample = testHomeProducts.first;
    final products = List.generate(
      1000,
      (index) => HomeProduct(
        id: '$index',
        name: 'Product $index',
        price: sample.price,
        unit: sample.unit,
        image: sample.image,
        harvestDate: sample.harvestDate,
        availableWeight: sample.availableWeight,
        sellerName: sample.sellerName,
        sellerLocation: sample.sellerLocation,
      ),
    );
    final scroll = ScrollController();
    addTearDown(scroll.dispose);
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: CustomScrollView(
            controller: scroll,
            slivers: [
              BuyerCatalogGrid(products: products, onProductTap: (_) {}),
            ],
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.byType(BuyerCatalogCard).evaluate().length, lessThan(30));
    expect(find.byKey(const ValueKey('catalog-product-999')), findsNothing);

    scroll.jumpTo(scroll.position.maxScrollExtent);
    await tester.pumpAndSettle();
    expect(find.byKey(const ValueKey('catalog-product-999')), findsOneWidget);
    expect(find.byKey(const ValueKey('catalog-product-0')), findsNothing);
    expect(find.byType(BuyerCatalogCard).evaluate().length, lessThan(30));
    expect(tester.takeException(), isNull);
  });

  testWidgets(
    'pagination coalesces requests after layout and respects guards',
    (tester) async {
      var calls = 0;
      final scroll = ScrollController();
      addTearDown(scroll.dispose);
      Future<void> mount({bool enabled = true}) => tester.pumpWidget(
        MaterialApp(
          home: HomeCatalogPagination(
            enabled: enabled,
            onLoadMore: () => calls++,
            child: ListView.builder(
              controller: scroll,
              itemExtent: 100,
              itemCount: 100,
              itemBuilder: (_, index) => Text('Item $index'),
            ),
          ),
        ),
      );
      void nearEnd() => scroll.jumpTo(scroll.position.maxScrollExtent - 200);

      await mount();
      scroll.jumpTo(1000);
      await tester.pump();
      expect(calls, 0);
      nearEnd();
      scroll.jumpTo(scroll.position.pixels + 1);
      expect(calls, 0);
      await tester.pump();
      expect(calls, 1);

      await mount(enabled: false);
      scroll.jumpTo(scroll.position.pixels + 1);
      await tester.pump();
      expect(calls, 1);

      await mount();
      nearEnd();
      await tester.pumpWidget(const SizedBox());
      expect(calls, 1);
      expect(tester.takeException(), isNull);
    },
  );
}
