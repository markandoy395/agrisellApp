import 'package:supabase_flutter/supabase_flutter.dart';

import 'package:agresell_app/features/shared/orders/data/order_json_codec.dart';
import 'package:agresell_app/features/shared/orders/data/order_repository.dart';
import 'package:agresell_app/features/shared/orders/data/order_snapshot_merger.dart';
import 'package:agresell_app/features/shared/orders/domain/placed_order.dart';

class SupabaseOrderRepository
    implements OrderRepository, FarmerOrderCancellationRepository {
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
    final cancellations = await client.rpc<Object?>(
      'current_account_cancellation_snapshots',
    );
    Object? refunds;
    try {
      refunds = await client.rpc<Object?>('current_account_refund_snapshots');
    } catch (_) {
      // Graceful fallback if database function is pending migration
    }
    Object? disputes;
    try {
      disputes = await client.rpc<Object?>('current_account_dispute_snapshots');
    } catch (_) {
      // Graceful fallback if database function is pending migration
    }
    return OrderJsonCodec.decodeOrders(
      OrderSnapshotMerger.merge(
        orders,
        payments: payments,
        reviews: reviews,
        expirations: expirations,
        cancellations: cancellations,
        refunds: refunds,
        disputes: disputes,
      ),
    );
  }

  @override
  Future<void> cancelFarmerOrder({
    required String accountId,
    required String orderId,
    required String reason,
  }) async {
    try {
      await client.rpc<Object?>(
        'cancel_current_farmer_order',
        params: {
          'p_seller_order_id': orderId,
          'p_cancellation_reason': reason.trim(),
        },
      );
    } on PostgrestException catch (error) {
      throw OrderPlacementException(error.message);
    }
  }

  @override
  Future<void> save(String accountId, Iterable<PlacedOrder> orders) async {
    await _syncOrders(orders);
  }

  @override
  Future<void> submitFeedback({
    required String accountId,
    required String orderId,
    required String productId,
    int? productRating,
    required String productComment,
    int? riderRating,
    String riderComment = '',
  }) async {
    final commodityId = int.tryParse(productId);
    if (commodityId == null) {
      throw const OrderPlacementException('The purchased product is invalid.');
    }
    try {
      await client.rpc<Object?>(
        'submit_current_buyer_feedback',
        params: {
          'p_client_order_id': orderId,
          'p_commodity_id': commodityId,
          'p_product_rating': productRating,
          'p_product_comment': productComment.trim(),
          'p_rider_rating': riderRating,
          'p_rider_comment': riderComment.trim(),
        },
      );
    } on PostgrestException catch (error) {
      throw OrderPlacementException(error.message);
    }
  }

  @override
  Future<void> createOrders({
    required String accountId,
    required Iterable<PlacedOrder> newOrders,
    required Iterable<PlacedOrder> currentOrders,
  }) => _syncOrders(newOrders);

  Future<void> _syncOrders(Iterable<PlacedOrder> orders) async {
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

  @override
  Future<void> reportOrderDispute({
    required String accountId,
    required String orderId,
    required String category,
    required String reason,
    required String requestedResolution,
  }) async {
    try {
      await client.rpc<Object?>(
        'report_current_buyer_order_dispute',
        params: {
          'p_client_order_id': orderId,
          'p_category': category,
          'p_reason': reason.trim(),
          'p_requested_resolution': requestedResolution,
        },
      );
    } on PostgrestException catch (error) {
      throw OrderPlacementException(error.message);
    }
  }
}
