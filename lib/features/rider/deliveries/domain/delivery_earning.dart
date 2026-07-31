import 'delivery_request_metadata.dart';

enum DeliveryEarningStatus { pending, finalized }

enum DeliveryPayoutStatus { pending, paid }

/// Backend/domain-calculated earning snapshot saved with a completion.
class DeliveryEarningBreakdown {
  const DeliveryEarningBreakdown({
    required this.estimatedEarning,
    required this.finalEarning,
    this.waitingAdjustment = 0,
    this.returnAdjustment = 0,
    this.bonus = 0,
    this.incentive = 0,
    this.deduction = 0,
    this.penalty = 0,
    this.currencyCode = 'PHP',
    this.earningStatus = DeliveryEarningStatus.pending,
    this.payoutStatus = DeliveryPayoutStatus.pending,
  });

  final double estimatedEarning;
  final double finalEarning;
  final double waitingAdjustment;
  final double returnAdjustment;
  final double bonus;
  final double incentive;
  final double deduction;
  final double penalty;
  final String currencyCode;
  final DeliveryEarningStatus earningStatus;
  final DeliveryPayoutStatus payoutStatus;

  double get netEarning =>
      finalEarning +
      waitingAdjustment +
      returnAdjustment +
      bonus +
      incentive -
      deduction -
      penalty;
}

/// Reference domain calculator. A remote implementation returns the same
/// shape from its server-side fee service.
class RiderDeliveryEarningCalculator {
  const RiderDeliveryEarningCalculator._();

  static DeliveryEarningBreakdown calculate({
    required double estimatedEarning,
    DeliveryFeeBreakdown? fees,
  }) {
    if (fees == null) {
      return DeliveryEarningBreakdown(
        estimatedEarning: estimatedEarning,
        finalEarning: estimatedEarning,
      );
    }
    final core =
        fees.baseFee +
        fees.pickupDistanceFee +
        fees.deliveryDistanceFee +
        fees.productWeightFee +
        fees.vehicleAdjustment +
        fees.urgencyFee +
        fees.perishableProductFee +
        fees.additionalStopFee +
        fees.otherAdjustment;
    return DeliveryEarningBreakdown(
      estimatedEarning: estimatedEarning,
      finalEarning: core,
      waitingAdjustment: fees.waitingFee,
      returnAdjustment: fees.returnFee,
      bonus: fees.bonus,
      incentive: fees.incentive,
      deduction: fees.deduction,
      penalty: fees.penalty,
      currencyCode: fees.currencyCode,
    );
  }
}
