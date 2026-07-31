import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import 'package:agresell_app/features/shared/location/domain/confirmed_location.dart';
import 'package:agresell_app/features/shared/location/data/confirmed_location_remote_data_source.dart';
import 'package:agresell_app/features/shared/location/data/supabase_confirmed_location_remote.dart';

export 'package:agresell_app/features/shared/location/data/confirmed_location_remote_data_source.dart';

class ConfirmedLocationRepository {
  factory ConfirmedLocationRepository({
    SharedPreferences? preferences,
    ConfirmedLocationRemoteDataSource? remote,
  }) => ConfirmedLocationRepository._(
    preferences,
    remote ?? SupabaseConfirmedLocationRemoteDataSource.currentOrNull(),
  );

  ConfirmedLocationRepository._(this._preferences, this._remote);

  final SharedPreferences? _preferences;
  final ConfirmedLocationRemoteDataSource? _remote;

  Future<ConfirmedLocation?> load(LocationOwnerRole role) async {
    final preferences = await _instance;
    final value = preferences.getString(_cacheKey(role));
    return value == null ? null : _decode(value);
  }

  Future<bool> confirm(
    LocationOwnerRole role,
    ConfirmedLocation location,
  ) async {
    final encoded = jsonEncode(location.toJson());
    final preferences = await _instance;
    await preferences.setString(_cacheKey(role), encoded);
    final remote = _remote;
    if (remote == null) {
      await preferences.setString(_pendingKey(role), encoded);
      return false;
    }
    try {
      await remote.save(role, location);
      await preferences.remove(_pendingKey(role));
      return true;
    } catch (_) {
      await preferences.setString(_pendingKey(role), encoded);
      return false;
    }
  }

  Future<bool> syncPending(LocationOwnerRole role) async {
    final remote = _remote;
    final preferences = await _instance;
    final encoded = preferences.getString(_pendingKey(role));
    if (remote == null || encoded == null) return encoded == null;
    try {
      await remote.save(role, _decode(encoded));
      await preferences.remove(_pendingKey(role));
      return true;
    } catch (_) {
      return false;
    }
  }

  ConfirmedLocation _decode(String value) {
    final decoded = jsonDecode(value);
    return ConfirmedLocation.fromJson({
      for (final entry in (decoded as Map).entries) '${entry.key}': entry.value,
    });
  }

  String _cacheKey(LocationOwnerRole role) =>
      'confirmed_location_${role.name}_v1';
  String _pendingKey(LocationOwnerRole role) =>
      'pending_location_${role.name}_v1';

  Future<SharedPreferences> get _instance async =>
      _preferences ?? await SharedPreferences.getInstance();
}
