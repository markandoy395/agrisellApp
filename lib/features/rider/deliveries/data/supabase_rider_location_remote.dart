import 'package:agresell_app/features/rider/deliveries/data/rider_location_outbox.dart';
import 'package:agresell_app/features/rider/deliveries/domain/rider_location.dart';
import 'package:agresell_app/features/rider/profile/data/rider_repository.dart';
import 'package:agresell_app/features/rider/profile/data/rider_repository_impl.dart';

class SupabaseRiderLocationRemoteDataSource
    implements RiderLocationRemoteDataSource {
  SupabaseRiderLocationRemoteDataSource({RiderRepository? repository})
    : _repository = repository ?? RiderRepositoryImpl();

  final RiderRepository _repository;

  @override
  Future<void> send(RiderLocationUpdate update) async {
    final riderId = update.riderId;
    if (riderId == null || riderId.isEmpty) {
      throw StateError('A Rider ID is required for location sync.');
    }
    await _repository.upsertRiderLocation(
      RiderLocation(
        riderId: riderId,
        latitude: update.latitude,
        longitude: update.longitude,
        accuracyMeters: update.accuracyMeters,
        speedMetersPerSecond: update.speedMetersPerSecond,
        headingDegrees: update.headingDegrees,
        timestamp: update.capturedAt,
      ),
    );
  }
}
