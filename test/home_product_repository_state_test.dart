import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:agresell_app/features/buyer/cart/presentation/widgets/basket/basket_suggestions.dart';
import 'package:agresell_app/features/buyer/home/presentation/screens/product_detail_screen.dart';
import 'package:agresell_app/features/shared/products/data/home_product_repository.dart';
import 'package:agresell_app/features/shared/products/domain/home_product.dart';
import 'package:agresell_app/features/shared/products/presentation/controllers/home_product_catalog_controller.dart';
import 'support/home_product_fixture.dart';

void main() {
  test(
    'product catalog exposes loading, loaded, empty, error, and retry',
    () async {
      final pending = Completer<List<HomeProduct>>();
      final repository = _ScriptedProductRepository([
        () => pending.future,
        () async => const [],
        () async => throw Exception('catalog offline'),
        () async => [testHomeProducts.first],
      ]);
      final controller = HomeProductCatalogController(repository: repository);
      addTearDown(controller.dispose);

      final firstLoad = controller.load();
      expect(controller.status, HomeProductCatalogStatus.loading);
      pending.complete([testHomeProducts.first]);
      await firstLoad;
      expect(controller.status, HomeProductCatalogStatus.ready);
      expect(controller.products, [same(testHomeProducts.first)]);

      await controller.load();
      expect(controller.status, HomeProductCatalogStatus.ready);
      expect(controller.products, isEmpty);

      await controller.load();
      expect(controller.status, HomeProductCatalogStatus.error);
      expect(controller.error.toString(), contains('catalog offline'));
      expect(controller.products, isEmpty);

      await controller.load();
      expect(controller.status, HomeProductCatalogStatus.ready);
      expect(controller.products.single, same(testHomeProducts.first));
    },
  );

  testWidgets('basket suggestions retry after a repository failure', (
    tester,
  ) async {
    final repository = _ScriptedProductRepository([
      () async => throw Exception('network unavailable'),
      () async => [testHomeProducts.first],
    ]);

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: SingleChildScrollView(
            child: BasketSuggestions(
              excludedProductIds: const {},
              productRepository: repository,
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Product suggestions are unavailable'), findsOneWidget);
    await tester.tap(find.text('Try again'));
    await tester.pumpAndSettle();

    expect(find.text(testHomeProducts.first.name), findsOneWidget);
    expect(repository.attempts, 2);
  });

  testWidgets('product details show empty recommendations without fake data', (
    tester,
  ) async {
    await _pumpProductDetails(
      tester,
      _ScriptedProductRepository([() async => const []]),
    );

    expect(find.text('No other products available'), findsOneWidget);
    expect(find.text('Recommended for you'), findsNothing);
  });

  testWidgets('product recommendation failure can retry to loaded state', (
    tester,
  ) async {
    final repository = _ScriptedProductRepository([
      () async => throw Exception('query failed'),
      () async => testHomeProducts.take(2).toList(growable: false),
    ]);
    await _pumpProductDetails(tester, repository);

    expect(find.text('Recommendations unavailable'), findsOneWidget);
    await tester.tap(find.text('Try again'));
    await tester.pumpAndSettle();

    expect(find.text('Recommended for you'), findsOneWidget);
    expect(find.text(testHomeProducts[1].name), findsOneWidget);
    expect(repository.attempts, 2);
  });
}

Future<void> _pumpProductDetails(
  WidgetTester tester,
  HomeProductRepository repository,
) async {
  await tester.binding.setSurfaceSize(const Size(430, 932));
  addTearDown(() => tester.binding.setSurfaceSize(null));
  await tester.pumpWidget(
    MaterialApp(
      home: ProductDetailScreen(
        product: testHomeProducts.first,
        productRepository: repository,
      ),
    ),
  );
  await tester.pumpAndSettle();
  await tester.drag(find.byType(CustomScrollView), const Offset(0, -700));
  await tester.pumpAndSettle();
}

class _ScriptedProductRepository extends HomeProductRepository {
  _ScriptedProductRepository(this._steps);

  final List<Future<List<HomeProduct>> Function()> _steps;
  var attempts = 0;

  @override
  Future<List<HomeProduct>> loadProducts() {
    final index = attempts.clamp(0, _steps.length - 1);
    attempts++;
    return _steps[index]();
  }
}
