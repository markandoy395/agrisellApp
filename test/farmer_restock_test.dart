import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:agresell_app/core/constants/agrisell_assets.dart';
import 'package:agresell_app/core/theme/agrisell_theme.dart';
import 'package:agresell_app/features/farmer/dashboard/presentation/screens/farmer_dashboard_screen.dart';
import 'package:agresell_app/features/farmer/products/data/farmer_commodity_repository.dart';
import 'package:agresell_app/features/farmer/products/domain/farmer_dashboard_product.dart';
import 'package:agresell_app/features/farmer/products/domain/farmer_restock.dart';
import 'package:agresell_app/features/shared/products/domain/product_inventory_lot.dart';

void main() {
  group('restock validation', () {
    test(
      'rejects empty, zero, negative, non-numeric, and excessive values',
      () {
        for (final entry in <String?>['', '0', '-1', 'abc', '1.2345']) {
          expect(
            FarmerRestockRules.validate(entry, currentStock: 0),
            isNotNull,
          );
        }
        expect(
          FarmerRestockRules.validate('1000001', currentStock: 0),
          isNotNull,
        );
        expect(
          FarmerRestockRules.validate('10', currentStock: 999995),
          isNotNull,
        );
      },
    );

    test('accepts positive quantities with up to three decimal places', () {
      expect(FarmerRestockRules.validate('20', currentStock: 0), isNull);
      expect(FarmerRestockRules.validate('0.125', currentStock: 10), isNull);
    });
  });

  test('multiple restocks add to existing stock', () async {
    final repository = _FakeRestockRepository([]);
    var product = _product(stock: 0);

    product = await repository.restock(product: product, quantity: 10);
    product = await repository.restock(product: product, quantity: 20);
    product = await repository.restock(product: product, quantity: 5);

    expect(product.availableQuantity, 35);
    expect(product.isOutOfStock, isFalse);
  });

  testWidgets('seller can restock an out-of-stock product from its card', (
    tester,
  ) async {
    final repository = _FakeRestockRepository([_product(stock: 0)]);
    await tester.binding.setSurfaceSize(const Size(430, 932));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    await tester.pumpWidget(
      MaterialApp(
        theme: AgrisellTheme.light,
        home: Scaffold(
          body: FarmerDashboardScreen(commodityRepository: repository),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('OUT OF STOCK'), findsOneWidget);
    await tester.tap(find.text('Restock'));
    await tester.pumpAndSettle();

    expect(find.text('Current stock'), findsOneWidget);
    expect(find.text('After restock'), findsOneWidget);
    await tester.enterText(
      find.byKey(const Key('restock-quantity-field')),
      '20',
    );
    await tester.pump();
    expect(find.text('20 kg'), findsOneWidget);

    await tester.tap(find.byKey(const Key('confirm-restock-button')));
    await tester.pumpAndSettle();

    expect(find.text('OUT OF STOCK'), findsNothing);
    expect(find.text('Stock: 20 kg'), findsOneWidget);
    expect(repository.restockCalls, 1);
  });
}

FarmerDashboardProduct _product({required double stock}) =>
    FarmerDashboardProduct(
      commodityId: 42,
      farmId: 7,
      name: 'Fertilizer',
      price: '₱50',
      unit: 'per kg',
      harvestDate: 'August 11, 2026',
      category: 'Farm supplies',
      imageAsset: AgrisellAssets.homeBannerVegetables,
      availableWeight: '${stock.toStringAsFixed(0)} kg',
      unitType: 'kg',
    );

class _FakeRestockRepository extends FarmerCommodityRepository {
  _FakeRestockRepository(this.seedProducts);

  final List<FarmerDashboardProduct> seedProducts;
  var _calls = 0;

  int get restockCalls => _calls;

  @override
  bool get isAvailable => true;

  @override
  Future<List<FarmerDashboardProduct>> loadProducts() async => seedProducts;

  @override
  Future<FarmerDashboardProduct> restock({
    required FarmerDashboardProduct product,
    required double quantity,
    ProductInventoryLotDraft? inventoryLot,
    String? reason,
  }) async {
    _calls++;
    final stock = product.availableQuantity + quantity;
    return product.copyWith(
      availableWeight: '${stock.toStringAsFixed(0)} ${product.unitType}',
    );
  }
}
