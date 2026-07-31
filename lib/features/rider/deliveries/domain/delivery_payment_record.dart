import 'delivery_json.dart';

enum DeliveryPaymentEarningStatus {
  pending,
  calculated,
  approved,
  cancelled;

  static DeliveryPaymentEarningStatus fromBackendValue(Object? value) =>
      values.firstWhere((item) => item.name == value, orElse: () => pending);
}

enum DeliveryPaymentPayoutStatus {
  unpaid,
  processing,
  paid,
  failed;

  static DeliveryPaymentPayoutStatus fromBackendValue(Object? value) =>
      values.firstWhere((item) => item.name == value, orElse: () => unpaid);
}

class DeliveryPayment {
  const DeliveryPayment({
    required this.paymentId,
    required this.deliveryId,
    required this.deliveryFee,
    required this.additionalFee,
    required this.deductionAmount,
    required this.finalEarning,
    required this.earningStatus,
    required this.payoutStatus,
    required this.createdAt,
    required this.updatedAt,
    this.paidAt,
  });

  factory DeliveryPayment.fromJson(Map<String, Object?> json) =>
      DeliveryPayment(
        paymentId: deliveryString(
          json['delivery_payment_id'] ?? json['payment_id'],
        ),
        deliveryId: deliveryString(json['delivery_id']),
        deliveryFee: deliveryDouble(json['delivery_fee']) ?? 0,
        additionalFee: deliveryDouble(json['additional_fee']) ?? 0,
        deductionAmount: deliveryDouble(json['deduction_amount']) ?? 0,
        finalEarning: deliveryDouble(json['final_earning']) ?? 0,
        earningStatus: DeliveryPaymentEarningStatus.fromBackendValue(
          json['earning_status'],
        ),
        payoutStatus: DeliveryPaymentPayoutStatus.fromBackendValue(
          json['payout_status'],
        ),
        paidAt: deliveryDateTime(json['paid_at']),
        createdAt:
            deliveryDateTime(json['created_at']) ??
            DateTime.fromMillisecondsSinceEpoch(0),
        updatedAt:
            deliveryDateTime(json['updated_at']) ??
            DateTime.fromMillisecondsSinceEpoch(0),
      );

  final String paymentId;
  final String deliveryId;
  final double deliveryFee;
  final double additionalFee;
  final double deductionAmount;
  final double finalEarning;
  final DeliveryPaymentEarningStatus earningStatus;
  final DeliveryPaymentPayoutStatus payoutStatus;
  final DateTime? paidAt;
  final DateTime createdAt;
  final DateTime updatedAt;

  Map<String, Object?> toJson() => {
    if (paymentId.isNotEmpty) 'delivery_payment_id': paymentId,
    'delivery_id': deliveryId,
    'delivery_fee': deliveryFee,
    'additional_fee': additionalFee,
    'deduction_amount': deductionAmount,
    'final_earning': finalEarning,
    'earning_status': earningStatus.name,
    'payout_status': payoutStatus.name,
    'paid_at': paidAt?.toUtc().toIso8601String(),
  };

  DeliveryPayment copyWith({
    double? additionalFee,
    double? deductionAmount,
    double? finalEarning,
  }) => DeliveryPayment(
    paymentId: paymentId,
    deliveryId: deliveryId,
    deliveryFee: deliveryFee,
    additionalFee: additionalFee ?? this.additionalFee,
    deductionAmount: deductionAmount ?? this.deductionAmount,
    finalEarning: finalEarning ?? this.finalEarning,
    earningStatus: earningStatus,
    payoutStatus: payoutStatus,
    paidAt: paidAt,
    createdAt: createdAt,
    updatedAt: updatedAt,
  );

  @override
  bool operator ==(Object other) =>
      other is DeliveryPayment && other.paymentId == paymentId;
  @override
  int get hashCode => paymentId.hashCode;
}
