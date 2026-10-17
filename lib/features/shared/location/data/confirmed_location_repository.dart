import 'dart:convert';
import 'package:agresell_app/core/services/agrisell_supabase.dart';

import 'package:shared_preferences/shared_preferences.dart';

import 'package:agresell_app/features/shared/location/domain/confirmed_location.dart';
import 'package:agresell_app/features/shared/location/data/confirmed_location_remote_data_source.dart';
import 'package:agresell_app/features/shared/location/data/supabase_confirmed_location_remote.dart';

export 'package:agresell_app/features/shared/location/data/confirmed_location_remote_data_source.dart';

class ConfirmedLocationRepository {
  factory ConfirmedLocationRepository({
    SharedPreferences? preferences,
    ConfirmedLocationRemoteDataSource? remote,
    String? Function()? accountId,
  }) => ConfirmedLocationRepository._(
    preferences,
    remote ?? SupabaseConfirmedLocationRemoteDataSource.currentOrNull(),
    accountId ?? _authenticatedAccountId,
  );

  ConfirmedLocationRepository._(
    this._preferences,
    this._remote,
    this._accountId,
  ) : _owner = _accountId();

  final SharedPreferences? _preferences;
  final ConfirmedLocationRemoteDataSource? _remote;
  final String? Function() _accountId;
  final String? _owner;
  bool get _isCurrent => _owner != null && _accountId() == _owner;

  Future<ConfirmedLocation?> load(LocationOwnerRole role) async {
    if (!_isCurrent) return null;
    final preferences = await _instance;
    if (!_isCurrent) return null;
    final value = preferences.getString(_cacheKey(role));
    return value == null ? null : _decode(value);
  }

  Future<bool> confirm(
    LocationOwnerRole role,
    ConfirmedLocation location,
  ) async {
    if (!_isCurrent) return false;
    final encoded = jsonEncode(location.toJson());
    final preferences = await _instance;
    if (!_isCurrent) return false;
    await preferences.setString(_cacheKey(role), encoded);
    final remote = _remote;
    if (remote == null) {
      await preferences.setString(_pendingKey(role), encoded);
      return false;
    }
    try {
      if (!_isCurrent) return false;
      await remote.save(role, location);
      if (!_isCurrent) return false;
      await preferences.remove(_pendingKey(role));
      return true;
    } catch (_) {
      await preferences.setString(_pendingKey(role), encoded);
      return false;
    }
  }

  Future<bool> syncPending(LocationOwnerRole role) async {
    if (!_isCurrent) return false;
    final remote = _remote;
    final preferences = await _instance;
    if (!_isCurrent) return false;
    final encoded = preferences.getString(_pendingKey(role));
    if (remote == null || encoded == null) return encoded == null;
    try {
      await remote.save(role, _decode(encoded));
      if (!_isCurrent) return false;
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
      'confirmed_location_${_owner}_${role.name}_v2';
  String _pendingKey(LocationOwnerRole role) =>
      'pending_location_${_owner}_${role.name}_v2';

  Future<SharedPreferences> get _instance async {
    final preferences = _preferences ?? await SharedPreferences.getInstance();
    // Legacy values have no provable owner and must never be adopted.
    for (final role in LocationOwnerRole.values) {
      await preferences.remove('confirmed_location_${role.name}_v1');
      await preferences.remove('pending_location_${role.name}_v1');
    }
    return preferences;
  }
}

String? _authenticatedAccountId() {
  if (!AgrisellSupabase.isInitialized) return null;
  final session = AgrisellSupabase.client.auth.currentSession;
  if (session == null || session.isExpired || session.user.isAnonymous)
    return null;
  return session.user.id;
}
