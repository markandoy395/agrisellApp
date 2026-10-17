import 'package:agresell_app/core/services/agrisell_supabase.dart';
import 'package:agresell_app/core/services/query_owner.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:agresell_app/features/shared/orders/data/order_local_repository.dart';
import 'package:agresell_app/features/shared/orders/data/order_repository.dart';
import 'package:agresell_app/features/shared/orders/data/supabase_order_repository.dart';
import 'package:agresell_app/features/shared/orders/domain/placed_order.dart';

part 'cached_order_payments.dart';

class CachedOrderRepository
    with _CachedOrderPayments
    implements OrderRepository, FarmerOrderCancellationRepository {
  CachedOrderRepository({OrderLocalRepository? local})
    : _local = local ?? OrderLocalRepository();

  final OrderLocalRepository _local;

  @override
  void _requireOwner(String accountId) {
    if (!AgrisellSupabase.isInitialized) return;
    final client = AgrisellSupabase.client;
    final session = client.auth.currentSession;
    if (session == null || session.isExpired || session.user.isAnonymous) {
      throw const AuthException('Sign in before accessing orders.');
    }
    QueryOwner(client).requireAuthId(accountId);
  }

  bool get _hasRemoteSession =>
      AgrisellSupabase.isInitialized &&
      AgrisellSupabase.client.auth.currentUser != null;

  @override
  Future<List<PlacedOrder>> load(String accountId) async {
    _requireOwner(accountId);
    if (!_hasRemoteSession) return _local.load(accountId);
    QueryOwner(AgrisellSupabase.client).requireAuthId(accountId);

    try {
      final orders = await SupabaseOrderRepository(
        AgrisellSupabase.client,
      ).load(accountId);
      _requireOwner(accountId);
      await _local.save(accountId, orders);
      return orders;
    } on Object {
      _requireOwner(accountId);
      return _local.load(accountId);
    }
  }

  @override
  Future<void> cancelFarmerOrder({
    required String accountId,
    required String orderId,
    required String reason,
  }) async {
    _requireOwner(accountId);
    if (_hasRemoteSession) {
      await SupabaseOrderRepository(AgrisellSupabase.client).cancelFarmerOrder(
        accountId: accountId,
        orderId: orderId,
        reason: reason,
      );
    }
    _requireOwner(accountId);
    await _local.cancelFarmerOrder(
      accountId: accountId,
      orderId: orderId,
      reason: reason,
    );
  }

  @override
  Future<void> save(String accountId, Iterable<PlacedOrder> orders) async {
    _requireOwner(accountId);
    final snapshot = List<PlacedOrder>.of(orders);
    if (_hasRemoteSession) {
      await SupabaseOrderRepository(
        AgrisellSupabase.client,
      ).save(accountId, snapshot);
    }
    _requireOwner(accountId);
    await _local.save(accountId, snapshot);
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
    _requireOwner(accountId);
    if (_hasRemoteSession) {
      await SupabaseOrderRepository(AgrisellSupabase.client).submitFeedback(
        accountId: accountId,
        orderId: orderId,
        productId: productId,
        productRating: productRating,
        productComment: productComment,
        riderRating: riderRating,
        riderComment: riderComment,
      );
    }
    _requireOwner(accountId);
    await _local.submitFeedback(
      accountId: accountId,
      orderId: orderId,
      productId: productId,
      productRating: productRating,
      productComment: productComment,
      riderRating: riderRating,
      riderComment: riderComment,
    );
  }

  @override
  Future<void> createOrders({
    required String accountId,
    required Iterable<PlacedOrder> newOrders,
    required Iterable<PlacedOrder> currentOrders,
  }) async {
    _requireOwner(accountId);
    final additions = List<PlacedOrder>.of(newOrders);
    final snapshot = List<PlacedOrder>.of(currentOrders);
    if (_hasRemoteSession) {
      await SupabaseOrderRepository(AgrisellSupabase.client).createOrders(
        accountId: accountId,
        newOrders: additions,
        currentOrders: snapshot,
      );
    }
    _requireOwner(accountId);
    await _local.save(accountId, snapshot);
  }

  @override
  Future<void> markReadyForPickup({
    required String accountId,
    required String orderId,
  }) async {
    _requireOwner(accountId);
    if (_hasRemoteSession) {
      await SupabaseOrderRepository(
        AgrisellSupabase.client,
      ).markReadyForPickup(accountId: accountId, orderId: orderId);
    }
    _requireOwner(accountId);
    await _local.markReadyForPickup(accountId: accountId, orderId: orderId);
  }
}
