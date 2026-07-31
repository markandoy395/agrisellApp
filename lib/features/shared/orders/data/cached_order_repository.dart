import 'package:agresell_app/core/services/agrisell_supabase.dart';
import 'package:agresell_app/features/shared/orders/data/order_local_repository.dart';
import 'package:agresell_app/features/shared/orders/data/order_repository.dart';
import 'package:agresell_app/features/shared/orders/data/supabase_order_repository.dart';
import 'package:agresell_app/features/shared/orders/domain/placed_order.dart';

class CachedOrderRepository implements OrderRepository {
  CachedOrderRepository({OrderLocalRepository? local})
    : _local = local ?? OrderLocalRepository();

  final OrderLocalRepository _local;

  bool get _hasRemoteSession =>
      AgrisellSupabase.isInitialized &&
      AgrisellSupabase.client.auth.currentUser != null;

  @override
  Future<List<PlacedOrder>> load(String accountId) async {
    if (!_hasRemoteSession) return _local.load(accountId);

    try {
      final orders = await SupabaseOrderRepository(
        AgrisellSupabase.client,
      ).load(accountId);
      await _local.save(accountId, orders);
      return orders;
    } on Object {
      return _local.load(accountId);
    }
  }

  @override
  Future<void> save(String accountId, Iterable<PlacedOrder> orders) async {
    final snapshot = List<PlacedOrder>.of(orders);
    if (_hasRemoteSession) {
      await SupabaseOrderRepository(
        AgrisellSupabase.client,
      ).save(accountId, snapshot);
    }
    await _local.save(accountId, snapshot);
  }

  @override
  Future<void> markReadyForPickup({
    required String accountId,
    required String orderId,
  }) async {
    if (_hasRemoteSession) {
      await SupabaseOrderRepository(
        AgrisellSupabase.client,
      ).markReadyForPickup(accountId: accountId, orderId: orderId);
    }
    await _local.markReadyForPickup(accountId: accountId, orderId: orderId);
  }

  @override
  Future<void> reviewGcashPayment({
    required String accountId,
    required String orderId,
    required bool approved,
  }) async {
    if (!_hasRemoteSession) return;
    await SupabaseOrderRepository(AgrisellSupabase.client).reviewGcashPayment(
      accountId: accountId,
      orderId: orderId,
      approved: approved,
    );
  }

  @override
  Future<void> resubmitGcashReference({
    required String accountId,
    required String orderId,
    required String reference,
  }) async {
    if (!_hasRemoteSession) return;
    await SupabaseOrderRepository(
      AgrisellSupabase.client,
    ).resubmitGcashReference(
      accountId: accountId,
      orderId: orderId,
      reference: reference,
    );
  }

  @override
  Future<void> recordGcashRefund({
    required String accountId,
    required String orderId,
    required String reference,
  }) async {
    if (!_hasRemoteSession) return;
    await SupabaseOrderRepository(AgrisellSupabase.client).recordGcashRefund(
      accountId: accountId,
      orderId: orderId,
      reference: reference,
    );
  }
}
