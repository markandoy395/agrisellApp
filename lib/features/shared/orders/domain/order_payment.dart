enum OrderPaymentMethod { cashOnDelivery, gcash }

extension OrderPaymentMethodDetails on OrderPaymentMethod {
  String get label => switch (this) {
    OrderPaymentMethod.cashOnDelivery => 'Cash on Delivery',
    OrderPaymentMethod.gcash => 'GCash',
  };

  String get databaseValue => switch (this) {
    OrderPaymentMethod.cashOnDelivery => 'cash_on_delivery',
    OrderPaymentMethod.gcash => 'gcash',
  };

  static OrderPaymentMethod fromValue(Object? value) {
    final normalized = value?.toString().trim().toLowerCase() ?? '';
    return normalized == 'gcash'
        ? OrderPaymentMethod.gcash
        : OrderPaymentMethod.cashOnDelivery;
  }
}

enum OrderPaymentStatus {
  pendingCollection,
  submittedForVerification,
  paymentReviewRequired,
  verified,
  rejected,
  cancelled,
  refundRequired,
  refunded,
}

extension OrderPaymentStatusDetails on OrderPaymentStatus {
  String get label => switch (this) {
    OrderPaymentStatus.pendingCollection => 'Pay on delivery',
    OrderPaymentStatus.submittedForVerification => 'Verification pending',
    OrderPaymentStatus.paymentReviewRequired => 'Payment review required',
    OrderPaymentStatus.verified => 'Payment verified',
    OrderPaymentStatus.rejected => 'Reference needs attention',
    OrderPaymentStatus.cancelled => 'Payment cancelled',
    OrderPaymentStatus.refundRequired => 'Refund required',
    OrderPaymentStatus.refunded => 'Refund completed',
  };

  String get databaseValue => switch (this) {
    OrderPaymentStatus.pendingCollection => 'pending_collection',
    OrderPaymentStatus.submittedForVerification => 'submitted_for_verification',
    OrderPaymentStatus.paymentReviewRequired => 'payment_review_required',
    OrderPaymentStatus.verified => 'verified',
    OrderPaymentStatus.rejected => 'rejected',
    OrderPaymentStatus.cancelled => 'cancelled',
    OrderPaymentStatus.refundRequired => 'refund_required',
    OrderPaymentStatus.refunded => 'refunded',
  };

  static OrderPaymentStatus fromValue(Object? value) {
    final normalized = value?.toString().trim().toLowerCase() ?? '';
    return switch (normalized) {
      'submittedforverification' || 'submitted_for_verification' =>
        OrderPaymentStatus.submittedForVerification,
      'paymentreviewrequired' ||
      'payment_review_required' => OrderPaymentStatus.paymentReviewRequired,
      'verified' || 'paid' => OrderPaymentStatus.verified,
      'rejected' => OrderPaymentStatus.rejected,
      'cancelled' => OrderPaymentStatus.cancelled,
      'refundrequired' ||
      'refund_required' => OrderPaymentStatus.refundRequired,
      'refunded' => OrderPaymentStatus.refunded,
      _ => OrderPaymentStatus.pendingCollection,
    };
  }
}

class OrderPayment {
  const OrderPayment({
    required this.method,
    required this.status,
    this.transactionReference = '',
    this.refundReference = '',
  });

  const OrderPayment.cashOnDelivery()
    : method = OrderPaymentMethod.cashOnDelivery,
      status = OrderPaymentStatus.pendingCollection,
      transactionReference = '',
      refundReference = '';

  factory OrderPayment.gcash(String reference) => OrderPayment(
    method: OrderPaymentMethod.gcash,
    status: OrderPaymentStatus.submittedForVerification,
    transactionReference: reference.trim(),
    refundReference: '',
  );

  final OrderPaymentMethod method;
  final OrderPaymentStatus status;
  final String transactionReference;
  final String refundReference;

  bool get allowsOrderAcceptance =>
      method == OrderPaymentMethod.cashOnDelivery ||
      status == OrderPaymentStatus.verified;

  bool get needsFarmerReview =>
      method == OrderPaymentMethod.gcash &&
      (status == OrderPaymentStatus.submittedForVerification ||
          status == OrderPaymentStatus.paymentReviewRequired);

  OrderPayment copyWith({
    OrderPaymentStatus? status,
    String? transactionReference,
    String? refundReference,
  }) => OrderPayment(
    method: method,
    status: status ?? this.status,
    transactionReference: transactionReference ?? this.transactionReference,
    refundReference: refundReference ?? this.refundReference,
  );
}
