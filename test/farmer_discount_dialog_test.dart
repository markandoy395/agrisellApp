import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:agresell_app/core/theme/agrisell_theme.dart';
import 'package:agresell_app/features/farmer/discounts/data/farmer_discount_repository.dart';
import 'package:agresell_app/features/farmer/discounts/domain/farmer_discount.dart';
import 'package:agresell_app/features/farmer/discounts/presentation/controllers/farmer_discount_form_controller.dart';
import 'package:agresell_app/features/farmer/discounts/presentation/widgets/farmer_discount_dialog.dart';
import 'package:agresell_app/features/farmer/products/domain/farmer_dashboard_product.dart';

const product = FarmerDashboardProduct(
  commodityId: 201,
  farmId: 10,
  name: 'Red Onions',
  price: '\u20b1120.00',
  unit: 'per kg',
  harvestDate: '2026-09-20',
  category: 'Vegetables',
  imageAsset: 'assets/images/vege.jpeg',
);

class RecordingDiscountRepository extends FarmerDiscountRepository {
  FarmerDiscount? saved;
  bool fail = false;
  Completer<void>? pending;

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
    if (fail) throw StateError('Save failed');
    if (pending != null) await pending!.future;
    saved = FarmerDiscount(
      saleId: saleId,
      farmId: farmId,
      name: name,
      discountType: discountType,
      discountValue: discountValue,
      startsAt: startsAt,
      endsAt: endsAt,
      promoCode: promoCode,
      commodityIds: commodityIds,
    );
  }
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  setUpAll(() async {
    final fonts = FontLoader(AgrisellTheme.fontFamily);
    for (final weight in ['Regular', 'SemiBold', 'Bold', 'ExtraBold']) {
      fonts.addFont(
        rootBundle.load('assets/fonts/Poppins/Poppins-$weight.ttf'),
      );
    }
    await fonts.load();
  });

  late RecordingDiscountRepository repository;
  late FarmerDiscountFormController form;

  setUp(() {
    repository = RecordingDiscountRepository();
    form = FarmerDiscountFormController(
      farmId: 10,
      repository: repository,
      initialProduct: product,
    );
  });
  tearDown(() => form.dispose());

  test('preserves preview calculations and all-product selection', () {
    expect(form.products, [product]);
    expect(form.selectedCommodityIds, {201});
    expect(form.previewPrice(product), product.price);
    form.valueController.text = '15';
    expect(form.previewPrice(product), '\u20b1102.00');
    form.setDiscountType('amount');
    expect(form.previewPrice(product), '\u20b1105.00');
    form.setDiscountType('sale_price');
    expect(form.previewPrice(product), '\u20b115.00');
    form.setDiscountType('amount');
    form.valueController.text = '120';
    expect(form.previewPrice(product), 'Invalid discount');
    form.toggleAllProducts();
    expect(form.selectedCommodityIds, isEmpty);
    form.toggleAllProducts();
    expect(form.selectedCommodityIds, {201});
  });

  test('preserves validation messages and ordering', () async {
    expect(await form.save(), isNull);
    expect(form.errorMessage, 'Please enter a promotion name.');
    form.nameController.text = 'Harvest';
    expect(await form.save(), isNull);
    expect(form.errorMessage, 'Please enter a valid discount value.');
    form.valueController.text = '91';
    expect(await form.save(), isNull);
    expect(form.errorMessage, 'Percentage discount cannot exceed 90%.');
    form.valueController.text = '15';
    form.setStartDate(DateTime(2026, 10, 10));
    form.setEndDate(DateTime(2026, 10, 9));
    expect(await form.save(), isNull);
    expect(form.errorMessage, 'End date must be after start date.');
    form.setEndDate(DateTime(2026, 10, 10));
    form.selectProduct(201, false);
    expect(await form.save(), isNull);
    expect(form.errorMessage, 'Select at least one product for this discount.');
    expect(repository.saved, isNull);
  });

  test('save failure allows retry and normalizes promotion input', () async {
    form.nameController.text = ' Harvest ';
    form.valueController.text = '15';
    form.promoCodeController.text = ' harvest15 ';
    repository.fail = true;
    expect(await form.save(), isNull);
    expect(form.isSaving, isFalse);
    expect(form.errorMessage, 'Failed to save discount. Please try again.');
    repository.fail = false;
    final result = await form.save();
    expect(result?.saleId, 501);
    expect(result?.name, 'Harvest');
    expect(result?.promoCode, 'HARVEST15');
    expect(repository.saved?.commodityIds, [201]);
    expect(form.errorMessage, isNull);
  });

  test(
    'late save completion after disposal does not notify listeners',
    () async {
      final dismissedForm = FarmerDiscountFormController(
        farmId: 10,
        repository: repository,
        initialProduct: product,
      );
      dismissedForm.nameController.text = 'Harvest';
      dismissedForm.valueController.text = '15';
      repository.pending = Completer<void>();
      final saving = dismissedForm.save();
      dismissedForm.dispose();
      repository.pending!.complete();
      expect(await saving, isNull);
    },
  );

  for (final editing in [false, true]) {
    testWidgets(
      'dialog ${editing ? 'updates' : 'creates'} and returns discount',
      (tester) async {
        await tester.binding.setSurfaceSize(const Size(430, 932));
        addTearDown(() => tester.binding.setSurfaceSize(null));
        FarmerDiscount? result;
        await tester.pumpWidget(
          MaterialApp(
            theme: AgrisellTheme.light,
            home: Builder(
              builder: (context) => Scaffold(
                body: TextButton(
                  onPressed: () async {
                    result = await showFarmerDiscountDialog(
                      context,
                      farmId: 10,
                      initialProduct: product,
                      discountRepository: repository,
                      existingDiscount: editing
                          ? const FarmerDiscount(
                              saleId: 777,
                              farmId: 10,
                              name: 'Existing',
                              discountType: 'percentage',
                              discountValue: 10,
                              commodityIds: [201],
                            )
                          : null,
                    );
                  },
                  child: const Text('Open'),
                ),
              ),
            ),
          ),
        );
        await tester.tap(find.text('Open'));
        await tester.pumpAndSettle();
        expect(
          find.text(editing ? 'Edit Promotion' : 'Create Promotion / Discount'),
          findsOneWidget,
        );
        if (editing) {
          expect(find.text('Existing'), findsOneWidget);
          expect(find.text('Sale: \u20b1108.00'), findsOneWidget);
        }
        await tester.enterText(find.byType(TextField).at(0), 'Harvest');
        await tester.enterText(find.byType(TextField).at(1), '15');
        await tester.pump();
        expect(find.text('Sale: \u20b1102.00'), findsOneWidget);
        await tester.tap(find.text('Amount Off (\u20b1)'));
        await tester.pump();
        expect(find.text('Sale: \u20b1105.00'), findsOneWidget);
        final save = find.byType(ElevatedButton);
        await tester.ensureVisible(save);
        await tester.tap(save);
        await tester.pumpAndSettle();
        expect(result?.saleId, editing ? 777 : 501);
        expect(result?.discountType, 'amount');
        expect(result?.promoCode, isNull);
        expect(repository.saved?.name, 'Harvest');
        expect(tester.takeException(), isNull);
      },
    );
  }
}
