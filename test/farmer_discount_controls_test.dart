import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:agresell_app/core/theme/agrisell_theme.dart';
import 'package:agresell_app/features/farmer/discounts/data/farmer_discount_repository.dart';
import 'package:agresell_app/features/farmer/discounts/domain/farmer_discount.dart';
import 'package:agresell_app/features/farmer/discounts/presentation/screens/farmer_discounts_screen.dart';
import 'package:agresell_app/features/farmer/products/data/farmer_commodity_repository.dart';
import 'package:agresell_app/features/farmer/products/domain/farmer_dashboard_product.dart';
import 'package:agresell_app/features/farmer/products/presentation/screens/farmer_product_edit_screen.dart';

class FakeFarmerCommodityRepo extends FarmerCommodityRepository {
  const FakeFarmerCommodityRepo(this.products);
  final List<FarmerDashboardProduct> products;

  @override
  bool get isAvailable => true;

  @override
  Future<List<FarmerDashboardProduct>> loadProducts() async => products;
}

void main() {
  final testProduct1 = FarmerDashboardProduct(
    commodityId: 201,
    farmId: 10,
    name: 'Red Onions',
    price: '₱120.00',
    unit: 'per kg',
    harvestDate: '2026-09-20',
    category: 'Vegetables',
    availableWeight: '40 kg',
    imageAsset: 'assets/images/vege.jpeg',
    activeSaleId: 501,
    activeSaleIsFarmerOwned: true,
    activeSaleName: 'Mid-Month Special',
    activeSaleDiscount: '10% OFF',
    activeSaleType: 'percentage',
    activeSaleValue: 10,
    activeSalePromoCode: 'ONION10',
    activeSaleStartsAt: DateTime(2026, 9, 1),
    activeSaleEndsAt: DateTime(2026, 9, 30),
  );

  final testProduct2 = FarmerDashboardProduct(
    commodityId: 202,
    farmId: 10,
    name: 'Eggplant',
    price: '₱80.00',
    unit: 'per kg',
    harvestDate: '2026-09-20',
    category: 'Vegetables',
    availableWeight: '25 kg',
    imageAsset: 'assets/images/vege.jpeg',
  );

  final testDiscounts = [
    FarmerDiscount(
      saleId: 501,
      farmId: 10,
      name: 'Mid-Month Special',
      discountType: 'percentage',
      discountValue: 10,
      promoCode: 'ONION10',
      isEnabled: true,
      startsAt: DateTime(2026, 9, 1),
      endsAt: DateTime(2026, 9, 30),
      commodityIds: [201],
      commodities: [
        {'commodity_id': 201, 'commodity_name': 'Red Onions'}
      ],
    ),
    FarmerDiscount(
      saleId: 502,
      farmId: 10,
      name: 'Upcoming Harvest Sale',
      discountType: 'fixed_amount',
      discountValue: 20,
      promoCode: null,
      isEnabled: true,
      startsAt: DateTime(2026, 10, 1),
      endsAt: DateTime(2026, 10, 15),
      commodityIds: [202],
      commodities: [
        {'commodity_id': 202, 'commodity_name': 'Eggplant'}
      ],
    ),
  ];

  testWidgets('FarmerDiscountsScreen displays discount list, stats, and delete dialog', (tester) async {
    await tester.binding.setSurfaceSize(const Size(430, 932));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    var deletedSaleId = 0;
    final discountRepo = FarmerDiscountRepository(
      customDiscountsLoader: (farmId) async => testDiscounts,
      customDiscountDeleter: (saleId, farmId) async {
        deletedSaleId = saleId;
      },
    );
    final commodityRepo = FakeFarmerCommodityRepo([testProduct1, testProduct2]);

    await tester.pumpWidget(
      MaterialApp(
        debugShowCheckedModeBanner: false,
        theme: AgrisellTheme.light,
        home: FarmerDiscountsScreen(
          farmId: 10,
          discountRepository: discountRepo,
          commodityRepository: commodityRepo,
        ),
      ),
    );
    await tester.pumpAndSettle();

    // Verify Title and Stats
    expect(find.text('Discounts & Promotions'), findsOneWidget);
    expect(find.text('Active'), findsOneWidget);
    expect(find.text('Scheduled'), findsOneWidget);
    expect(find.text('Total'), findsOneWidget);

    // Verify Discount Cards
    expect(find.text('Mid-Month Special'), findsOneWidget);
    expect(find.text('10% OFF'), findsOneWidget);
    expect(find.text('Code: ONION10'), findsOneWidget);
    expect(find.text('Red Onions'), findsOneWidget);

    expect(find.text('Upcoming Harvest Sale'), findsOneWidget);
    expect(find.text('₱20 OFF'), findsOneWidget);
    expect(find.text('Eggplant'), findsOneWidget);

    // Test Delete Action
    await tester.tap(find.text('Delete').first);
    await tester.pumpAndSettle();

    expect(find.text('Delete Promotion?'), findsOneWidget);
    expect(find.textContaining('Are you sure you want to delete "Mid-Month Special"?'), findsOneWidget);

    // Confirm Delete
    await tester.tap(find.widgetWithText(ElevatedButton, 'Delete'));
    await tester.pumpAndSettle();

    expect(deletedSaleId, 501);
  });

  testWidgets('FarmerProductEditScreen displays active farmer promotion section with edit and remove options', (tester) async {
    await tester.binding.setSurfaceSize(const Size(430, 932));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    var deletedSaleId = 0;
    final discountRepo = FarmerDiscountRepository(
      customDiscountDeleter: (saleId, farmId) async {
        deletedSaleId = saleId;
      },
    );

    await tester.pumpWidget(
      MaterialApp(
        debugShowCheckedModeBanner: false,
        theme: AgrisellTheme.light,
        home: FarmerProductEditScreen(
          product: testProduct1,
          discountRepository: discountRepo,
        ),
      ),
    );
    await tester.pumpAndSettle();

    // Verify Farmer-Owned Active Promotion is displayed (not the admin one)
    expect(find.text('Active Product Promotion'), findsOneWidget);
    expect(find.text('Featured in Active Admin Sale'), findsNothing);
    expect(find.textContaining('Mid-Month Special (10% OFF)'), findsOneWidget);

    // Check action buttons: Edit Discount & Remove
    expect(find.widgetWithText(TextButton, 'Edit Discount'), findsOneWidget);
    expect(find.widgetWithText(TextButton, 'Remove'), findsOneWidget);

    // Tap Remove
    await tester.tap(find.widgetWithText(TextButton, 'Remove'));
    await tester.pumpAndSettle();

    expect(find.text('Remove Discount?'), findsOneWidget);
    await tester.tap(find.widgetWithText(ElevatedButton, 'Remove'));
    await tester.pumpAndSettle();

    expect(deletedSaleId, 501);
    // After removal, should show "Product Discount" and "Put on Sale"
    expect(find.text('Product Discount'), findsOneWidget);
    expect(find.text('Put on Sale'), findsOneWidget);
  });

  testWidgets('FarmerProductEditScreen displays add discount button when product has no sale', (tester) async {
    await tester.binding.setSurfaceSize(const Size(430, 932));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    await tester.pumpWidget(
      MaterialApp(
        debugShowCheckedModeBanner: false,
        theme: AgrisellTheme.light,
        home: FarmerProductEditScreen(
          product: testProduct2,
        ),
      ),
    );
    await tester.pumpAndSettle();

    // Product without sale should show "Product Discount" and "Put on Sale" button
    expect(find.text('Product Discount'), findsOneWidget);
    expect(find.text('No active promotion on this product.'), findsOneWidget);
    expect(find.widgetWithText(OutlinedButton, 'Put on Sale'), findsOneWidget);
    expect(find.text('Active Product Promotion'), findsNothing);
    expect(find.text('Featured in Active Admin Sale'), findsNothing);
  });
}
