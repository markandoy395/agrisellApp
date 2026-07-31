import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import 'package:agresell_app/features/rider/deliveries/data/rider_delivery_foundation_repositories.dart';
import 'package:agresell_app/features/rider/deliveries/domain/rider_delivery_state_snapshot.dart';

class SharedPreferencesRiderDeliveryStateStore
    implements RiderDeliveryStateStore {
  SharedPreferencesRiderDeliveryStateStore({this.preferences});

  static const _keyPrefix = 'rider_delivery_foundation_state_v1_';
  final SharedPreferences? preferences;

  @override
  Future<RiderDeliveryStateSnapshot?> load(String riderId) async {
    try {
      final encoded = (await _instance).getString(_keyFor(riderId));
      if (encoded == null) return null;
      return RiderDeliveryStateSnapshot.fromJson(
        Map<String, Object?>.from(jsonDecode(encoded) as Map),
      );
    } catch (_) {
      return null;
    }
  }

  @override
  Future<void> save(String riderId, RiderDeliveryStateSnapshot snapshot) async {
    await (await _instance).setString(
      _keyFor(riderId),
      jsonEncode(snapshot.toJson()),
    );
  }

  @override
  Future<void> clear(String riderId) async {
    await (await _instance).remove(_keyFor(riderId));
  }

  String _keyFor(String riderId) => '$_keyPrefix$riderId';

  Future<SharedPreferences> get _instance async =>
      preferences ?? await SharedPreferences.getInstance();
}
