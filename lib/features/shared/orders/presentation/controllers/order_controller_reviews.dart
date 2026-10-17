part of 'order_controller.dart';

extension OrderControllerReviews on OrderController {
  Future<void> _submitFeedback({
    required String orderId,
    String? productId,
    required int rating,
    required String comment,
    int? riderRating,
    String riderComment = '',
    bool reviewProduct = true,
  }) async {
    final generation = _accountGeneration;
    final normalizedComment = comment.trim();
    final feedback = OrderFeedback(
      rating: rating,
      comment: normalizedComment,
      submittedAt: DateTime.now().toUtc(),
    );
    if (reviewProduct && !feedback.isValid) {
      throw ArgumentError(
        'Rating must be 1–5 and feedback at most 500 characters.',
      );
    }

    final index = _orders.indexWhere((order) => order.id == orderId);
    final resolvedProductId =
        productId ??
        (index == -1 || _orders[index].items.length != 1
            ? null
            : _orders[index].items.single.productId);
    final canRateRider =
        index != -1 &&
        _orders[index].status.canLeaveFeedback &&
        _orders[index].deliveryId != null &&
        !_orders[index].riderRated &&
        riderRating != null;
    if (index == -1 ||
        ((!reviewProduct ||
                resolvedProductId == null ||
                !_orders[index].canReviewProduct(resolvedProductId)) &&
            !canRateRider)) {
      throw StateError('This order is not ready for feedback.');
    }

    final previousOrder = _orders[index];
    try {
      await _repository.submitFeedback(
        accountId: _accountId ?? '',
        orderId: orderId,
        productId: resolvedProductId!,
        productRating: reviewProduct ? rating : null,
        productComment: normalizedComment,
        riderRating: riderRating,
        riderComment: riderComment.trim(),
      );
    } on Object {
      rethrow;
    }
    if (_disposed || generation != _accountGeneration) return;
    final items = [...previousOrder.items];
    final itemIndex = items.indexWhere(
      (item) => item.productId == resolvedProductId,
    );
    if (reviewProduct) {
      items[itemIndex] = items[itemIndex].copyWith(feedback: feedback);
    }
    final allProductsRated = items.every((item) => item.feedback != null);
    _orders[index] = previousOrder.copyWith(
      items: items,
      isRated: allProductsRated,
      feedback: allProductsRated && reviewProduct
          ? feedback
          : previousOrder.feedback,
      riderRated: riderRating == null ? previousOrder.riderRated : true,
    );
    _commitChange(persist: false);
  }
}
