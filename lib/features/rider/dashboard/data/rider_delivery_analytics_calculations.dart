import '../../deliveries/domain/delivery_completion.dart';
import '../../deliveries/domain/delivery_earning.dart';
import '../../deliveries/domain/delivery_status.dart';
import '../domain/rider_analytics_models.dart';

abstract final class RiderDeliveryAnalyticsCalculations {
  static RiderEarningEntry earningEntry(DeliveryCompletionRecord record) {
    final earning =
        record.earning ??
        RiderDeliveryEarningCalculator.calculate(
          estimatedEarning: record.request.deliveryFee,
          fees: record.request.feeBreakdown,
        );
    return RiderEarningEntry(
      id: 'earning-${record.request.id}',
      deliveryId: record.request.id,
      orderNumber: record.request.orderNumber,
      occurredAt: record.completedAt,
      description: record.request.productName,
      amount: earning.finalEarning,
      type: RiderEarningType.deliveryFee,
      payoutStatus: earning.payoutStatus == DeliveryPayoutStatus.paid
          ? RiderPayoutStatus.paid
          : RiderPayoutStatus.pending,
      estimatedEarning: earning.estimatedEarning,
      finalEarning: earning.finalEarning,
      waitingAdjustment: earning.waitingAdjustment,
      returnAdjustment: earning.returnAdjustment,
      bonus: earning.bonus,
      incentive: earning.incentive,
      deduction: earning.deduction,
      penalty: earning.penalty,
    );
  }

  static double onTimePickupRate(List<DeliveryCompletionRecord> records) =>
      rate(records, (record) {
        final pickedUp = record.events
            .where((event) => event.newStatus == DeliveryStatus.productPickedUp)
            .firstOrNull;
        return pickedUp != null &&
            !pickedUp.timestamp.isAfter(record.request.pickupDeadline);
      });

  static double onTimeDeliveryRate(List<DeliveryCompletionRecord> records) =>
      rate(records, (record) {
        final deadline = record.request.deliveryDeadline;
        return deadline != null && !record.completedAt.isAfter(deadline);
      });

  static double averageWaitingMinutes(List<DeliveryCompletionRecord> records) {
    final durations = <Duration>[];
    for (final record in records) {
      for (var index = 0; index < record.events.length - 1; index++) {
        final status = record.events[index].newStatus;
        if (status == DeliveryStatus.waitingForProduct ||
            status == DeliveryStatus.waitingForBuyer) {
          durations.add(
            record.events[index + 1].timestamp.difference(
              record.events[index].timestamp,
            ),
          );
        }
      }
    }
    if (durations.isEmpty) return 0;
    return durations.fold<int>(0, (sum, item) => sum + item.inSeconds) /
        durations.length /
        60;
  }

  static double rate(
    List<DeliveryCompletionRecord> records,
    bool Function(DeliveryCompletionRecord) matches,
  ) => records.isEmpty
      ? 0
      : records.where(matches).length / records.length * 100;

  static bool inDateRange(DateTime value, RiderDateRange range) =>
      !value.isBefore(range.start) &&
      value.isBefore(range.end.add(const Duration(days: 1)));
}
