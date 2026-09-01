import 'package:agresell_app/core/theme/agrisell_theme.dart';
import 'package:agresell_app/features/buyer/home/presentation/widgets/home/home_sale_products_section.dart';
import 'package:agresell_app/features/shared/products/domain/home_product.dart';
import 'package:agresell_app/features/shared/products/presentation/widgets/home_product_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('limits Buyer Home sale products to eight with View All', (
    tester,
  ) async {
    final products = List<HomeProduct>.generate(12, _saleProduct);
    var viewedAll = false;

    await tester.pumpWidget(
      MaterialApp(
        theme: AgrisellTheme.light,
        home: Scaffold(
          body: HomeSaleProductsSection(
            products: products,
            onViewAll: () => viewedAll = true,
            onProductTap: (_) {},
          ),
        ),
      ),
    );
    await tester.pump();

    final list = tester.widget<ListView>(
      find.byKey(const ValueKey('home-sale-products-list')),
    );
    // ListView.separated counts seven separators in addition to eight cards.
    expect(list.childrenDelegate.estimatedChildCount, 15);
    expect(find.byType(HomeProductCard), findsWidgets);
    await tester.tap(find.byKey(const ValueKey('home-sale-products-view-all')));
    expect(viewedAll, isTrue);
  });

  testWidgets('compact sale cards fit price and freshness metadata', (
    tester,
  ) async {
    tester.view.devicePixelRatio = 1;
    tester.view.physicalSize = const Size(360, 800);
    addTearDown(() {
      tester.view.resetDevicePixelRatio();
      tester.view.resetPhysicalSize();
    });

    await tester.pumpWidget(
      MaterialApp(
        theme: AgrisellTheme.light,
        home: Scaffold(
          body: HomeSaleProductsSection(
            products: [_saleProduct(1)],
            onViewAll: () {},
            onProductTap: (_) {},
          ),
        ),
      ),
    );
    await tester.pump();

    expect(
      tester.getSize(find.byType(HomeProductCard)).height,
      HomeProductCard.heightForWidth(360),
    );
    expect(tester.takeException(), isNull);
  });
}

HomeProduct _saleProduct(int index) => HomeProduct(
  id: 'sale-$index',
  name: 'Sale product $index',
  price: '\u20B1100',
  salePrice: '\u20B180',
  unit: 'per kg',
  image: 'assets/images/vege.jpeg',
  harvestDate: 'August 27, 2026',
  availableWeight: '10 kg',
  sellerName: 'Test Farm',
  sellerLocation: 'Lianga',
);
