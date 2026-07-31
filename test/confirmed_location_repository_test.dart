import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:agresell_app/features/shared/location/data/confirmed_location_repository.dart';
import 'package:agresell_app/features/shared/location/domain/confirmed_location.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() => SharedPreferences.setMockInitialValues({}));

  test(
    'confirmed coordinates and metadata survive repository recreation',
    () async {
      final capturedAt = DateTime(2026, 7, 13, 9, 30);
      final location = ConfirmedLocation(
        latitude: 8.4822,
        longitude: 124.6472,
        accuracyMeters: 8.5,
        capturedAt: capturedAt,
        address: 'Farm entrance',
        notes: 'Green roadside gate',
      );

      await ConfirmedLocationRepository().confirm(
        LocationOwnerRole.farmer,
        location,
      );
      final restored = await ConfirmedLocationRepository().load(
        LocationOwnerRole.farmer,
      );

      expect(restored?.latitude, location.latitude);
      expect(restored?.longitude, location.longitude);
      expect(restored?.accuracyMeters, location.accuracyMeters);
      expect(restored?.capturedAt, capturedAt);
      expect(restored?.address, 'Farm entrance');
      expect(restored?.notes, 'Green roadside gate');
    },
  );

  test('failed remote save stays pending and later synchronizes', () async {
    final remote = _RemoteLocation(fails: true);
    final repository = ConfirmedLocationRepository(remote: remote);
    final location = ConfirmedLocation(
      latitude: 8.48,
      longitude: 124.64,
      accuracyMeters: 12,
      capturedAt: DateTime(2026, 7, 13),
    );

    expect(
      await repository.confirm(LocationOwnerRole.buyer, location),
      isFalse,
    );
    remote.fails = false;
    expect(await repository.syncPending(LocationOwnerRole.buyer), isTrue);
    expect(remote.saved.single.latitude, 8.48);
  });
}

class _RemoteLocation implements ConfirmedLocationRemoteDataSource {
  _RemoteLocation({required this.fails});
  bool fails;
  final saved = <ConfirmedLocation>[];

  @override
  Future<void> save(LocationOwnerRole role, ConfirmedLocation location) async {
    if (fails) throw Exception('offline');
    saved.add(location);
  }
}
