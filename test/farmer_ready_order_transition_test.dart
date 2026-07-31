import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'package:agresell_app/features/shared/orders/data/order_repository.dart';
import 'package:agresell_app/features/shared/orders/data/supabase_order_repository.dart';
import 'package:agresell_app/features/shared/orders/domain/placed_order.dart';
import 'package:agresell_app/features/shared/orders/presentation/controllers/order_controller.dart';

void main() {
  test('ready transition uses the dedicated repository operation', () async {
    final repository = _RecordingOrderRepository();
    final controller = OrderController(repository: repository);
    await controller.loadForAccount('farmer-1');

    await controller.markReadyForPickup('ORD-1');

    expect(repository.readyOrderIds, ['ORD-1']);
    expect(repository.saveCalls, 0);
    expect(controller.orders.single.status, PlacedOrderStatus.readyForPickup);
  });

  test('failed ready transition restores the preparing order', () async {
    final repository = _RecordingOrderRepository(
      readyError: const OrderPlacementException('Server rejected transition'),
    );
    final controller = OrderController(repository: repository);
    await controller.loadForAccount('farmer-1');

    await expectLater(
      controller.markReadyForPickup('ORD-1'),
      throwsA(isA<OrderPlacementException>()),
    );

    expect(controller.orders.single.status, PlacedOrderStatus.preparing);
    expect(controller.orderNotifications, isEmpty);
  });

  test('Supabase repository calls the farmer-ready RPC only', () async {
    Uri? requestUri;
    Object? requestBody;
    final httpClient = MockClient((request) async {
      requestUri = request.url;
      requestBody = jsonDecode(request.body);
      return http.Response(
        '',
        204,
        headers: {'content-type': 'application/json'},
        request: request,
      );
    });
    final client = SupabaseClient(
      'https://example.supabase.co',
      'test-publishable-key',
      httpClient: httpClient,
      accessToken: () async => 'test-access-token',
    );
    addTearDown(client.dispose);

    await SupabaseOrderRepository(
      client,
    ).markReadyForPickup(accountId: 'farmer-1', orderId: 'ORD-1');

    expect(requestUri?.path, endsWith('/rpc/mark_current_farmer_order_ready'));
    expect(requestBody, {'seller_order_id': 'ORD-1'});
  });
}

class _RecordingOrderRepository implements OrderRepository {
  _RecordingOrderRepository({this.readyError});

  final Object? readyError;
  final readyOrderIds = <String>[];
  var saveCalls = 0;

  @override
  Future<List<PlacedOrder>> load(String accountId) async => [
    PlacedOrder(
      id: 'ORD-1',
      status: PlacedOrderStatus.preparing,
      placedAt: DateTime(2026),
      deliveryAddress: 'Buyer address',
      phoneNumber: '09123456789',
      items: const [],
    ),
  ];

  @override
  Future<void> markReadyForPickup({
    required String accountId,
    required String orderId,
  }) async {
    readyOrderIds.add(orderId);
    if (readyError case final error?) throw error;
  }

  @override
  Future<void> save(String accountId, Iterable<PlacedOrder> orders) async {
    saveCalls++;
  }

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
}
