import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'package:agresell_app/features/shared/orders/data/order_repository.dart';
import 'package:agresell_app/features/shared/orders/data/supabase_order_repository.dart';

void main() {
  final cases =
      <
        ({
          String rpc,
          Map<String, Object?> payload,
          Future<void> Function(SupabaseOrderRepository) run,
        })
      >[
        (
          rpc: 'cancel_current_farmer_order',
          payload: {
            'p_seller_order_id': 'order',
            'p_cancellation_reason': 'reason',
          },
          run: (repository) => repository.cancelFarmerOrder(
            accountId: 'account',
            orderId: 'order',
            reason: ' reason ',
          ),
        ),
        (
          rpc: 'submit_current_buyer_feedback',
          payload: {
            'p_client_order_id': 'order',
            'p_commodity_id': 12,
            'p_product_rating': 5,
            'p_product_comment': 'fresh',
            'p_rider_rating': 4,
            'p_rider_comment': 'quick',
          },
          run: (repository) => repository.submitFeedback(
            accountId: 'account',
            orderId: 'order',
            productId: '12',
            productRating: 5,
            productComment: ' fresh ',
            riderRating: 4,
            riderComment: ' quick ',
          ),
        ),
        (
          rpc: 'mark_current_farmer_order_ready',
          payload: {'seller_order_id': 'order'},
          run: (repository) => repository.markReadyForPickup(
            accountId: 'account',
            orderId: 'order',
          ),
        ),
        (
          rpc: 'review_current_order_gcash_payment',
          payload: {'client_order_id': 'order', 'approved': true},
          run: (repository) => repository.reviewGcashPayment(
            accountId: 'account',
            orderId: 'order',
            approved: true,
          ),
        ),
        (
          rpc: 'resubmit_current_order_gcash_reference',
          payload: {'client_order_id': 'order', 'transaction_reference': '123'},
          run: (repository) => repository.resubmitGcashReference(
            accountId: 'account',
            orderId: 'order',
            reference: ' 123 ',
          ),
        ),
        (
          rpc: 'record_current_order_gcash_refund',
          payload: {'client_order_id': 'order', 'refund_reference': '456'},
          run: (repository) => repository.recordGcashRefund(
            accountId: 'account',
            orderId: 'order',
            reference: ' 456 ',
          ),
        ),
        (
          rpc: 'report_current_buyer_order_dispute',
          payload: {
            'p_client_order_id': 'order',
            'p_category': 'quality',
            'p_reason': 'damaged',
            'p_requested_resolution': 'refund',
          },
          run: (repository) => repository.reportOrderDispute(
            accountId: 'account',
            orderId: 'order',
            category: 'quality',
            reason: ' damaged ',
            requestedResolution: 'refund',
          ),
        ),
      ];

  for (final mutation in cases) {
    test('${mutation.rpc} preserves RPC name and payload', () async {
      final client = _client((request) async {
        expect(request.url.path, '/rest/v1/rpc/${mutation.rpc}');
        expect(jsonDecode(request.body), mutation.payload);
        return _response(request, '{}');
      });
      addTearDown(client.dispose);
      await mutation.run(SupabaseOrderRepository(client));
    });

    test('${mutation.rpc} translates database errors', () async {
      final client = _client(
        (request) async => _response(
          request,
          '{"message":"Rejected","code":"42501"}',
          status: 400,
        ),
      );
      addTearDown(client.dispose);
      await expectLater(
        mutation.run(SupabaseOrderRepository(client)),
        throwsA(
          isA<OrderPlacementException>().having(
            (error) => error.message,
            'message',
            'Rejected',
          ),
        ),
      );
    });
  }

  test(
    'snapshot loading keeps call order and optional migration fallbacks',
    () async {
      final calls = <String>[];
      final client = _client((request) async {
        final rpc = request.url.pathSegments.last;
        calls.add(rpc);
        final optional = rpc.contains('refund') || rpc.contains('dispute');
        return _response(
          request,
          optional ? '{"message":"Missing function","code":"42883"}' : '[]',
          status: optional ? 400 : 200,
        );
      });
      addTearDown(client.dispose);
      expect(await SupabaseOrderRepository(client).load('account'), isEmpty);
      expect(calls, [
        'current_account_orders',
        'current_account_payment_snapshots',
        'current_account_review_snapshots',
        'current_account_expiration_snapshots',
        'current_account_cancellation_snapshots',
        'current_account_refund_snapshots',
        'current_account_dispute_snapshots',
      ]);
    },
  );
}

SupabaseClient _client(MockClientHandler handler) => SupabaseClient(
  'https://example.supabase.co',
  'test-publishable-key',
  httpClient: MockClient(handler),
  accessToken: () async => 'test-access-token',
);

http.Response _response(
  http.Request request,
  String body, {
  int status = 200,
}) => http.Response(
  body,
  status,
  headers: {'content-type': 'application/json'},
  request: request,
);
