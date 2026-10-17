part of 'order_controller.dart';

extension OrderControllerActions on OrderController {
  Future<T> _runOrderAction<T>(Object key, Future<T> Function() action) {
    final account = _accountId;
    if (AgrisellSupabase.isInitialized && account == null) {
      return Future<T>.error(
        StateError('Your account is still loading. Please retry.'),
      );
    }
    final generation = _accountGeneration;
    return _operations.run(
      (account, generation, key),
      () => _operations.serialize(('orders', account), () async {
        try {
          await _pendingPersistence;
        } on Object {
          // A failed older write must not block an explicit recovery action.
        }
        if (_disposed || generation != _accountGeneration) {
          throw StateError(
            'The account changed. Please retry after signing in.',
          );
        }
        return action();
      }),
    );
  }

  Future<void> acceptOrder(String orderId) =>
      _runOrderAction((orderId, 'accept'), () => _acceptOrder(orderId));

  Future<void> markReadyForPickup(String orderId) =>
      _runOrderAction((orderId, 'ready'), () => _markReadyForPickup(orderId));

  Future<void> recordGcashRefund({
    required String orderId,
    required String reference,
  }) => _runOrderAction((
    orderId,
    'refund',
    reference,
  ), () => _recordGcashRefund(orderId: orderId, reference: reference));

  Future<void> resubmitGcashReference({
    required String orderId,
    required String reference,
  }) => _runOrderAction((
    orderId,
    'reference',
    reference,
  ), () => _resubmitGcashReference(orderId: orderId, reference: reference));

  Future<void> reviewGcashPayment({
    required String orderId,
    required bool approved,
  }) => _runOrderAction((
    orderId,
    'review',
    approved,
  ), () => _reviewGcashPayment(orderId: orderId, approved: approved));

  Future<void> reportOrderDispute({
    required String orderId,
    required OrderDisputeCategory category,
    required String reason,
    required OrderDisputeResolution requestedResolution,
  }) => _runOrderAction(
    (orderId, 'dispute'),
    () => _reportOrderDispute(
      orderId: orderId,
      category: category,
      reason: reason,
      requestedResolution: requestedResolution,
    ),
  );

  Future<void> submitFeedback({
    required String orderId,
    String? productId,
    required int rating,
    required String comment,
    int? riderRating,
    String riderComment = '',
    bool reviewProduct = true,
  }) => _runOrderAction(
    (orderId, 'feedback', productId),
    () => _submitFeedback(
      orderId: orderId,
      productId: productId,
      rating: rating,
      comment: comment,
      riderRating: riderRating,
      riderComment: riderComment,
      reviewProduct: reviewProduct,
    ),
  );
}
