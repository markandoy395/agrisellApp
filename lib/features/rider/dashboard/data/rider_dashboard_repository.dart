import 'package:agresell_app/features/rider/dashboard/domain/rider_dashboard_state.dart';
import 'package:agresell_app/features/rider/dashboard/domain/rider_data_source.dart';

abstract interface class RiderDashboardRepository {
  Future<RiderDashboardData> fetchDashboard({required String riderId});
}

/// Temporary adapter used until dashboard aggregation endpoints are available.
/// It intentionally returns empty metrics instead of invented production data.
class TemporaryLocalRiderDashboardRepository
    implements RiderDashboardRepository, RiderDataSourceMetadata {
  const TemporaryLocalRiderDashboardRepository();

  @override
  RiderDataOrigin get dataOrigin => RiderDataOrigin.temporaryLocal;

  @override
  Future<RiderDashboardData> fetchDashboard({required String riderId}) async {
    return RiderDashboardData(
      metrics: const RiderDashboardMetrics(),
      fetchedAt: DateTime.now(),
      dataOrigin: dataOrigin,
      unavailableSections: const <String>[
        'Today metrics',
        'Earnings',
        'Communication counts',
        'Performance',
      ],
    );
  }
}
