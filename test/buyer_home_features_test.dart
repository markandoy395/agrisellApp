import 'package:agresell_app/core/theme/agrisellTheme.dart';
import 'package:agresell_app/features/buyer/home/presentation/screens/home_screen.dart';
import 'package:agresell_app/features/buyer/home/presentation/screens/product_detail_screen.dart';
import 'package:agresell_app/features/shared/products/data/home_product_repository.dart';
import 'package:agresell_app/features/shared/products/domain/home_product.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'support/home_product_fixture.dart';

void main() {
  testWidgets('buyer home starts empty until backend products arrive', (
    tester,
  ) async {
    await _pumpHome(tester);

    expect(find.text('0 products found'), findsOneWidget);
    expect(find.text('No products available'), findsOneWidget);
    expect(
      find.textContaining('No commodities have been posted yet'),
      findsOneWidget,
    );

    await tester.enterText(
      find.byKey(const ValueKey('home-product-search')),
      'Pumpkin',
    );
    await tester.pumpAndSettle();

    expect(find.text('0 products found'), findsOneWidget);
    expect(find.byTooltip('Add to basket'), findsNothing);
    expect(tester.takeException(), isNull);
  });

  testWidgets('product filters remain usable while backend data is empty', (
    tester,
  ) async {
    await _pumpHome(tester);

    await tester.tap(find.byKey(const ValueKey('home-product-filter-button')));
    await tester.pumpAndSettle();
    expect(find.text('Filter products'), findsOneWidget);

    await tester.tap(find.text('Accepting orders'));
    await tester.pump();
    await tester.tap(find.text('Show products'));
    await tester.pumpAndSettle();

    expect(find.text('0 products found'), findsOneWidget);
    expect(find.text('No products available'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('buyer home opens the selected product details', (tester) async {
    final product = testHomeProducts.first;
    await _pumpHome(
      tester,
      productRepository: _FakeHomeProductRepository([product]),
    );

    await tester.tap(find.text(product.name));
    await tester.pumpAndSettle();

    final details = tester.widget<ProductDetailScreen>(
      find.byType(ProductDetailScreen),
    );
    expect(details.product, same(product));
    expect(find.byKey(const ValueKey('product-details-panel')), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('buyer home retries a failed product query', (tester) async {
    final repository = _RetryingHomeProductRepository();
    await _pumpHome(tester, productRepository: repository);

    expect(find.text('Unable to load products'), findsOneWidget);
    expect(find.text('Try again'), findsOneWidget);

    await tester.tap(find.text('Try again'));
    await tester.pumpAndSettle();

    expect(find.text(testHomeProducts.first.name), findsOneWidget);
    expect(repository.attempts, 2);
    expect(tester.takeException(), isNull);
  });
}

Future<void> _pumpHome(
  WidgetTester tester, {
  HomeProductRepository productRepository = const HomeProductRepository(),
}) async {
  await tester.binding.setSurfaceSize(const Size(430, 932));
  addTearDown(() => tester.binding.setSurfaceSize(null));

  await tester.pumpWidget(
    MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: AgrisellTheme.light,
      home: HomeScreen(productRepository: productRepository),
    ),
  );
  await tester.pumpAndSettle();
}

class _FakeHomeProductRepository extends HomeProductRepository {
  const _FakeHomeProductRepository(this.products);

  final List<HomeProduct> products;

  @override
  Future<List<HomeProduct>> loadProducts() async => products;
}

class _RetryingHomeProductRepository extends HomeProductRepository {
  var attempts = 0;

  @override
  Future<List<HomeProduct>> loadProducts() async {
    attempts++;
    if (attempts == 1) throw Exception('temporary product failure');
    return [testHomeProducts.first];
  }
}
