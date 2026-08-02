import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:agresell_app/core/constants/agrisell_routes.dart';
import 'package:agresell_app/core/theme/agrisell_theme.dart';
import 'package:agresell_app/features/buyer/cart/presentation/controllers/basket_controller.dart';
import 'package:agresell_app/features/buyer/cart/presentation/screens/basket_screen.dart';
import 'package:agresell_app/features/buyer/cart/presentation/screens/checkout_screen.dart';
import 'package:agresell_app/features/shared/orders/presentation/controllers/order_controller.dart';

import 'support/home_product_fixture.dart';

void main() {
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
    await tester.tap(find.text('Place Order'));
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
  });
}
