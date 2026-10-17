part of 'cached_order_repository.dart';

mixin _CachedOrderPayments implements OrderRepository {
  OrderLocalRepository get _local;
  bool get _hasRemoteSession;
  void _requireOwner(String accountId);

  @override
  Future<void> reviewGcashPayment({
    required String accountId,
    required String orderId,
    required bool approved,
  }) async {
    _requireOwner(accountId);
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
    _requireOwner(accountId);
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
    _requireOwner(accountId);
    if (!_hasRemoteSession) return;
    await SupabaseOrderRepository(AgrisellSupabase.client).recordGcashRefund(
      accountId: accountId,
      orderId: orderId,
      reference: reference,
    );
  }

  @override
  Future<void> reportOrderDispute({
    required String accountId,
    required String orderId,
    required String category,
    required String reason,
    required String requestedResolution,
  }) async {
    _requireOwner(accountId);
    if (_hasRemoteSession) {
      await SupabaseOrderRepository(AgrisellSupabase.client).reportOrderDispute(
        accountId: accountId,
        orderId: orderId,
        category: category,
        reason: reason,
        requestedResolution: requestedResolution,
      );
    }
    _requireOwner(accountId);
    await _local.reportOrderDispute(
      accountId: accountId,
      orderId: orderId,
      category: category,
      reason: reason,
      requestedResolution: requestedResolution,
    );
  }
}
