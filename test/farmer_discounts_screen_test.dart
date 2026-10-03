import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:agresell_app/core/theme/agrisell_theme.dart';
import 'package:agresell_app/features/farmer/discounts/data/farmer_discount_repository.dart';
import 'package:agresell_app/features/farmer/discounts/domain/farmer_discount.dart';
import 'package:agresell_app/features/farmer/discounts/presentation/controllers/farmer_discounts_controller.dart';
import 'package:agresell_app/features/farmer/discounts/presentation/screens/farmer_discounts_screen.dart';
import 'package:agresell_app/features/farmer/products/data/farmer_commodity_repository.dart';
import 'package:agresell_app/features/farmer/products/domain/farmer_dashboard_product.dart';

void main() {
  testWidgets(
    'load failure retries and the empty state can create a promotion',
    (tester) async {
      final repository = _DiscountRepository()..failLoad = true;
      await _pumpScreen(tester, repository);
      expect(find.text('Unable to load promotions.'), findsOneWidget);
      repository.failLoad = false;
      await tester.tap(find.text('Try Again'));
      await tester.pumpAndSettle();
      expect(find.text('No promotions created yet'), findsOneWidget);
      expect(repository.loads, 2);
      await tester.tap(find.text('Create First Promotion'));
      await tester.pumpAndSettle();
      expect(find.text('Create Promotion / Discount'), findsOneWidget);
      await tester.enterText(find.byType(TextField).at(0), 'Harvest');
      await tester.enterText(find.byType(TextField).at(1), '15');
      await tester.ensureVisible(find.text('Select All'));
      await tester.tap(find.text('Select All'));
      await tester.ensureVisible(find.text('Save & Apply Discount'));
      await tester.tap(find.text('Save & Apply Discount'));
      await tester.pumpAndSettle();
      expect(find.text('Promotion "Harvest" created.'), findsOneWidget);
      expect(repository.saved?.commodityIds, [201]);
      expect(repository.loads, 3);
      expect(find.text('Harvest'), findsOneWidget);
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets('edit saves the existing promotion and refreshes the list', (
    tester,
  ) async {
    final repository = _DiscountRepository()..discounts = [_discount];
    await _pumpScreen(tester, repository);
    await tester.tap(find.text('Edit'));
    await tester.pumpAndSettle();
    expect(find.text('Edit Promotion'), findsOneWidget);
    expect(
      tester.widget<TextField>(find.byType(TextField).first).controller!.text,
      'Harvest',
    );
    await tester.enterText(find.byType(TextField).at(0), 'Updated Harvest');
    await tester.ensureVisible(find.text('Update Promotion'));
    await tester.tap(find.text('Update Promotion'));
    await tester.pumpAndSettle();
    expect(repository.saved?.saleId, 501);
    expect(find.text('Updated Harvest'), findsOneWidget);
    expect(find.text('Promotion "Updated Harvest" updated.'), findsOneWidget);
    expect(repository.loads, 2);
  });

  testWidgets(
    'status toggle preserves promotion details and reports failures',
    (tester) async {
      final repository = _DiscountRepository()..discounts = [_discount];
      await _pumpScreen(tester, repository);
      repository.failUpdate = true;
      await tester.tap(find.byType(Switch));
      await tester.pumpAndSettle();
      expect(find.text('Unable to update status.'), findsOneWidget);
      expect(tester.widget<Switch>(find.byType(Switch)).value, isTrue);
      repository.failUpdate = false;
      await tester.tap(find.byType(Switch));
      await tester.pumpAndSettle();
      expect(repository.saved?.isEnabled, isFalse);
      expect(repository.saved?.name, _discount.name);
      expect(repository.saved?.promoCode, _discount.promoCode);
      expect(repository.saved?.commodityIds, _discount.commodityIds);
      expect(repository.saved?.startsAt, _discount.startsAt);
      expect(repository.saved?.endsAt, _discount.endsAt);
      expect(find.text('DISABLED'), findsOneWidget);
      expect(repository.loads, 2);
    },
  );

  testWidgets('delete supports cancel, failure, and successful refresh', (
    tester,
  ) async {
    final repository = _DiscountRepository()..discounts = [_discount];
    await _pumpScreen(tester, repository);
    await tester.tap(find.text('Delete'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Cancel'));
    await tester.pumpAndSettle();
    expect(repository.deletes, 0);
    repository.failDelete = true;
    await tester.tap(find.text('Delete'));
    await tester.pumpAndSettle();
    await tester.tap(find.widgetWithText(ElevatedButton, 'Delete'));
    await tester.pumpAndSettle();
    expect(
      find.text('Unable to delete promotion. Please try again.'),
      findsOneWidget,
    );
    expect(find.text('Harvest'), findsOneWidget);
    repository.failDelete = false;
    await tester.tap(find.text('Delete'));
    await tester.pumpAndSettle();
    await tester.tap(find.widgetWithText(ElevatedButton, 'Delete'));
    await tester.pumpAndSettle();
    expect(repository.deletes, 2);
    expect(find.text('Promotion "Harvest" deleted.'), findsOneWidget);
    expect(find.text('No promotions created yet'), findsOneWidget);
    expect(repository.loads, 2);
  });

  testWidgets(
    'refresh reloads promotions and disposal tolerates pending loads',
    (tester) async {
      final repository = _DiscountRepository();
      await _pumpScreen(tester, repository);
      await tester.drag(find.byType(CustomScrollView), const Offset(0, 400));
      await tester.pumpAndSettle();
      expect(repository.loads, 2);
      final pending = Completer<List<FarmerDiscount>>();
      final controller = FarmerDiscountsController(
        farmId: 10,
        discountRepository: FarmerDiscountRepository(
          customDiscountsLoader: (_) => pending.future,
        ),
        commodityRepository: _CommodityRepository(),
      );
      final loading = controller.load();
      controller.dispose();
      pending.complete([_discount]);
      await loading;
      expect(tester.takeException(), isNull);
    },
  );
}

final _discount = FarmerDiscount(
  saleId: 501,
  farmId: 10,
  name: 'Harvest',
  discountType: 'percentage',
  discountValue: 10,
  promoCode: 'HARVEST10',
  startsAt: DateTime(2020),
  endsAt: DateTime(2099),
  commodityIds: const [201],
);

class _CommodityRepository extends FarmerCommodityRepository {
  @override
  Future<List<FarmerDashboardProduct>> loadProducts() async => const [
    FarmerDashboardProduct(
      commodityId: 201,
      farmId: 10,
      name: 'Onions',
      price: '120',
      unit: 'per kg',
      harvestDate: '2026-09-20',
      category: 'Vegetables',
      imageAsset: 'assets/images/vege.jpeg',
    ),
  ];
}

class _DiscountRepository extends FarmerDiscountRepository {
  List<FarmerDiscount> discounts = [];
  FarmerDiscount? saved;
  var loads = 0;
  var deletes = 0;
  var failLoad = false;
  var failUpdate = false;
  var failDelete = false;

  @override
  Future<List<FarmerDiscount>> loadDiscounts(int farmId) async {
    expect(farmId, 10);
    loads++;
    if (failLoad) throw StateError('Load failed');
    return discounts;
  }

  @override
  Future<int> createDiscount({
    required int farmId,
    required String name,
    required String discountType,
    required double discountValue,
    DateTime? startsAt,
    DateTime? endsAt,
    String? promoCode,
    List<int> commodityIds = const [],
  }) async {
    await updateDiscount(
      saleId: 501,
      farmId: farmId,
      name: name,
      discountType: discountType,
      discountValue: discountValue,
      startsAt: startsAt,
      endsAt: endsAt,
      promoCode: promoCode,
      commodityIds: commodityIds,
    );
    return 501;
  }

  @override
  Future<void> updateDiscount({
    required int saleId,
    required int farmId,
    required String name,
    required String discountType,
    required double discountValue,
    DateTime? startsAt,
    DateTime? endsAt,
    String? promoCode,
    bool isEnabled = true,
    List<int> commodityIds = const [],
  }) async {
    if (failUpdate) throw StateError('Update failed');
    saved = FarmerDiscount(
      saleId: saleId,
      farmId: farmId,
      name: name,
      discountType: discountType,
      discountValue: discountValue,
      startsAt: startsAt,
      endsAt: endsAt,
      promoCode: promoCode,
      isEnabled: isEnabled,
      commodityIds: commodityIds,
    );
    discounts = [saved!];
  }

  @override
  Future<void> deleteDiscount(int saleId, int farmId) async {
    expect(saleId, 501);
    expect(farmId, 10);
    deletes++;
    if (failDelete) throw StateError('Delete failed');
    discounts = [];
  }
}

Future<void> _pumpScreen(
  WidgetTester tester,
  _DiscountRepository repository,
) async {
  await tester.binding.setSurfaceSize(const Size(600, 1000));
  addTearDown(() => tester.binding.setSurfaceSize(null));
  await tester.pumpWidget(
    MaterialApp(
      theme: AgrisellTheme.light,
      home: FarmerDiscountsScreen(
        farmId: 10,
        discountRepository: repository,
        commodityRepository: _CommodityRepository(),
      ),
    ),
  );
  await tester.pumpAndSettle();
}
