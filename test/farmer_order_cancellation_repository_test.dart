import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'package:agresell_app/features/shared/orders/data/supabase_order_repository.dart';

void main() {
  test('Supabase repository uses the farmer cancellation RPC', () async {
    Uri? requestUri;
    Object? requestBody;
    final client = SupabaseClient(
      'https://example.supabase.co',
      'test-publishable-key',
      httpClient: MockClient((request) async {
        requestUri = request.url;
        requestBody = jsonDecode(request.body);
        return http.Response(
          '{}',
          200,
          headers: {'content-type': 'application/json'},
          request: request,
        );
      }),
      accessToken: () async => 'test-access-token',
    );
    addTearDown(client.dispose);

    await SupabaseOrderRepository(client).cancelFarmerOrder(
      accountId: 'farmer-1',
      orderId: 'ORDER-1',
      reason: 'Out of stock',
    );

    expect(requestUri?.path, endsWith('/rpc/cancel_current_farmer_order'));
    expect(requestBody, {
      'p_seller_order_id': 'ORDER-1',
      'p_cancellation_reason': 'Out of stock',
    });
  });
}
