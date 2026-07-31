enum RiderPaymentMethod { prepaid, cashOnDelivery, other }

extension RiderPaymentMethodDetails on RiderPaymentMethod {
  static RiderPaymentMethod fromBackendValue(String value) {
    final normalized = value.trim().toLowerCase();
    if (normalized == 'cod' ||
        normalized == 'cash on delivery' ||
        normalized == 'cash_on_delivery') {
      return RiderPaymentMethod.cashOnDelivery;
    }
    if (normalized == 'gcash' ||
        normalized == 'agrisell wallet' ||
        normalized == 'prepaid') {
      return RiderPaymentMethod.prepaid;
    }
    return RiderPaymentMethod.other;
  }
}

enum CashCollectionStatus { pending, collected, exceptionApproved, remitted }

enum CashCollectionIssue {
  insufficientCash,
  buyerRefusedPayment,
  amountMismatch,
  collectionFailed,
  alternateApprovedMethod,
}

extension CashCollectionIssueDetails on CashCollectionIssue {
  String get label => switch (this) {
    CashCollectionIssue.insufficientCash => 'Buyer has insufficient cash',
    CashCollectionIssue.buyerRefusedPayment => 'Buyer refuses payment',
    CashCollectionIssue.amountMismatch => 'Amount mismatch',
    CashCollectionIssue.collectionFailed => 'Collection failed',
    CashCollectionIssue.alternateApprovedMethod =>
      'Buyer used another approved method',
  };
}

/// Server-owned COD requirement. Riders cannot change the expected total.
class CashOnDeliveryRequirement {
  const CashOnDeliveryRequirement({
    required this.amountToCollect,
    this.currencyCode = 'PHP',
    this.status = CashCollectionStatus.pending,
    this.remittanceRequired = true,
    this.riderCashResponsibility = '',
    this.paymentNotes = '',
    this.authorizedExceptionReference,
  }) : assert(amountToCollect >= 0);

  final double amountToCollect;
  final String currencyCode;
  final CashCollectionStatus status;
  final bool remittanceRequired;
  final String riderCashResponsibility;
  final String paymentNotes;
  final String? authorizedExceptionReference;

  bool get hasAuthorizedException =>
      status == CashCollectionStatus.exceptionApproved &&
      (authorizedExceptionReference?.trim().isNotEmpty ?? false);
}

class CashCollectionSubmission {
  const CashCollectionSubmission({
    required this.amountReceived,
    required this.collectionConfirmed,
    this.issue,
    this.notes,
  }) : assert(amountReceived >= 0);

  final double amountReceived;
  final bool collectionConfirmed;
  final CashCollectionIssue? issue;
  final String? notes;
}

class CashCollectionRecord {
  const CashCollectionRecord({
    required this.amountToCollect,
    required this.amountReceived,
    required this.status,
    required this.recordedAt,
    required this.remittanceRequired,
    this.issue,
    this.notes,
    this.authorizedExceptionReference,
  });

  final double amountToCollect;
  final double amountReceived;
  final CashCollectionStatus status;
  final DateTime recordedAt;
  final bool remittanceRequired;
  final CashCollectionIssue? issue;
  final String? notes;
  final String? authorizedExceptionReference;

  bool get permitsCompletion =>
      status == CashCollectionStatus.collected ||
      status == CashCollectionStatus.exceptionApproved;
}
