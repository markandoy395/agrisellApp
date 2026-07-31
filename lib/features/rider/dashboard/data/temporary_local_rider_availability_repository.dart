import 'package:shared_preferences/shared_preferences.dart';

import 'package:agresell_app/features/rider/dashboard/domain/rider_availability.dart';
import 'package:agresell_app/features/rider/dashboard/domain/rider_data_source.dart';
import 'package:agresell_app/features/rider/deliveries/data/rider_delivery_foundation_repositories.dart';

/// Temporary authoritative-status adapter used until a Rider API is present.
/// Its separate key simulates server state without mixing it into UI state.
class TemporaryLocalRiderAvailabilityRepository
    implements RiderAvailabilityRepository, RiderDataSourceMetadata {
  TemporaryLocalRiderAvailabilityRepository({this.preferences});

  static const _keyPrefix = 'temporary_server_rider_availability_v1_';
  final SharedPreferences? preferences;

  @override
  RiderDataOrigin get dataOrigin => RiderDataOrigin.temporaryLocal;

  @override
  Future<RiderAvailability> loadAvailability(String riderId) async {
    final value = (await _instance).getString(_keyFor(riderId));
    if (value == null) return RiderAvailability.offline;
    return RiderAvailability.fromBackendValue(value);
  }

  @override
  Future<void> saveAvailability(
    String riderId,
    RiderAvailability availability,
  ) async {
    await (await _instance).setString(
      _keyFor(riderId),
      availability.backendValue,
    );
  }

  String _keyFor(String riderId) => '$_keyPrefix$riderId';

  Future<SharedPreferences> get _instance async =>
      preferences ?? await SharedPreferences.getInstance();
}
