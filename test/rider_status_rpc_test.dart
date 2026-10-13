import 'dart:convert';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:agresell_app/features/rider/deliveries/data/supabase_delivery_data_source.dart';
import 'package:agresell_app/features/rider/deliveries/domain/delivery_status.dart';

void main() {
  test(
    'rider status uses assigned-rider RPC with bound data and idempotency key',
    () async {
      late http.Request sent;
      const hostile = "literal %_*' ; delete from public.deliveries --";
      final client = SupabaseClient(
        'https://example.supabase.co',
        'test-key',
        accessToken: () async => 'test-token',
        httpClient: MockClient((request) async {
          sent = request;
          return http.Response(
            jsonEncode({
              'history': {
                'status_history_id': 'key1',
                'delivery_id': 75,
                'previous_status': 'accepted',
                'new_status': 'going_to_pickup',
                'remarks': hostile,
                'changed_at': '2026-10-13T05:00:00Z',
                'created_at': '2026-10-13T05:00:00Z',
              },
            }),
            200,
            headers: {'content-type': 'application/json'},
            request: request,
          );
        }),
      );
      addTearDown(client.dispose);
      final history = await SupabaseDeliveryDataSource(client)
          .updateDeliveryStatus(
            deliveryId: '75',
            previousStatus: DeliveryStatus.accepted,
            newStatus: DeliveryStatus.goingToPickup,
            idempotencyKey: 'key1',
            remarks: hostile,
          );
      expect(
        sent.url.path,
        endsWith('/rpc/update_current_rider_delivery_status'),
      );
      expect(jsonDecode(sent.body), containsPair('p_remarks', hostile));
      expect(jsonDecode(sent.body), containsPair('p_idempotency_key', 'key1'));
      expect(history.newStatus, DeliveryStatus.goingToPickup);
    },
  );
}
