import 'support/authenticated_test_session.dart';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:agresell_app/core/constants/agrisell_routes.dart';
import 'package:agresell_app/core/theme/agrisell_theme.dart';
import 'package:agresell_app/features/auth/data/auth_registration_service.dart';
import 'package:agresell_app/features/auth/data/auth_session_service.dart';
import 'package:agresell_app/features/auth/domain/buyer_shipping_address.dart';
import 'package:agresell_app/features/buyer/cart/presentation/controllers/basket_controller.dart';
import 'package:agresell_app/features/buyer/cart/presentation/screens/basket_screen.dart';
import 'package:agresell_app/features/buyer/cart/presentation/screens/checkout_screen.dart';
import 'package:agresell_app/features/shared/orders/presentation/controllers/order_controller.dart';

import 'support/home_product_fixture.dart';

void main() {
  configureAuthenticatedTests();
  final basket = BasketController.instance;
  final orders = OrderController.instance;

  setUp(() {
    basket.clear();
    orders.clear();
    SharedPreferences.setMockInitialValues({
      'confirmed_location_buyer_v1': jsonEncode({
        'latitude': 8.1575,
        'longitude': 125.1277,
        'accuracyMeters': 6.0,
        'capturedAt': '2026-07-29T08:00:00.000Z',
        'address': 'Test address',
        'notes': null,
      }),
    });
  });

  tearDown(() {
    AuthSessionService.instance.clearMemoryForTesting();
    AuthRegistrationService.instance.clearForTesting();
    basket.clear();
    orders.clear();
  });

  testWidgets('place order moves checkout items to To Ship', (tester) async {
    final semantics = tester.ensureSemantics();
    await tester.binding.setSurfaceSize(const Size(430, 932));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    basket.addProduct(testHomeProducts[0], quantity: 2);
    await tester.pumpWidget(
      MaterialApp(
        debugShowCheckedModeBanner: false,
        theme: AgrisellTheme.light,
        routes: {
          AgrisellRoutes.basket: (_) => const BasketScreen(),
          AgrisellRoutes.checkout: (_) => const CheckoutScreen(),
        },
        home: const CheckoutScreen(initialDeliveryAddress: 'Test address'),
      ),
    );
    await tester.pumpAndSettle();
    // Order persistence must complete outside the simulated widget clock so
    // subsequent authenticated fixtures can await the same controller's queue.
    await tester.runAsync(() async {
      await tester.tap(find.text('Place Order'));
      final deadline = DateTime.now().add(const Duration(seconds: 5));
      while (basket.selectedItems.isNotEmpty &&
          DateTime.now().isBefore(deadline)) {
        await Future<void>.delayed(const Duration(milliseconds: 10));
      }
    });
    await tester.pumpAndSettle();

    expect(orders.toShipOrders, hasLength(1));
    expect(orders.toShipOrders.single.items, hasLength(1));
    expect(
      orders.toShipOrders.single.items.single.productName,
      testHomeProducts[0].name,
    );
    expect(basket.items, isEmpty);
    expect(find.text('Order Tracking'), findsOneWidget);
    expect(find.text('To Pay'), findsAtLeastNWidgets(1));
    expect(find.text('To Ship'), findsAtLeastNWidgets(1));
    expect(find.text('To Receive'), findsAtLeastNWidgets(1));
    expect(find.text('To Rate'), findsAtLeastNWidgets(1));
    expect(find.text('Completed'), findsAtLeastNWidgets(1));
    expect(find.text('Cancelled'), findsOneWidget);
    expect(find.text(testHomeProducts[0].name), findsOneWidget);
    expect(
      find.byKey(const ValueKey('to-ship-quantity-counter')),
      findsOneWidget,
    );
    expect(
      find.bySemanticsLabel(RegExp(r'Order Placed, reached')),
      findsOneWidget,
    );
    expect(find.text('Details'), findsOneWidget);
    expect(find.text('Cancel'), findsOneWidget);
    expect(find.text('Chat'), findsOneWidget);

    await tester.tap(find.text('Details'));
    await tester.pumpAndSettle();
    expect(find.text('Order Details'), findsOneWidget);
    expect(find.text('Delivery Address'), findsOneWidget);
    semantics.dispose();
    // Dispose routed widgets and drain their persistence while the test clock
    // is still active, before the next account fixture loads saved orders.
    await tester.pumpWidget(const SizedBox.shrink());
    await tester.pumpAndSettle();
  });

  testWidgets('checkout accepts saved buyer shipping coordinates', (
    tester,
  ) async {
    SharedPreferences.setMockInitialValues({});
    final account = AuthSessionService.instance.currentAccount!;
    await AuthRegistrationService.instance.saveBuyerShippingAddress(
      account,
      const BuyerShippingAddress(
        address:
            'Purok 5, Barangay Hubang, San Francisco, Agusan del Sur, Philippines',
        latitude: 8.4822,
        longitude: 124.6472,
      ),
    );

    basket.addProduct(testHomeProducts[0], quantity: 1);
    await tester.pumpWidget(
      MaterialApp(
        debugShowCheckedModeBanner: false,
        theme: AgrisellTheme.light,
        routes: {
          AgrisellRoutes.basket: (_) => const BasketScreen(),
          AgrisellRoutes.checkout: (_) => const CheckoutScreen(),
        },
        home: const CheckoutScreen(),
      ),
    );
    await tester.pumpAndSettle();
    await tester.runAsync(() => tester.tap(find.text('Place Order')));
    await tester.pumpAndSettle();

    expect(
      find.text('Confirm your exact delivery map location first.'),
      findsNothing,
    );
    expect(orders.toShipOrders, hasLength(1));
    expect(orders.toShipOrders.single.deliveryLatitude, 8.4822);
    expect(orders.toShipOrders.single.deliveryLongitude, 124.6472);
    await tester.pumpWidget(const SizedBox.shrink());
    await tester.pumpAndSettle();
  });
}
