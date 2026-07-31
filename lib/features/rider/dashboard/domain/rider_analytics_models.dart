enum RiderAnalyticsPeriod { today, yesterday, week, month, custom }

extension RiderAnalyticsPeriodDetails on RiderAnalyticsPeriod {
  String get label => switch (this) {
    RiderAnalyticsPeriod.today => 'Today',
    RiderAnalyticsPeriod.yesterday => 'Yesterday',
    RiderAnalyticsPeriod.week => 'This week',
    RiderAnalyticsPeriod.month => 'This month',
    RiderAnalyticsPeriod.custom => 'Custom range',
  };
}

/// An inclusive, calendar-date range sent to rider analytics endpoints.
class RiderDateRange {
  RiderDateRange({required this.start, required this.end})
    : assert(!end.isBefore(start));

  final DateTime start;
  final DateTime end;

  factory RiderDateRange.forPeriod(RiderAnalyticsPeriod period, DateTime now) {
    final today = DateTime(now.year, now.month, now.day);
    return switch (period) {
      RiderAnalyticsPeriod.today => RiderDateRange(start: today, end: today),
      RiderAnalyticsPeriod.yesterday => RiderDateRange(
        start: today.subtract(const Duration(days: 1)),
        end: today.subtract(const Duration(days: 1)),
      ),
      RiderAnalyticsPeriod.week => RiderDateRange(
        start: today.subtract(Duration(days: today.weekday - 1)),
        end: today,
      ),
      RiderAnalyticsPeriod.month => RiderDateRange(
        start: DateTime(now.year, now.month),
        end: today,
      ),
      RiderAnalyticsPeriod.custom => RiderDateRange(start: today, end: today),
    };
  }

  factory RiderDateRange.fromDates(DateTime start, DateTime end) {
    return RiderDateRange(
      start: DateTime(start.year, start.month, start.day),
      end: DateTime(end.year, end.month, end.day),
    );
  }
}

enum RiderEarningType {
  deliveryFee,
  waitingFee,
  returnFee,
  incentive,
  bonus,
  deduction,
  penalty,
}

extension RiderEarningTypeDetails on RiderEarningType {
  String get label => switch (this) {
    RiderEarningType.deliveryFee => 'Delivery fee',
    RiderEarningType.waitingFee => 'Waiting fee',
    RiderEarningType.returnFee => 'Return fee',
    RiderEarningType.incentive => 'Incentive',
    RiderEarningType.bonus => 'Bonus',
    RiderEarningType.deduction => 'Deduction',
    RiderEarningType.penalty => 'Penalty',
  };
}

enum RiderPayoutStatus { pending, paid }

extension RiderPayoutStatusDetails on RiderPayoutStatus {
  String get label => this == RiderPayoutStatus.paid ? 'Paid' : 'Pending';
}

class RiderEarningsSummary {
  const RiderEarningsSummary({
    this.deliveryEarnings = 0,
    this.completedDeliveries = 0,
    this.pendingPayments = 0,
    this.paidEarnings = 0,
    this.incentives = 0,
    this.bonuses = 0,
    this.deductions = 0,
    this.waitingFees = 0,
    this.returnFees = 0,
    this.penalties = 0,
  });

  const RiderEarningsSummary.empty() : this();

  final double deliveryEarnings;
  final int completedDeliveries;
  final double pendingPayments;
  final double paidEarnings;
  final double incentives;
  final double bonuses;
  final double deductions;
  final double waitingFees;
  final double returnFees;
  final double penalties;

  double get grossEarnings =>
      deliveryEarnings + waitingFees + returnFees + incentives + bonuses;
  double get netEarnings => grossEarnings - deductions - penalties;
  double get completedDeliveryEarnings => deliveryEarnings;

  bool get isEmpty =>
      completedDeliveries == 0 &&
      deliveryEarnings == 0 &&
      pendingPayments == 0 &&
      paidEarnings == 0 &&
      incentives == 0 &&
      bonuses == 0 &&
      deductions == 0 &&
      waitingFees == 0 &&
      returnFees == 0 &&
      penalties == 0;
}

class RiderEarningEntry {
  const RiderEarningEntry({
    required this.id,
    required this.occurredAt,
    required this.description,
    required this.amount,
    required this.type,
    required this.payoutStatus,
    this.orderNumber,
    this.deliveryId,
    this.estimatedEarning,
    this.finalEarning,
    this.waitingAdjustment = 0,
    this.returnAdjustment = 0,
    this.bonus = 0,
    this.incentive = 0,
    this.deduction = 0,
    this.penalty = 0,
  }) : assert(id != ''),
       assert(amount >= 0);

  final String id;
  final DateTime occurredAt;
  final String description;
  final double amount;
  final RiderEarningType type;
  final RiderPayoutStatus payoutStatus;
  final String? orderNumber;
  final String? deliveryId;
  final double? estimatedEarning;
  final double? finalEarning;
  final double waitingAdjustment;
  final double returnAdjustment;
  final double bonus;
  final double incentive;
  final double deduction;
  final double penalty;

  double get signedAmount =>
      type == RiderEarningType.deduction || type == RiderEarningType.penalty
      ? -amount
      : amount;

  double get netAmount =>
      (finalEarning ?? signedAmount) +
      waitingAdjustment +
      returnAdjustment +
      bonus +
      incentive -
      deduction -
      penalty;
}

class RiderEarningsData {
  const RiderEarningsData({
    required this.summary,
    this.entries = const <RiderEarningEntry>[],
  });

  const RiderEarningsData.empty()
    : summary = const RiderEarningsSummary.empty(),
      entries = const <RiderEarningEntry>[];

  final RiderEarningsSummary summary;
  final List<RiderEarningEntry> entries;

  bool get hasData => !summary.isEmpty || entries.isNotEmpty;
}
