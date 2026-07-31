import 'package:agresell_app/features/rider/dashboard/data/rider_analytics_repository.dart';
import 'package:agresell_app/features/rider/dashboard/domain/rider_analytics_models.dart';
import 'package:agresell_app/features/rider/dashboard/domain/rider_history_models.dart';
import 'package:agresell_app/features/rider/dashboard/domain/rider_rating_models.dart';
import 'package:agresell_app/features/rider/dashboard/presentation/controllers/rider_analytics_controller.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('empty analytics adapter has no seeded rider data', () async {
    final repository = InMemoryRiderAnalyticsRepository();

    final earnings = await repository.fetchEarnings(
      riderId: 'rider-1',
      dateRange: RiderDateRange.forPeriod(
        RiderAnalyticsPeriod.today,
        DateTime(2026, 7, 11),
      ),
    );
    final history = await repository.fetchHistory(riderId: 'rider-1');
    final ratings = await repository.fetchRatings(riderId: 'rider-1');

    expect(earnings.hasData, isFalse);
    expect(history, isEmpty);
    expect(ratings.hasData, isFalse);
  });

  test(
    'history query and ratings submission stay scoped to the rider',
    () async {
      final repository = InMemoryRiderAnalyticsRepository(
        historyByRider: {
          'rider-1': [
            RiderDeliveryHistoryEntry(
              id: 'history-1',
              orderNumber: 'ORD-1',
              completedAt: DateTime(2026, 7, 10),
              pickupAddress: 'Farm pickup',
              deliveryAddress: 'Buyer delivery',
              productName: 'Mangoes',
              quantityDescription: '2 kg',
              deliveryFee: 50,
              status: RiderHistoryStatus.completed,
            ),
          ],
        },
      );

      final history = await repository.fetchHistory(
        riderId: 'rider-1',
        query: const RiderHistoryQuery(status: RiderHistoryStatus.completed),
      );
      await repository.submitRating(
        const RiderRatingSubmission(
          riderId: 'rider-1',
          deliveryId: 'history-1',
          reviewerRole: RiderReviewerRole.buyer,
          rating: 4.5,
        ),
      );

      final ratings = await repository.fetchRatings(riderId: 'rider-1');
      expect(history, hasLength(1));
      expect(ratings.summary.totalRatings, 1);
      expect(ratings.summary.averageRating, 4.5);
    },
  );

  test('controller exposes ready earnings data from its repository', () async {
    final controller = RiderAnalyticsController();
    addTearDown(controller.dispose);

    await controller.loadEarnings(
      riderId: 'rider-1',
      dateRange: RiderDateRange.forPeriod(
        RiderAnalyticsPeriod.week,
        DateTime(2026, 7, 11),
      ),
    );

    expect(controller.earningsState, RiderAnalyticsLoadState.ready);
    expect(controller.earnings.hasData, isFalse);
  });
}
