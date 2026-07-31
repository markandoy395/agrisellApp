import 'package:flutter_test/flutter_test.dart';

import 'package:agresell_app/features/rider/deliveries/domain/rider_location.dart';
import 'package:agresell_app/features/rider/profile/data/rider_remote_data_source.dart';
import 'package:agresell_app/features/rider/profile/data/rider_repository_impl.dart';
import 'package:agresell_app/features/rider/profile/domain/rider.dart';

void main() {
  test('Rider maps only the final ERD fields', () {
    final rider = Rider.fromJson({
      'rider_id': 'rider-1',
      'logistics_company_id': 'company-1',
      'license_number': 'N01-23-456789',
      'full_name': 'Ana Maria Reyes',
      'vehicle_type': 'motorcycle',
      'vehicle_plate_number': 'ABC 1234',
      'first_name': 'Ana',
      'last_name': 'Reyes',
      'email': 'ana@example.com',
      'contact_number': '09171234567',
      'gps_lat': 8.48,
      'gps_long': 124.65,
      'total_deliveries': 4,
      'employment_status': 'inactive',
      'availability_status': 'offline',
    });

    expect(rider.fullName, 'Ana Maria Reyes');
    expect(rider.licenseNumber, 'N01-23-456789');
    expect(rider.gpsLatitude, 8.48);
    expect(rider.employmentStatus.name, 'inactive');
    expect(rider.toJson()['vehicle_plate_number'], 'ABC 1234');
    expect(rider.toJson(), isNot(contains('service_radius_km')));
  });

  test('repository upserts one current Rider location', () async {
    final remote = _FakeRemote();
    final repository = RiderRepositoryImpl(remote: remote);
    final location = RiderLocation(
      riderId: 'rider-1',
      latitude: 8.48,
      longitude: 124.65,
      accuracyMeters: 8,
      timestamp: DateTime.utc(2026, 7, 16),
    );

    final saved = await repository.upsertRiderLocation(location);

    expect(saved.riderId, 'rider-1');
    expect(remote.locationWrites, 1);
  });

  test('profile update excludes protected Rider columns', () async {
    final remote = _FakeRemote();
    final repository = RiderRepositoryImpl(remote: remote);
    final rider = Rider.fromJson({
      'rider_id': 'rider-1',
      'logistics_company_id': 'company-1',
      'license_number': 'N01-23-456789',
      'full_name': 'Ana Santos',
      'vehicle_type': 'motorcycle',
      'vehicle_plate_number': 'ABC 1234',
      'first_name': 'Ana',
      'last_name': 'Santos',
      'email': 'ana@example.com',
      'contact_number': '09171234567',
    });

    await repository.updateRider(rider);

    expect(remote.riderUpdate, isNot(contains('logistics_company_id')));
    expect(remote.riderUpdate, isNot(contains('email')));
    expect(remote.riderUpdate?['full_name'], 'Ana Santos');
    expect(remote.riderUpdate?['license_number'], 'N01-23-456789');
  });
}

class _FakeRemote extends Fake implements RiderRemoteDataSource {
  int locationWrites = 0;
  Map<String, Object?>? riderUpdate;
  @override
  String get currentAuthId => 'auth-1';

  @override
  Future<RiderLocation> upsertLocation(RiderLocation location) async {
    locationWrites++;
    return RiderLocation.fromDatabaseJson({
      ...location.toDatabaseJson(),
      'location_id': 'location-1',
    });
  }

  @override
  Future<Rider> updateRider(String riderId, Map<String, Object?> values) async {
    riderUpdate = values;
    return Rider.fromJson({...values, 'rider_id': riderId});
  }
}
