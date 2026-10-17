import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:agresell_app/features/shared/location/data/confirmed_location_repository.dart';
import 'package:agresell_app/features/shared/location/domain/confirmed_location.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  setUp(() => SharedPreferences.setMockInitialValues({}));

  test(
    'Pending locations stay with their owner across account switches',
    () async {
      var account = 'account-a';
      final offline = _Remote(offline: true);
      final first = ConfirmedLocationRepository(
        remote: offline,
        accountId: () => account,
      );
      final location = _location();
      expect(await first.confirm(LocationOwnerRole.buyer, location), isFalse);
      account = 'account-b';
      final online = _Remote();
      final second = ConfirmedLocationRepository(
        remote: online,
        accountId: () => account,
      );
      expect(await first.load(LocationOwnerRole.buyer), isNull);
      expect(await first.syncPending(LocationOwnerRole.buyer), isFalse);
      expect(await second.load(LocationOwnerRole.buyer), isNull);
      expect(await second.syncPending(LocationOwnerRole.buyer), isTrue);
      expect(online.saved, isEmpty);
      account = 'account-a';
      final restored = ConfirmedLocationRepository(
        remote: online,
        accountId: () => account,
      );
      expect(
        (await restored.load(LocationOwnerRole.buyer))!.address,
        location.address,
      );
      expect(await restored.syncPending(LocationOwnerRole.buyer), isTrue);
      expect(online.saved.single.address, location.address);
    },
  );

  test(
    'Signed-out and legacy unowned locations are never loaded or synced',
    () async {
      SharedPreferences.setMockInitialValues({
        'confirmed_location_buyer_v1': 'unowned',
        'pending_location_buyer_v1': 'unowned',
      });
      final remote = _Remote();
      final signedOut = ConfirmedLocationRepository(
        remote: remote,
        accountId: () => null,
      );
      expect(await signedOut.load(LocationOwnerRole.buyer), isNull);
      expect(
        await signedOut.confirm(LocationOwnerRole.buyer, _location()),
        isFalse,
      );
      expect(await signedOut.syncPending(LocationOwnerRole.buyer), isFalse);
      final owned = ConfirmedLocationRepository(
        remote: remote,
        accountId: () => 'account-a',
      );
      expect(await owned.load(LocationOwnerRole.buyer), isNull);
      expect(remote.saved, isEmpty);
      final preferences = await SharedPreferences.getInstance();
      expect(preferences.containsKey('pending_location_buyer_v1'), isFalse);
    },
  );
}

ConfirmedLocation _location() => ConfirmedLocation(
  latitude: 8.48,
  longitude: 124.65,
  accuracyMeters: 8,
  capturedAt: DateTime.utc(2026, 10, 17),
  address: 'Private address',
);

class _Remote implements ConfirmedLocationRemoteDataSource {
  _Remote({this.offline = false});
  final bool offline;
  final saved = <ConfirmedLocation>[];
  @override
  Future<void> save(LocationOwnerRole role, ConfirmedLocation location) async {
    if (offline) throw Exception('offline');
    saved.add(location);
  }
}
