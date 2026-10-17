import 'package:supabase_flutter/supabase_flutter.dart';

import 'package:agresell_app/features/shared/orders/data/order_json_codec.dart';
import 'package:agresell_app/features/shared/orders/data/order_snapshot_merger.dart';
import 'package:agresell_app/features/shared/orders/domain/placed_order.dart';

Future<List<PlacedOrder>> loadSupabaseOrderSnapshots(
  SupabaseClient client,
) async {
  try {
    final bundle = await client.rpc<Object?>('current_account_order_bundle');
    if (bundle is! Map) throw const FormatException('Invalid order snapshot');
    return OrderJsonCodec.decodeOrders(
      OrderSnapshotMerger.merge(
        bundle['orders'],
        payments: bundle['payments'],
        reviews: bundle['reviews'],
        expirations: bundle['expirations'],
        cancellations: bundle['cancellations'],
        refunds: bundle['refunds'],
        disputes: bundle['disputes'],
      ),
    );
  } on PostgrestException catch (error) {
    // Older deployments retain the owner-scoped legacy reads only when missing.
    if (error.code != 'PGRST202' && error.code != '42883') rethrow;
  }
  final orders = await client.rpc<Object?>('current_account_orders');
  final payments = await client.rpc<Object?>(
    'current_account_payment_snapshots',
  );
  final reviews = await client.rpc<Object?>('current_account_review_snapshots');
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
