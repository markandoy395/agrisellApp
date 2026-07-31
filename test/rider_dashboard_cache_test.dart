import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:agresell_app/features/rider/dashboard/data/rider_dashboard_cache.dart';
import 'package:agresell_app/features/rider/dashboard/domain/rider_dashboard_state.dart';
import 'package:agresell_app/features/rider/dashboard/domain/rider_data_source.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('non-sensitive dashboard metrics survive cache recreation', () async {
    SharedPreferences.setMockInitialValues({});
    final preferences = await SharedPreferences.getInstance();
    final cache = SharedPreferencesRiderDashboardCache(
      preferences: preferences,
    );
    final data = RiderDashboardData(
      metrics: const RiderDashboardMetrics(
        todayCompletedDeliveries: 3,
        todayEstimatedEarnings: 240,
        unreadMessageCount: 2,
        unreadNotificationCount: 1,
        pendingEarnings: 100,
        averageRating: 4.8,
        completedDeliveryCount: 20,
        onTimeDeliveryRate: 95,
        cancellationRate: 1,
      ),
      fetchedAt: DateTime(2026, 7, 13, 9),
      dataOrigin: RiderDataOrigin.backend,
      unavailableSections: const ['One section'],
    );

    await cache.save('rider-a', data);
    final restored = await cache.load('rider-a');

    expect(restored?.metrics.todayCompletedDeliveries, 3);
    expect(restored?.metrics.todayEstimatedEarnings, 240);
    expect(restored?.metrics.averageRating, 4.8);
    expect(restored?.unavailableSections, ['One section']);
    expect(restored?.fetchedAt, DateTime(2026, 7, 13, 9));
  });
}
