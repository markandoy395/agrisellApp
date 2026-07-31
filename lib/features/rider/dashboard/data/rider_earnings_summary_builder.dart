import '../domain/rider_analytics_models.dart';

RiderEarningsSummary summarizeRiderEarnings(
  Iterable<RiderEarningEntry> entries,
) {
  var delivery = 0.0;
  var waiting = 0.0;
  var returns = 0.0;
  var incentives = 0.0;
  var bonuses = 0.0;
  var deductions = 0.0;
  var penalties = 0.0;
  var pending = 0.0;
  var paid = 0.0;
  final deliveries = <String>{};
  for (final entry in entries) {
    delivery +=
        entry.finalEarning ??
        (entry.type == RiderEarningType.deliveryFee ? entry.amount : 0);
    waiting +=
        entry.waitingAdjustment +
        (entry.type == RiderEarningType.waitingFee ? entry.amount : 0);
    returns +=
        entry.returnAdjustment +
        (entry.type == RiderEarningType.returnFee ? entry.amount : 0);
    incentives +=
        entry.incentive +
        (entry.type == RiderEarningType.incentive ? entry.amount : 0);
    bonuses +=
        entry.bonus + (entry.type == RiderEarningType.bonus ? entry.amount : 0);
    deductions +=
        entry.deduction +
        (entry.type == RiderEarningType.deduction ? entry.amount : 0);
    penalties +=
        entry.penalty +
        (entry.type == RiderEarningType.penalty ? entry.amount : 0);
    if (entry.payoutStatus == RiderPayoutStatus.paid) {
      paid += entry.netAmount;
    } else {
      pending += entry.netAmount;
    }
    if (entry.deliveryId != null) deliveries.add(entry.deliveryId!);
  }
  return RiderEarningsSummary(
    deliveryEarnings: delivery,
    completedDeliveries: deliveries.length,
    pendingPayments: pending,
    paidEarnings: paid,
    incentives: incentives,
    bonuses: bonuses,
    deductions: deductions,
    waitingFees: waiting,
    returnFees: returns,
    penalties: penalties,
  );
}
