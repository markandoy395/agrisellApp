import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'package:agresell_app/features/rider/deliveries/data/rider_delivery_repository.dart';
import 'package:agresell_app/features/rider/deliveries/data/supabase_delivery_data_source.dart';
import 'package:agresell_app/features/rider/deliveries/domain/delivery_completion.dart';
import 'package:agresell_app/features/rider/deliveries/domain/delivery_payment.dart';
import 'package:agresell_app/features/rider/deliveries/domain/delivery_status_update.dart';

void main() {
  test('Supabase completion sends server-verified COD collection', () async {
    Map<String, Object?>? completionPayload;
    var deliveryFetches = 0;
    final httpClient = MockClient((request) async {
      if (request.url.path.endsWith('/rpc/complete_delivery')) {
        completionPayload = Map<String, Object?>.from(
          jsonDecode(request.body) as Map,
        );
        return _response(request, {
          'delivery': {..._delivery, 'delivery_status': 'completed'},
          'history': {
            'status_history_id': 'complete-key',
            'delivery_id': 7,
            'previous_status': 'arrived_at_delivery',
            'new_status': 'completed',
            'changed_at': _created,
            'created_at': _created,
          },
        });
      }
      if (request.url.path.endsWith('/rpc/current_rider_deliveries')) {
        deliveryFetches++;
        return _response(request, [
          {
            ..._delivery,
            'delivery_status': deliveryFetches > 1
                ? 'completed'
                : 'arrived_at_delivery',
          },
        ]);
      }
      return _response(request, {});
    });
    final client = SupabaseClient(
      'https://example.supabase.co',
      'test-publishable-key',
      httpClient: httpClient,
      accessToken: () async => 'test-access-token',
    );
    addTearDown(client.dispose);
    final repository = SupabaseRiderDeliveryRepository(
      SupabaseDeliveryDataSource(client),
    );

    final result = await repository.completeDelivery(
      const DeliveryCompletionCommand(
        deliveryId: '7',
        riderId: 'rider-1',
        idempotencyKey: 'complete-key',
        finalLocation: DeliveryStatusLocation(
          latitude: 8.48,
          longitude: 124.64,
          accuracyMeters: 5,
        ),
        proofReferences: {},
        cashCollection: CashCollectionSubmission(
          amountReceived: 450,
          collectionConfirmed: true,
        ),
      ),
    );

    expect(completionPayload?['p_cash_amount'], 450);
    expect(completionPayload?['p_cash_confirmed'], isTrue);
    expect(completionPayload?['p_previous_status'], 'arrived_at_delivery');
    expect(result.record.cashCollection?.amountReceived, 450);
    expect(
      result.record.cashCollection?.status,
      CashCollectionStatus.collected,
    );
  });
}

http.Response _response(http.Request request, Object value) => http.Response(
  jsonEncode(value),
  200,
  headers: {'content-type': 'application/json'},
  request: request,
);

const _created = '2026-07-29T01:00:00Z';
const _delivery = <String, Object?>{
  'delivery_id': 7,
  'order_id': 9,
  'delivery_status': 'arrived_at_delivery',
  'created_at': _created,
  'pickup_location': 'Carmen Market',
  'dropoff_location': 'Uptown Buyer',
  'payment_method': 'cash_on_delivery',
  'payment_status': 'pending_collection',
  'amount_to_collect': 450,
  'assigned_to_current_rider': true,
};
