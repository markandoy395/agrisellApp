import 'dart:async';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:agresell_app/core/utils/async_operation_gate.dart';
import 'package:agresell_app/core/services/pending_operation_store.dart';
import 'package:agresell_app/features/shared/orders/data/order_local_repository.dart';
import 'package:agresell_app/features/shared/orders/data/order_repository.dart';
import 'package:agresell_app/features/shared/orders/domain/placed_order.dart';
import 'package:agresell_app/features/shared/orders/domain/basket_cart_item.dart';
import 'package:agresell_app/features/shared/orders/presentation/controllers/order_controller.dart';
import 'support/home_product_fixture.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  setUp(() => SharedPreferences.setMockInitialValues({}));

  test(
    'in-flight callers share success/failure and later calls retry',
    () async {
      final gate = AsyncOperationGate();
      final pending = Completer<int>();
      final first = gate.run('one', () => pending.future);
      final second = gate.run('one', () async => 99);
      expect(identical(first, second), isTrue);
      pending.complete(7);
      expect(await second, 7);
      expect(await gate.run('one', () async => 8), 8);
      final failed = gate.run<int>(
        'one',
        () async => throw StateError('failed'),
      );
      await expectLater(failed, throwsStateError);
      expect(await gate.run('one', () async => 9), 9);
    },
  );

  test('resource writes stay ordered even after a failed write', () async {
    final gate = AsyncOperationGate();
    final pending = Completer<void>();
    final events = <int>[];
    final first = gate.serialize('stock', () async {
      await pending.future;
      events.add(1);
      throw StateError('rejected');
    });
    final expectation = expectLater(first, throwsStateError);
    final second = gate.serialize('stock', () async => events.add(2));
    expect(events, isEmpty);
    pending.complete();
    await expectation;
    await second;
    expect(events, [1, 2]);
  });

  test('retry identity survives recreation and stays account scoped', () async {
    final first = await PendingOperationStore().prepare('a', 'send', {
      'body': 'secret',
    });
    final second = await PendingOperationStore().prepare('a', 'send', {
      'body': 'secret',
    });
    final other = await PendingOperationStore().prepare('b', 'send', {
      'body': 'secret',
    });
    expect(second.id, first.id);
    expect(second.isRetry, isTrue);
    expect(other.id, isNot(first.id));
    final prefs = await SharedPreferences.getInstance();
    expect(prefs.getString(first.slot), isNot(contains('secret')));
    await PendingOperationStore().complete(second);
    expect(
      (await PendingOperationStore().prepare('a', 'send', {
        'body': 'secret',
      })).id,
      isNot(first.id),
    );
  });

  test('parallel checkout calls create one logical order', () async {
    final repository = ControlledOrders()..gate = Completer<void>();
    final controller = OrderController(repository: repository);
    addTearDown(controller.dispose);
    await controller.loadForAccount('buyer-a');
    final first = place(controller);
    final second = place(controller);
    await Future<void>.delayed(Duration.zero);
    repository.gate!.complete();
    expect((await first).single.id, (await second).single.id);
    expect(repository.createCount, 1);
    expect(controller.orders, hasLength(1));
  });

  test(
    'lost committed response reconciles after controller recreation',
    () async {
      final repository = ControlledOrders()..loseResponse = true;
      final first = OrderController(repository: repository);
      await first.loadForAccount('buyer-a');
      await expectLater(place(first), throwsA(isA<OrderPlacementException>()));
      final savedId = repository.saved.single.id;
      first.dispose();
      final retry = OrderController(repository: repository);
      addTearDown(retry.dispose);
      await retry.loadForAccount('buyer-a');
      expect((await place(retry)).single.id, savedId);
      expect(repository.createCount, 1);
      expect(retry.orders, hasLength(1));
    },
  );

  test('definite rejection permits a corrected checkout', () async {
    final repository = ControlledOrders()..reject = true;
    final controller = OrderController(repository: repository);
    addTearDown(controller.dispose);
    await controller.loadForAccount('buyer-a');
    await expectLater(
      place(controller),
      throwsA(isA<OrderPlacementException>()),
    );
    repository.reject = false;
    expect(await place(controller, address: 'Corrected address'), hasLength(1));
  });

  test('old checkout failure cannot overwrite a switched account', () async {
    final repository = ControlledOrders()
      ..gate = Completer<void>()
      ..loseResponse = true;
    final controller = OrderController(repository: repository);
    addTearDown(controller.dispose);
    await controller.loadForAccount('buyer-a');
    final first = place(controller);
    final expectation = expectLater(
      first,
      throwsA(isA<OrderPlacementException>()),
    );
    await Future<void>.delayed(Duration.zero);
    controller.unload();
    final loading = controller.loadForAccount('buyer-b');
    repository.gate!.complete();
    await expectation;
    await loading;
    expect(controller.orders, isEmpty);
  });
}

Future<List<PlacedOrder>> place(
  OrderController controller, {
  String address = 'Address',
}) => controller.placeToShipOrders(
  items: [BasketCartItem.fromProduct(testHomeProducts.first)],
  deliveryAddress: address,
  phoneNumber: '09123456789',
);

class ControlledOrders extends OrderLocalRepository {
  Completer<void>? gate;
  bool loseResponse = false;
  bool reject = false;
  int createCount = 0;
  List<PlacedOrder> saved = [];
  String? savedOwner;
  @override
  Future<List<PlacedOrder>> load(String accountId) async =>
      accountId == savedOwner ? List.of(saved) : [];
  @override
  Future<void> createOrders({
    required String accountId,
    required Iterable<PlacedOrder> newOrders,
    required Iterable<PlacedOrder> currentOrders,
  }) async {
    createCount++;
    if (gate != null) await gate!.future;
    if (reject)
      throw const OrderPlacementException(
        'Stock changed',
        definitivelyRejected: true,
      );
    savedOwner = accountId;
    saved = List.of(newOrders);
    if (loseResponse) {
      loseResponse = false;
      throw const OrderPlacementException('Response lost');
    }
  }
}
