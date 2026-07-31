import 'package:supabase_flutter/supabase_flutter.dart';

import 'package:agresell_app/features/shared/orders/data/order_json_codec.dart';
import 'package:agresell_app/features/shared/orders/data/order_repository.dart';
import 'package:agresell_app/features/shared/orders/data/order_snapshot_merger.dart';
import 'package:agresell_app/features/shared/orders/domain/placed_order.dart';

class SupabaseOrderRepository implements OrderRepository {
  const SupabaseOrderRepository(this.client);

  final SupabaseClient client;

  @override
  Future<List<PlacedOrder>> load(String accountId) async {
    final orders = await client.rpc<Object?>('current_account_orders');
    final payments = await client.rpc<Object?>(
      'current_account_payment_snapshots',
    );
    final reviews = await client.rpc<Object?>(
      'current_account_review_snapshots',
    );
    final expirations = await client.rpc<Object?>(
      'current_account_expiration_snapshots',
    );
    return OrderJsonCodec.decodeOrders(
      OrderSnapshotMerger.merge(
        orders,
        payments: payments,
        reviews: reviews,
        expirations: expirations,
      ),
    );
  }

  @override
  Future<void> save(String accountId, Iterable<PlacedOrder> orders) async {
    final payload = OrderJsonCodec.encodeOrders(orders);
    final orderPayload = payload
        .map((order) => {...order, 'isRated': false})
        .toList(growable: false);
    try {
      await client.rpc<void>(
        'sync_current_account_orders',
        params: {'order_payload': orderPayload},
      );
    } on PostgrestException catch (error) {
      const actionableCodes = {'22023', '40001', '42501'};
      throw OrderPlacementException(
        actionableCodes.contains(error.code)
            ? error.message
            : 'The order could not be saved. Please try again.',
      );
    }
    await client.rpc<void>(
      'sync_current_buyer_review_snapshots',
      params: {'order_payload': payload},
    );
  }

  @override
  Future<void> markReadyForPickup({
    required String accountId,
    required String orderId,
  }) async {
    try {
      await client.rpc<void>(
        'mark_current_farmer_order_ready',
        params: {'seller_order_id': orderId},
      );
    } on PostgrestException catch (error) {
      throw OrderPlacementException(error.message);
    }
  }

  @override
  Future<void> reviewGcashPayment({
    required String accountId,
    required String orderId,
    required bool approved,
  }) async {
    try {
      await client.rpc<void>(
        'review_current_order_gcash_payment',
        params: {'client_order_id': orderId, 'approved': approved},
      );
    } on PostgrestException catch (error) {
      throw OrderPlacementException(error.message);
    }
  }

  @override
  Future<void> resubmitGcashReference({
    required String accountId,
    required String orderId,
    required String reference,
  }) async {
    try {
      await client.rpc<void>(
        'resubmit_current_order_gcash_reference',
        params: {
          'client_order_id': orderId,
          'transaction_reference': reference.trim(),
        },
      );
    } on PostgrestException catch (error) {
      throw OrderPlacementException(error.message);
    }
  }

  @override
  Future<void> recordGcashRefund({
    required String accountId,
    required String orderId,
    required String reference,
  }) async {
    try {
      await client.rpc<void>(
        'record_current_order_gcash_refund',
        params: {
          'client_order_id': orderId,
          'refund_reference': reference.trim(),
        },
      );
    } on PostgrestException catch (error) {
      throw OrderPlacementException(error.message);
    }
  }
}
