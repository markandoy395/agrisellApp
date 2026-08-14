import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:agresell_app/features/farmer/reservations/presentation/screens/farmer_reserve_screen.dart';
import 'package:agresell_app/features/shared/orders/data/order_local_repository.dart';
import 'package:agresell_app/features/shared/orders/domain/placed_order.dart';
import 'package:agresell_app/features/shared/orders/presentation/controllers/order_controller.dart';

void main() {
  testWidgets('Reserve card opens complete snapshotted buyer information', (
    tester,
  ) async {
    await tester.binding.setSurfaceSize(const Size(430, 932));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    final controller = await _controllerWith(_order());

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(body: FarmerReserveScreen(controller: controller)),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Juan Dela Cruz'), findsOneWidget);
    expect(find.text('0912 345 6789'), findsNothing);
    expect(find.text('123 Main Street, Lianga'), findsNothing);
    expect(find.textContaining('3 items'), findsOneWidget);

    await tester.tap(find.byKey(const ValueKey('farmer-order-card-ORD-1024')));
    await tester.pumpAndSettle();

    expect(find.text('Order Details'), findsOneWidget);
    expect(find.text('Buyer Information'), findsOneWidget);
    expect(find.text('Juan Dela Cruz'), findsOneWidget);
    expect(find.text('0912 345 6789'), findsOneWidget);
    expect(find.text('123 Main Street, Lianga'), findsOneWidget);
    expect(find.text('Order Information'), findsOneWidget);
    expect(find.text('Order/Reservation ID'), findsOneWidget);
    expect(find.text('ORD-1024'), findsWidgets);
    expect(find.text('Total Amount'), findsOneWidget);
    expect(find.text('\u20B1 130'), findsOneWidget);
  });

  testWidgets('missing buyer contact and address use safe fallback copy', (
    tester,
  ) async {
    await tester.binding.setSurfaceSize(const Size(430, 932));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    final controller = await _controllerWith(
      _order(buyerName: '', phoneNumber: '', deliveryAddress: ''),
    );

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(body: FarmerReserveScreen(controller: controller)),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.text('Buyer name not available'), findsOneWidget);

    await tester.tap(find.byKey(const ValueKey('farmer-order-card-ORD-1024')));
    await tester.pumpAndSettle();

    expect(find.text('Buyer name not available'), findsOneWidget);
    expect(find.text('Not provided'), findsOneWidget);
    expect(find.text('No delivery address available'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}

Future<OrderController> _controllerWith(PlacedOrder order) async {
  SharedPreferences.setMockInitialValues({});
  final preferences = await SharedPreferences.getInstance();
  final repository = OrderLocalRepository(preferences: preferences);
  await repository.save('farmer-1', [order]);
  final controller = OrderController(repository: repository);
  await controller.loadForAccount('farmer-1');
  return controller;
}

PlacedOrder _order({
  String buyerName = 'Juan Dela Cruz',
  String phoneNumber = '0912 345 6789',
  String deliveryAddress = '123 Main Street, Lianga',
}) => PlacedOrder(
  id: 'ORD-1024',
  buyerId: '42',
  buyerName: buyerName,
  status: PlacedOrderStatus.toShip,
  placedAt: DateTime(2026, 8, 11, 14, 5),
  deliveryAddress: deliveryAddress,
  phoneNumber: phoneNumber,
  items: const [
    PlacedOrderItem(
      productId: '1',
      productName: 'Tomato',
      image: 'assets/images/vege.jpeg',
      sellerName: 'Green Farm',
      pricePerKg: 50,
      unit: 'kg',
      quantity: 2,
    ),
    PlacedOrderItem(
      productId: '2',
      productName: 'Eggplant',
      image: 'assets/images/vege.jpeg',
      sellerName: 'Green Farm',
      pricePerKg: 30,
      unit: 'kg',
      quantity: 1,
    ),
  ],
);
