import 'package:agresell_app/core/theme/agrisell_theme.dart';
import 'support/home_product_fixture.dart';
import 'package:agresell_app/features/buyer/cart/presentation/controllers/basket_controller.dart';
import 'package:agresell_app/features/buyer/cart/presentation/screens/checkout_screen.dart';
import 'package:agresell_app/features/buyer/cart/presentation/widgets/basket/basket_checkout_controls.dart';
import 'package:agresell_app/features/buyer/cart/presentation/widgets/basket/notched_checkout_footer.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('checkout footer does not overflow with large text', (
    tester,
  ) async {
    await tester.binding.setSurfaceSize(const Size(320, 480));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    await tester.pumpWidget(
      MaterialApp(
        debugShowCheckedModeBanner: false,
        theme: AgrisellTheme.light,
        home: MediaQuery(
          data: const MediaQueryData(
            size: Size(320, 480),
            padding: EdgeInsets.only(bottom: 24),
            textScaler: TextScaler.linear(3.2),
          ),
          child: Scaffold(
            bottomNavigationBar: NotchedCheckoutFooter(
              actionLabel: 'Checkout',
              enabled: true,
              onActionTap: () {},
              leading: BasketCheckoutSummary(
                allSelected: true,
                hasItems: true,
                total: 123456.78,
                onAllChanged: (_) {},
              ),
            ),
            body: const SizedBox.shrink(),
          ),
        ),
      ),
    );

    expect(tester.takeException(), isNull);
  });

  testWidgets('checkout screen stays overflow-free on compact screens', (
    tester,
  ) async {
    final controller = BasketController.instance;
    controller
      ..clear()
      ..addProduct(testHomeProducts[0], quantity: 2);
    addTearDown(controller.clear);

    await tester.binding.setSurfaceSize(const Size(360, 640));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    await tester.pumpWidget(
      MaterialApp(
        debugShowCheckedModeBanner: false,
        theme: AgrisellTheme.light,
        home: const MediaQuery(
          data: MediaQueryData(
            size: Size(360, 640),
            textScaler: TextScaler.linear(1.3),
          ),
          child: CheckoutScreen(),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(tester.takeException(), isNull);
  });
}
