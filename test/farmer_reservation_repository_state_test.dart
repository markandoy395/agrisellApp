import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:agresell_app/features/farmer/reservations/presentation/screens/farmer_reserve_screen.dart';
import 'package:agresell_app/features/shared/orders/data/order_repository.dart';
import 'package:agresell_app/features/shared/orders/domain/placed_order.dart';
import 'package:agresell_app/features/shared/orders/presentation/controllers/order_controller.dart';

void main() {
  testWidgets(
    'farmer reservations show loading then an empty repository state',
    (tester) async {
      final repository = _ReservationRepository();
      final controller = OrderController(repository: repository);
      addTearDown(controller.dispose);
      await controller.loadForAccount('farmer-1');
      repository.pendingLoad = Completer<List<PlacedOrder>>();

      await _pumpScreen(tester, controller);
      expect(find.text('Loading reservations'), findsOneWidget);

      repository.pendingLoad!.complete(const []);
      await tester.pumpAndSettle();
      expect(find.text('No reservations'), findsOneWidget);
    },
  );

  testWidgets('farmer reservations expose failure and retry repository load', (
    tester,
  ) async {
    final repository = _ReservationRepository()..shouldFail = true;
    final controller = OrderController(repository: repository);
    addTearDown(controller.dispose);
    await expectLater(
      controller.loadForAccount('farmer-1'),
      throwsA(isA<Exception>()),
    );

    await _pumpScreen(tester, controller);
    await tester.pumpAndSettle();
    expect(find.text('Unable to load reservations'), findsOneWidget);

    repository.shouldFail = false;
    await tester.tap(find.text('Try again'));
    await tester.pumpAndSettle();

    expect(find.text('No reservations'), findsOneWidget);
    expect(repository.loadAttempts, 3);
  });
}

Future<void> _pumpScreen(
  WidgetTester tester,
  OrderController controller,
) async {
  await tester.binding.setSurfaceSize(const Size(430, 932));
  addTearDown(() => tester.binding.setSurfaceSize(null));
  await tester.pumpWidget(
    MaterialApp(
      home: Scaffold(body: FarmerReserveScreen(controller: controller)),
    ),
  );
  await tester.pump();
}

class _ReservationRepository implements OrderRepository {
  var shouldFail = false;
  var loadAttempts = 0;
  Completer<List<PlacedOrder>>? pendingLoad;

  @override
  Future<List<PlacedOrder>> load(String accountId) {
    loadAttempts++;
    if (shouldFail) return Future.error(Exception('reservation query failed'));
    final pending = pendingLoad;
    if (pending != null) return pending.future;
    return Future.value(const []);
  }

  @override
  Future<void> markReadyForPickup({
    required String accountId,
    required String orderId,
  }) async {}

  @override
  Future<void> recordGcashRefund({
    required String accountId,
    required String orderId,
    required String reference,
  }) async {}

  @override
  Future<void> resubmitGcashReference({
    required String accountId,
    required String orderId,
    required String reference,
  }) async {}

  @override
  Future<void> reviewGcashPayment({
    required String accountId,
    required String orderId,
    required bool approved,
  }) async {}

  @override
  Future<void> save(String accountId, Iterable<PlacedOrder> orders) async {}
}
