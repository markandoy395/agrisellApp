import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:agresell_app/core/theme/agrisell_theme.dart';
import 'package:agresell_app/features/buyer/deals/data/buyer_deals_repository.dart';
import 'package:agresell_app/features/buyer/deals/domain/deal_voucher.dart';
import 'package:agresell_app/features/buyer/deals/presentation/screens/deals_and_promos_screen.dart';
import 'package:agresell_app/features/buyer/cart/presentation/widgets/checkout/checkout_voucher_picker_sheet.dart';
import 'package:agresell_app/features/shared/orders/domain/basket_cart_item.dart';

class FakeBuyerDealsRepository extends BuyerDealsRepository {
  const FakeBuyerDealsRepository(this.deals, {this.applicableCommodityMap = const {}});
  final List<DealVoucher> deals;
  final Map<int, Set<int>> applicableCommodityMap;

  @override
  bool get isAvailable => true;

  @override
  Future<List<DealVoucher>> loadActiveDeals() async => deals;

  @override
  Future<Set<int>> loadApplicableCommodityIds(int saleId) async =>
      applicableCommodityMap[saleId] ?? const <int>{};
}

void main() {
  final List<DealVoucher> testDeals = [
    DealVoucher(
      saleId: 1,
      name: 'Harvest Welcome 20',
      discountType: 'percentage',
      discountValue: 20,
      code: 'HARVEST20',
      startsAt: DateTime(2026, 9, 1),
      endsAt: DateTime(2026, 9, 30),
      productCount: 5,
    ),
    DealVoucher(
      saleId: 2,
      name: 'Fresh Greens Flash Sale',
      discountType: 'fixed_amount',
      discountValue: 50,
      code: 'GREEN50',
      farmId: 10,
      farmName: 'Green Valley Farm',
      startsAt: DateTime(2026, 9, 15),
      endsAt: DateTime(2026, 9, 25),
      productCount: 2,
    ),
    DealVoucher(
      saleId: 3,
      name: 'Platform Mega Markdown',
      discountType: 'percentage',
      discountValue: 15,
      code: null, // No promo code, automatic deal
      startsAt: DateTime(2026, 9, 10),
      endsAt: DateTime(2026, 10, 1),
      productCount: 12,
    ),
  ];

  testWidgets('DealsAndPromosScreen displays vouchers and filters by tabs', (tester) async {
    await tester.binding.setSurfaceSize(const Size(430, 932));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    final repo = FakeBuyerDealsRepository(testDeals);

    await tester.pumpWidget(
      MaterialApp(
        debugShowCheckedModeBanner: false,
        theme: AgrisellTheme.light,
        home: DealsAndPromosScreen(dealsRepository: repo),
      ),
    );
    await tester.pumpAndSettle();

    // Verify Title & Tabs
    expect(find.text('Deals & Voucher Wallet'), findsOneWidget);
    expect(find.text('Vouchers & Codes (2)'), findsOneWidget);
    expect(find.text('All Deals (3)'), findsOneWidget);

    // Initial Tab: "Vouchers & Codes" should only show deals with codes
    expect(find.text('Harvest Welcome 20'), findsOneWidget);
    expect(find.text('Fresh Greens Flash Sale'), findsOneWidget);
    expect(find.text('Platform Mega Markdown'), findsNothing);

    // Verify Voucher Card details
    expect(find.text('20% OFF'), findsOneWidget);
    expect(find.text('₱50 OFF'), findsOneWidget);
    expect(find.text('HARVEST20'), findsOneWidget);
    expect(find.text('GREEN50'), findsOneWidget);
    expect(find.text('Green Valley Farm'), findsOneWidget);

    // Switch to "All Deals" tab
    await tester.tap(find.text('All Deals (3)'));
    await tester.pumpAndSettle();

    // All deals should now be visible including automatic discount
    expect(find.text('Harvest Welcome 20'), findsOneWidget);
    expect(find.text('Fresh Greens Flash Sale'), findsOneWidget);
    expect(find.text('Platform Mega Markdown'), findsOneWidget);
    expect(find.text('15% OFF'), findsOneWidget);
  });

  testWidgets('DealsAndPromosScreen filters deals by search query', (tester) async {
    await tester.binding.setSurfaceSize(const Size(430, 932));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    final repo = FakeBuyerDealsRepository(testDeals);

    await tester.pumpWidget(
      MaterialApp(
        debugShowCheckedModeBanner: false,
        theme: AgrisellTheme.light,
        home: DealsAndPromosScreen(dealsRepository: repo),
      ),
    );
    await tester.pumpAndSettle();

    // Search for "GREEN50"
    await tester.enterText(find.byType(TextField), 'GREEN50');
    await tester.pumpAndSettle();

    expect(find.text('Fresh Greens Flash Sale'), findsOneWidget);
    expect(find.text('Harvest Welcome 20'), findsNothing);

    // Clear search
    await tester.tap(find.byIcon(Icons.clear_rounded));
    await tester.pumpAndSettle();

    expect(find.text('Harvest Welcome 20'), findsOneWidget);
    expect(find.text('Fresh Greens Flash Sale'), findsOneWidget);
  });

  testWidgets('CheckoutVoucherPickerSheet displays and selects voucher for checkout', (tester) async {
    await tester.binding.setSurfaceSize(const Size(430, 932));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    final repo = FakeBuyerDealsRepository(
      testDeals,
      applicableCommodityMap: {
        1: <int>{}, // Empty set = platform-wide (applies to all)
      },
    );
    DealVoucher? selected;

    final dummyCartItems = [
      const BasketCartItem(
        productId: '101',
        productName: 'Organic Tomatoes',
        image: 'assets/images/vege.jpeg',
        priceLabel: '₱80.00',
        pricePerKg: 80.0,
        unit: 'per kg',
        quantity: 2,
        sellerName: 'Green Valley Farm',
        sellerLocation: 'Benguet',
        harvestDate: '2026-09-20',
        availableWeight: '50 kg',
        isSelected: true,
      ),
    ];

    await tester.pumpWidget(
      MaterialApp(
        debugShowCheckedModeBanner: false,
        theme: AgrisellTheme.light,
        home: Scaffold(
          body: Builder(
            builder: (context) => ElevatedButton(
              onPressed: () {
                showModalBottomSheet<void>(
                  context: context,
                  isScrollControlled: true,
                  backgroundColor: Colors.transparent,
                  builder: (_) => CheckoutVoucherPickerSheet(
                    cartItems: dummyCartItems,
                    dealsRepository: repo,
                    onSelectVoucher: (v) => selected = v,
                  ),
                );
              },
              child: const Text('Open Picker'),
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.text('Open Picker'));
    await tester.pumpAndSettle();

    // Should show the Deals screen inside modal with 'Available Vouchers' title
    expect(find.text('Available Vouchers'), findsOneWidget);
    expect(find.text('Apply'), findsWidgets);

    // Tap apply on the first voucher (HARVEST20)
    await tester.tap(find.text('Apply').first);
    await tester.pumpAndSettle();

    // Bottom sheet should close and voucher selected
    expect(selected, isNotNull);
    expect(selected?.code, 'HARVEST20');
  });
}
