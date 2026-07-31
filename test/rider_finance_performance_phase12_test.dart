import 'package:flutter_test/flutter_test.dart';

import 'package:agresell_app/features/rider/dashboard/data/rider_analytics_repository.dart';
import 'package:agresell_app/features/rider/dashboard/data/rider_delivery_analytics_repository.dart';
import 'package:agresell_app/features/rider/dashboard/domain/rider_analytics_models.dart';
import 'package:agresell_app/features/rider/dashboard/domain/rider_rating_models.dart';
import 'package:agresell_app/features/rider/deliveries/data/rider_delivery_repository.dart';
import 'package:agresell_app/features/rider/deliveries/domain/delivery_earning.dart';
import 'package:agresell_app/features/rider/deliveries/domain/delivery_errors.dart';
import 'package:agresell_app/features/rider/deliveries/domain/delivery_payment.dart';
import 'package:agresell_app/features/rider/deliveries/domain/delivery_request_metadata.dart';

import 'support/rider_completion_fixture.dart';
import 'support/rider_finance_phase12_support.dart';

void main() {
  test('domain fee service preserves every configured fee component', () {
    const fees = DeliveryFeeBreakdown(
      baseFee: 50,
      pickupDistanceFee: 10,
      deliveryDistanceFee: 20,
      productWeightFee: 5,
      vehicleAdjustment: 3,
      urgencyFee: 2,
      perishableProductFee: 4,
      waitingFee: 6,
      returnFee: 7,
      additionalStopFee: 1,
      incentive: 8,
      bonus: 9,
      deduction: 4,
      penalty: 2,
    );
    final earning = RiderDeliveryEarningCalculator.calculate(
      estimatedEarning: 119,
      fees: fees,
    );

    expect(fees.components, hasLength(14));
    expect(fees.total, 119);
    expect(earning.finalEarning, 95);
    expect(earning.netEarning, 119);
  });

  test('COD completion requires the exact authoritative amount', () async {
    final repository = codRepository();
    await reachDeliveryConfirmation(repository);

    await expectLater(
      repository.completeDelivery(completionCommand()),
      throwsA(
        isA<DeliveryDomainException>().having(
          (error) => error.code,
          'code',
          DeliveryErrorCode.invalidPayment,
        ),
      ),
    );
    await expectLater(
      repository.completeDelivery(
        codCommand(amount: 499, issue: CashCollectionIssue.amountMismatch),
      ),
      throwsA(isA<DeliveryDomainException>()),
    );
    expect(
      repository.cashCollectionIssueFor('delivery-1')?.amountReceived,
      499,
    );

    final result = await repository.completeDelivery(
      codCommand(amount: 500, key: 'cod-exact'),
    );
    expect(result.record.cashCollection?.permitsCompletion, isTrue);
    expect(result.record.cashCollection?.amountToCollect, 500);
  });

  test('server-authorized COD exception permits completion', () async {
    final repository = codRepository(exceptionApproved: true);
    await reachDeliveryConfirmation(repository);

    final result = await repository.completeDelivery(
      completionCommand(key: 'approved-exception'),
    );

    expect(
      result.record.cashCollection?.status,
      CashCollectionStatus.exceptionApproved,
    );
  });

  test('earnings are date-filtered and linked to completion history', () async {
    final repository = codRepository();
    await reachDeliveryConfirmation(repository);
    final completion = await repository.completeDelivery(
      codCommand(amount: 500),
    );
    final analytics = RiderDeliveryAnalyticsRepository(
      completionRecords: () => [completion.record],
    );
    final today = RiderDateRange.forPeriod(
      RiderAnalyticsPeriod.today,
      DateTime.now(),
    );

    final earnings = await analytics.fetchEarnings(
      riderId: 'rider-a',
      dateRange: today,
    );
    final history = await analytics.fetchHistory(riderId: 'rider-a');

    expect(earnings.entries.single.deliveryId, 'delivery-1');
    expect(earnings.summary.completedDeliveries, 1);
    expect(earnings.summary.netEarnings, 119);
    expect(history.single.earning?.netEarning, 119);
    expect(history.single.cashCollection?.amountReceived, 500);
  });

  test('yesterday filter excludes today and includes yesterday', () async {
    final now = DateTime(2026, 7, 15, 12);
    final repository = InMemoryRiderAnalyticsRepository(
      earningsByRider: {
        'rider-a': RiderEarningsData(
          summary: const RiderEarningsSummary(),
          entries: [
            _entry('today', now),
            _entry('yesterday', now.subtract(const Duration(days: 1))),
          ],
        ),
      },
    );

    final data = await repository.fetchEarnings(
      riderId: 'rider-a',
      dateRange: RiderDateRange.forPeriod(RiderAnalyticsPeriod.yesterday, now),
    );

    expect(data.entries.single.id, 'yesterday');
  });

  test('the same reviewing user cannot rate a delivery twice', () async {
    final repository = codRepository();
    await reachDeliveryConfirmation(repository);
    final completion = await repository.completeDelivery(
      codCommand(amount: 500),
    );
    final analytics = RiderDeliveryAnalyticsRepository(
      completionRecords: () => [completion.record],
    );
    const rating = RiderRatingSubmission(
      riderId: 'rider-a',
      deliveryId: 'delivery-1',
      reviewerRole: RiderReviewerRole.buyer,
      reviewerId: 'buyer-1',
      rating: 5,
    );

    await analytics.submitRating(rating);
    await expectLater(analytics.submitRating(rating), throwsStateError);
    final data = await analytics.fetchRatings(riderId: 'rider-a');
    expect(data.summary.totalRatings, 1);
    expect(data.summary.completedDeliveries, 1);
    expect(data.summary.completionRate, 100);
  });
}

RiderEarningEntry _entry(String id, DateTime occurredAt) => RiderEarningEntry(
  id: id,
  deliveryId: 'delivery-$id',
  occurredAt: occurredAt,
  description: id,
  amount: 50,
  type: RiderEarningType.deliveryFee,
  payoutStatus: RiderPayoutStatus.pending,
);
