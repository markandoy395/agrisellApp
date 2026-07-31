import 'package:flutter_test/flutter_test.dart';

import 'package:agresell_app/features/rider/dashboard/data/rider_delivery_analytics_repository.dart';
import 'package:agresell_app/features/rider/dashboard/domain/rider_analytics_models.dart';
import 'package:agresell_app/features/rider/deliveries/domain/rider_delivery_search.dart';
import 'package:agresell_app/features/rider/deliveries/presentation/controllers/rider_delivery_controller.dart';

import 'support/rider_completion_fixture.dart';
import 'support/rider_finance_phase12_support.dart';
import 'support/rider_test_models.dart';

void main() {
  test(
    'successful Rider journey reaches finance and performance records',
    () async {
      final repository = codRepository(readyForAcceptance: true);
      final controller = RiderDeliveryController(repository: repository)
        ..updateProfile(verifiedRiderProfile())
        ..setOnline(true)
        ..updateRequestEnvironment(
          state: RiderRequestAccessState.eligible,
          location: const RiderDeliverySearch(
            latitude: 8.48,
            longitude: 124.65,
          ),
          accuracyMeters: 5,
        );
      addTearDown(controller.dispose);
      await controller.load(riderId: 'rider-a');

      final accepted = await controller.accept(
        requestId: 'delivery-1',
        riderId: 'rider-a',
      );
      expect(
        accepted.isSuccess,
        isTrue,
        reason: '${accepted.failure}: ${accepted.message}',
      );
      expect(controller.hasActiveDelivery, isTrue);

      await reachDeliveryConfirmation(repository);
      await controller.refreshActiveDelivery();
      final completed = await controller.completeDelivery(
        command: codCommand(amount: 500),
      );
      expect(completed.isSuccess, isTrue);
      expect(controller.hasActiveDelivery, isFalse);

      final analytics = RiderDeliveryAnalyticsRepository(
        completionRecords: () => controller.completionHistory,
      );
      final earnings = await analytics.fetchEarnings(
        riderId: 'rider-a',
        dateRange: RiderDateRange.forPeriod(
          RiderAnalyticsPeriod.today,
          DateTime.now(),
        ),
      );
      final ratings = await analytics.fetchRatings(riderId: 'rider-a');

      expect(earnings.summary.netEarnings, 119);
      expect(earnings.entries.single.deliveryId, 'delivery-1');
      expect(ratings.summary.completedDeliveries, 1);
      expect(ratings.summary.completionRate, 100);
    },
  );
}
