import 'dart:async';

import 'package:agresell_app/features/shared/orders/data/order_local_repository.dart';
import 'package:agresell_app/features/shared/orders/domain/placed_order.dart';
import 'package:agresell_app/features/shared/orders/presentation/controllers/order_controller.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test(
    'logout cancels a queued order load before it reads account data',
    () async {
      final repository = _RecordingRepository();
      final controller = OrderController(repository: repository);
      await controller.loadForAccount('seed');
      controller.clear();
      repository.loadedAccounts.clear();
      final pending = controller.loadForAccount('outgoing');
      controller.unload();
      repository.pendingSave.complete();
      await pending;
      expect(repository.loadedAccounts, isEmpty);
      expect(controller.orders, isEmpty);
      controller.dispose();
    },
  );

  test(
    'switching skips the queued outgoing load and loads only the new account',
    () async {
      final repository = _RecordingRepository();
      final controller = OrderController(repository: repository);
      await controller.loadForAccount('seed');
      controller.clear();
      repository.loadedAccounts.clear();
      final outgoing = controller.loadForAccount('outgoing');
      controller.unload();
      final selected = controller.loadForAccount('selected');
      repository.pendingSave.complete();
      await Future.wait([outgoing, selected]);
      expect(repository.loadedAccounts, ['selected']);
      controller.dispose();
    },
  );
}

class _RecordingRepository extends OrderLocalRepository {
  final loadedAccounts = <String>[];
  final pendingSave = Completer<void>();

  @override
  Future<void> save(String accountId, Iterable<PlacedOrder> orders) =>
      pendingSave.future;

  @override
  Future<List<PlacedOrder>> load(String accountId) async {
    loadedAccounts.add(accountId);
    return accountId == 'seed'
        ? [
            PlacedOrder(
              id: 'seed',
              status: PlacedOrderStatus.toShip,
              placedAt: DateTime(2026, 10, 13),
              deliveryAddress: 'Test address',
              phoneNumber: 'Test phone',
              items: const [],
            ),
          ]
        : [];
  }
}
