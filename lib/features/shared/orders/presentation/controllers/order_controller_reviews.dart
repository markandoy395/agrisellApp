part of 'order_controller.dart';

extension OrderControllerReviews on OrderController {
  Future<void> submitFeedback({
    required String orderId,
    required int rating,
    required String comment,
  }) async {
    final normalizedComment = comment.trim();
    final feedback = OrderFeedback(
      rating: rating,
      comment: normalizedComment,
      submittedAt: DateTime.now().toUtc(),
    );
    if (!feedback.isValid) {
      throw ArgumentError(
        'Rating must be 1–5 and feedback at most 500 characters.',
      );
    }

    final index = _orders.indexWhere((order) => order.id == orderId);
    if (index == -1 || !_orders[index].canLeaveFeedback) {
      throw StateError('This order is not ready for feedback.');
    }

    final previousOrder = _orders[index];
    _orders[index] = previousOrder.copyWith(isRated: true, feedback: feedback);
    _commitChange(persist: false);
    try {
      await _persistOrders();
    } on Object {
      _orders[index] = previousOrder;
      _commitChange(persist: false);
      rethrow;
    }
  }
}
