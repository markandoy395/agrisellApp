import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:agresell_app/core/theme/agrisell_theme.dart';
import 'package:agresell_app/features/buyer/cart/data/checkout_voucher_service.dart';
import 'package:agresell_app/features/buyer/cart/presentation/controllers/basket_controller.dart';
import 'package:agresell_app/features/buyer/cart/presentation/screens/checkout_screen.dart';
import 'package:agresell_app/features/shared/orders/presentation/controllers/order_controller.dart';
import 'support/home_product_fixture.dart';

void main() {
  final controller = BasketController.instance;
  final orderController = OrderController.instance;

  setUp(() {
    controller.clear();
    orderController.clear();
  });

  tearDown(() {
    controller.clear();
    orderController.clear();
  });

  testWidgets('checkout applies voucher and displays discount breakdown', (tester) async {
    await tester.binding.setSurfaceSize(const Size(430, 1100));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    controller.addProduct(testHomeProducts[0], quantity: 2); // 2 * 15 = 30
    controller.addProduct(testHomeProducts[1], quantity: 1); // 1 * 35 = 35 -> Total = 65

    final mockVoucherService = CheckoutVoucherService(
      customValidator: (code, items) async {
        if (code == 'HARVEST20') {
          return const AppliedVoucher(
            saleId: '1',
            name: 'Harvest Festival Sale',
            code: 'HARVEST20',
            discountType: 'percentage',
            discountValue: 20,
            targetUserGroup: 'all_users',
            discountAmount: 13.0, // 20% of 65 = 13
            applicableCommodityIds: {},
          );
        }
        if (code == 'EXPIRED') {
          throw const VoucherValidationException('This voucher code has expired.');
        }
        throw const VoucherValidationException('Invalid or inactive voucher code.');
      },
    );

    await tester.pumpWidget(
      MaterialApp(
        debugShowCheckedModeBanner: false,
        theme: AgrisellTheme.light,
        home: CheckoutScreen(voucherService: mockVoucherService),
      ),
    );
    await tester.pumpAndSettle();

    // Initial state without voucher
    expect(find.text('Order Summary & Discounts'), findsOneWidget);
    expect(find.text('Items Subtotal'), findsOneWidget);
    expect(find.text('Voucher / Promo Code'), findsOneWidget);
    expect(find.text('Enter code (e.g. HARVEST20)'), findsOneWidget);

    // Apply invalid code
    await tester.enterText(find.byType(TextField).last, 'INVALID');
    await tester.tap(find.text('Apply'));
    await tester.pumpAndSettle();

    expect(find.text('Invalid or inactive voucher code.'), findsOneWidget);

    // Apply expired code
    await tester.enterText(find.byType(TextField).last, 'EXPIRED');
    await tester.tap(find.text('Apply'));
    await tester.pumpAndSettle();

    expect(find.text('This voucher code has expired.'), findsOneWidget);

    // Apply valid code
    await tester.enterText(find.byType(TextField).last, 'HARVEST20');
    await tester.tap(find.text('Apply'));
    await tester.pumpAndSettle();

    // Verify voucher is applied
    expect(find.text('HARVEST20'), findsOneWidget);
    expect(find.text('20% OFF'), findsOneWidget);
    expect(find.text('Voucher (HARVEST20)'), findsOneWidget);
    expect(find.text('-₱ 13'), findsWidgets);
    expect(find.textContaining('You save'), findsOneWidget);

    // Final total after 20% off 65 = 52
    expect(find.textContaining('₱ 52'), findsWidgets);

    // Remove voucher
    await tester.tap(find.byTooltip('Remove voucher'));
    await tester.pumpAndSettle();

    expect(find.text('HARVEST20'), findsNothing);
    expect(find.text('Enter code (e.g. HARVEST20)'), findsOneWidget);
  });
}
