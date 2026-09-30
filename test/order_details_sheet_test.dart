import 'dart:convert';

import 'package:agresell_app/core/theme/agrisell_theme.dart';
import 'package:agresell_app/features/buyer/orders/presentation/screens/order_tracking_screen.dart';
import 'package:agresell_app/features/shared/orders/domain/order_status.dart';
import 'package:agresell_app/features/shared/orders/presentation/controllers/order_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  final orderController = OrderController.instance;

  setUp(() async {
    SharedPreferences.setMockInitialValues({
      'orders.local.v1.test-user': jsonEncode([
        {
          'id': 'ORD-1786430510386597-F4',
          'status': 'delivered',
          'placedAt': '2026-08-11T18:41:00.000',
          'acceptanceExpiresAt': '2026-08-11T18:41:00.000',
          'deliveryAddress':
              'zamora, Barangay Poblacion, Lianga, Surigao del Sur, Philippines',
          'phoneNumber': '09285585658',
          'isRated': true,
          'riderRated': false,
          'payment': {
            'method': 'cashOnDelivery',
            'status': 'verified',
            'transactionReference': '',
            'refundReference': '',
            'receiptImageReference': '',
            'receiptImageName': '',
          },
          'items': [
            {
              'productId': 'lettuce-1',
              'productName': 'Lettuce',
              'image': 'assets/images/home/vegetable.png',
              'sellerName': 'benjomark fuentes andoy',
              'pricePerKg': 10,
              'unit': 'kg',
              'quantity': 1,
            },
          ],
        },
      ]),
    });
    await orderController.loadForAccount('test-user');
  });

  tearDown(() {
    orderController.unload();
  });

  testWidgets(
    'order details modal bottom sheet opens without overflow on compact screen',
    (tester) async {
      await tester.binding.setSurfaceSize(const Size(360, 640));
      addTearDown(() => tester.binding.setSurfaceSize(null));

      await tester.pumpWidget(
        MaterialApp(
          theme: AgrisellTheme.light,
          home: const OrderTrackingScreen(
            initialFilter: OrderTrackingFilter.completed,
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('ORD-1786430510386597-F4'), findsOneWidget);
      expect(find.text('Details'), findsOneWidget);

      await tester.tap(find.text('Details'));
      await tester.pumpAndSettle();

      expect(tester.takeException(), isNull);
      expect(find.text('Order Details'), findsOneWidget);
      expect(find.text('Completed'), findsWidgets);
      expect(find.text('09285585658'), findsOneWidget);
      expect(
        find.textContaining('zamora, Barangay Poblacion, Lianga'),
        findsOneWidget,
      );

      // Verify the map tracking button is present in the scrollable sheet
      expect(find.text('Track Live Delivery on Map'), findsOneWidget);

      // Tap close button and verify dismissal
      await tester.tap(find.byTooltip('Close'));
      await tester.pumpAndSettle();

      expect(find.text('Order Details'), findsNothing);
      expect(tester.takeException(), isNull);
    },
  );
}
