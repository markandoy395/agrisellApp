enum FarmerPayoutStatus { approved, paid, failed, pending }

extension FarmerPayoutStatusDetails on FarmerPayoutStatus {
  String get label => switch (this) {
        FarmerPayoutStatus.paid => 'Paid',
        FarmerPayoutStatus.approved => 'Approved',
        FarmerPayoutStatus.failed => 'Failed',
        FarmerPayoutStatus.pending => 'Pending',
      };

  static FarmerPayoutStatus fromValue(Object? value) {
    final normalized = value?.toString().trim().toLowerCase() ?? '';
    return switch (normalized) {
      'paid' => FarmerPayoutStatus.paid,
      'approved' => FarmerPayoutStatus.approved,
      'failed' => FarmerPayoutStatus.failed,
      _ => FarmerPayoutStatus.pending,
    };
  }
}

class FarmerPayout {
  const FarmerPayout({
    required this.payoutId,
    required this.paymentId,
    required this.orderId,
    required this.clientOrderId,
    required this.amount,
    required this.status,
    this.reference = '',
    this.approvedAt,
    this.paidAt,
    this.failureReason = '',
    this.orderTotal = 0,
    this.buyerName = 'Marketplace Buyer',
    this.createdAt,
  });

  factory FarmerPayout.fromJson(Map<String, Object?> json) {
    final payoutId = json['payoutId']?.toString() ?? '0';
    final paymentId = json['paymentId']?.toString() ?? '0';
    final orderId = json['orderId']?.toString() ?? '';
    final clientOrderId = json['clientOrderId']?.toString() ?? '';
    final amount = (json['amount'] as num?)?.toDouble() ?? 0.0;
    final status = FarmerPayoutStatusDetails.fromValue(json['payoutStatus']);
    final reference = json['payoutReference'] as String? ?? '';
    final approvedAt = json['approvedAt'] != null
        ? DateTime.tryParse(json['approvedAt'] as String)
        : null;
    final paidAt = json['paidAt'] != null
        ? DateTime.tryParse(json['paidAt'] as String)
        : null;
    final failureReason = json['failureReason'] as String? ?? '';
    final orderTotal = (json['orderTotal'] as num?)?.toDouble() ?? amount;
    final buyerName = json['buyerName'] as String? ?? 'Marketplace Buyer';
    final createdAt = json['createdAt'] != null
        ? DateTime.tryParse(json['createdAt'] as String)
        : null;

    return FarmerPayout(
      payoutId: payoutId,
      paymentId: paymentId,
      orderId: orderId,
      clientOrderId: clientOrderId,
      amount: amount,
      status: status,
      reference: reference,
      approvedAt: approvedAt,
      paidAt: paidAt,
      failureReason: failureReason,
      orderTotal: orderTotal,
      buyerName: buyerName,
      createdAt: createdAt,
    );
  }

  final String payoutId;
  final String paymentId;
  final String orderId;
  final String clientOrderId;
  final double amount;
  final FarmerPayoutStatus status;
  final String reference;
  final DateTime? approvedAt;
  final DateTime? paidAt;
  final String failureReason;
  final double orderTotal;
  final String buyerName;
  final DateTime? createdAt;

  bool get isPaid => status == FarmerPayoutStatus.paid;
  bool get isApproved => status == FarmerPayoutStatus.approved;
  bool get isFailed => status == FarmerPayoutStatus.failed;
}

class FarmerPayoutSummary {
  const FarmerPayoutSummary({
    this.totalPaidOut = 0.0,
    this.pendingPayouts = 0.0,
    this.paidCount = 0,
    this.pendingCount = 0,
  });

  final double totalPaidOut;
  final double pendingPayouts;
  final int paidCount;
  final int pendingCount;

  factory FarmerPayoutSummary.fromPayouts(List<FarmerPayout> payouts) {
    var totalPaid = 0.0;
    var pendingTotal = 0.0;
    var paidCount = 0;
    var pendingCount = 0;

    for (final payout in payouts) {
      if (payout.isPaid) {
        totalPaid += payout.amount;
        paidCount++;
      } else if (payout.isApproved || payout.status == FarmerPayoutStatus.pending) {
        pendingTotal += payout.amount;
        pendingCount++;
      }
    }

    return FarmerPayoutSummary(
      totalPaidOut: totalPaid,
      pendingPayouts: pendingTotal,
      paidCount: paidCount,
      pendingCount: pendingCount,
    );
  }
}
