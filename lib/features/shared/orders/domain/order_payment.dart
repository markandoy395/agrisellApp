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
    this.receiptImageReference = '',
    this.receiptImageName = '',
    this.refundAmount,
    this.refundedAt,
    this.refundReason = '',
    this.refundStatus = '',
  });

  const OrderPayment.cashOnDelivery()
    : method = OrderPaymentMethod.cashOnDelivery,
      status = OrderPaymentStatus.pendingCollection,
      transactionReference = '',
      refundReference = '',
      receiptImageReference = '',
      receiptImageName = '',
      refundAmount = null,
      refundedAt = null,
      refundReason = '',
      refundStatus = '';

  factory OrderPayment.gcash(
    String reference, {
    String receiptImageReference = '',
    String receiptImageName = '',
  }) => OrderPayment(
    method: OrderPaymentMethod.gcash,
    status: OrderPaymentStatus.submittedForVerification,
    transactionReference: normalizeGcashReference(reference),
    refundReference: '',
    receiptImageReference: receiptImageReference.trim(),
    receiptImageName: receiptImageName.trim(),
    refundAmount: null,
    refundedAt: null,
    refundReason: '',
    refundStatus: '',
  );

  final OrderPaymentMethod method;
  final OrderPaymentStatus status;
  final String transactionReference;
  final String refundReference;
  final String receiptImageReference;
  final String receiptImageName;
  final double? refundAmount;
  final DateTime? refundedAt;
  final String refundReason;
  final String refundStatus;

  static final _gcashReferenceSeparators = RegExp(r'[\s_-]+');

  static String normalizeGcashReference(String reference) =>
      reference.trim().replaceAll(_gcashReferenceSeparators, '');

  static bool isValidGcashReference(String reference) =>
      RegExp(r'^\d{13}$').hasMatch(normalizeGcashReference(reference));

  bool get allowsOrderAcceptance =>
      method == OrderPaymentMethod.cashOnDelivery ||
      status == OrderPaymentStatus.verified;

  bool get needsFarmerReview =>
      method == OrderPaymentMethod.gcash &&
      (status == OrderPaymentStatus.submittedForVerification ||
          status == OrderPaymentStatus.paymentReviewRequired);
  bool get hasReceiptImage => receiptImageReference.trim().isNotEmpty;
  bool get hasRefund =>
      refundReference.isNotEmpty ||
      status == OrderPaymentStatus.refundRequired ||
      status == OrderPaymentStatus.refunded;
  bool get isRefundCompleted =>
      status == OrderPaymentStatus.refunded ||
      refundStatus.toLowerCase() == 'completed';

  OrderPayment copyWith({
    OrderPaymentStatus? status,
    String? transactionReference,
    String? refundReference,
    String? receiptImageReference,
    String? receiptImageName,
    double? refundAmount,
    DateTime? refundedAt,
    String? refundReason,
    String? refundStatus,
  }) => OrderPayment(
    method: method,
    status: status ?? this.status,
    transactionReference: transactionReference ?? this.transactionReference,
    refundReference: refundReference ?? this.refundReference,
    receiptImageReference: receiptImageReference ?? this.receiptImageReference,
    receiptImageName: receiptImageName ?? this.receiptImageName,
    refundAmount: refundAmount ?? this.refundAmount,
    refundedAt: refundedAt ?? this.refundedAt,
    refundReason: refundReason ?? this.refundReason,
    refundStatus: refundStatus ?? this.refundStatus,
  );
}
