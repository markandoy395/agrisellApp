import 'dart:async';
import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../domain/rider_location.dart';

class RiderLocationUpdate extends RiderLocation {
  const RiderLocationUpdate({
    required super.latitude,
    required super.longitude,
    required super.accuracyMeters,
    required this.capturedAt,
    super.altitudeMeters,
    super.speedMetersPerSecond,
    super.headingDegrees,
    super.isMocked,
    super.isApproximate,
    this.deliveryId,
    super.riderId,
  }) : super(timestamp: capturedAt);

  final DateTime capturedAt;
  final String? deliveryId;

  @override
  Map<String, Object> toJson() => {
    'latitude': latitude,
    'longitude': longitude,
    'accuracyMeters': accuracyMeters,
    'altitudeMeters': ?altitudeMeters,
    'speedMetersPerSecond': speedMetersPerSecond,
    'headingDegrees': headingDegrees,
    'isMocked': isMocked,
    'isApproximate': isApproximate,
    'deliveryId': ?deliveryId,
    'riderId': ?riderId,
    'capturedAt': capturedAt.toUtc().toIso8601String(),
  };

  factory RiderLocationUpdate.fromJson(Map<String, Object?> json) =>
      RiderLocationUpdate(
        latitude: (json['latitude'] as num).toDouble(),
        longitude: (json['longitude'] as num).toDouble(),
        accuracyMeters: (json['accuracyMeters'] as num).toDouble(),
        altitudeMeters: (json['altitudeMeters'] as num?)?.toDouble(),
        speedMetersPerSecond:
            (json['speedMetersPerSecond'] as num?)?.toDouble() ?? 0,
        headingDegrees: (json['headingDegrees'] as num?)?.toDouble() ?? 0,
        isMocked: json['isMocked'] as bool? ?? false,
        isApproximate: json['isApproximate'] as bool? ?? false,
        deliveryId: json['deliveryId'] as String?,
        riderId: json['riderId'] as String?,
        capturedAt: DateTime.parse(json['capturedAt'] as String).toLocal(),
      );

  String get deduplicationKey =>
      '$riderId|$deliveryId|${capturedAt.toUtc().toIso8601String()}|'
      '$latitude|$longitude';
}

abstract interface class RiderLocationRemoteDataSource {
  Future<void> send(RiderLocationUpdate update);
}

class RiderLocationOutbox {
  factory RiderLocationOutbox({
    SharedPreferences? preferences,
    RiderLocationRemoteDataSource? remote,
    int maxPendingPoints = 200,
  }) => RiderLocationOutbox._(preferences, remote, maxPendingPoints);

  RiderLocationOutbox._(this._preferences, this._remote, this.maxPendingPoints);

  static const _pendingKey = 'pending_rider_locations_v2';
  static const _legacyKey = 'pending_rider_location_v1';
  final SharedPreferences? _preferences;
  final RiderLocationRemoteDataSource? _remote;
  final int maxPendingPoints;
  Future<void> _serial = Future.value();

  Future<void> record(RiderLocationUpdate update) => _exclusive(() async {
    final pending = await _load();
    if (!pending.any(
      (item) => item.deduplicationKey == update.deduplicationKey,
    )) {
      pending.add(update);
      pending.sort((a, b) => a.capturedAt.compareTo(b.capturedAt));
      await _save(_compact(pending));
    }
    await _syncOnce();
  });

  Future<bool> sync() {
    final result = Completer<bool>();
    _serial = _serial.then((_) async {
      try {
        result.complete(await _syncOnce());
      } on Object catch (error, stackTrace) {
        result.completeError(error, stackTrace);
      }
    });
    return result.future;
  }

  Future<List<RiderLocationUpdate>> loadPending() =>
      _exclusive(() async => List.unmodifiable(await _load()));

  Future<bool> _syncOnce() async {
    final remote = _remote;
    final pending = await _load();
    if (pending.isEmpty) return true;
    if (remote == null) return false;
    for (var index = 0; index < pending.length; index++) {
      try {
        await remote.send(pending[index]);
        await _save(pending.sublist(index + 1));
      } on Exception {
        return false;
      }
    }
    return true;
  }

  Future<void> clearPending() => _exclusive(() async => _save(const []));

  List<RiderLocationUpdate> _compact(List<RiderLocationUpdate> pending) {
    if (pending.length <= maxPendingPoints) return pending;
    final result = <RiderLocationUpdate>[];
    final stride = (pending.length / (maxPendingPoints - 1)).ceil();
    for (var index = 0; index < pending.length - 1; index += stride) {
      result.add(pending[index]);
    }
    result.add(pending.last);
    while (result.length > maxPendingPoints) {
      result.removeAt(1);
    }
    return result;
  }

  Future<List<RiderLocationUpdate>> _load() async {
    final preferences = await _instance;
    var encoded = preferences.getString(_pendingKey);
    if (encoded == null) {
      final legacy = preferences.getString(_legacyKey);
      if (legacy != null) {
        encoded = jsonEncode([jsonDecode(legacy)]);
        await preferences.remove(_legacyKey);
        await preferences.setString(_pendingKey, encoded);
      }
    }
    if (encoded == null) return [];
    return (jsonDecode(encoded) as List)
        .map(
          (item) => RiderLocationUpdate.fromJson(
            Map<String, Object?>.from(item as Map),
          ),
        )
        .toList();
  }

  Future<void> _save(List<RiderLocationUpdate> pending) async {
    final preferences = await _instance;
    if (pending.isEmpty) {
      await preferences.remove(_pendingKey);
    } else {
      await preferences.setString(
        _pendingKey,
        jsonEncode(pending.map((item) => item.toJson()).toList()),
      );
    }
  }

  Future<T> _exclusive<T>(Future<T> Function() action) {
    final result = Completer<T>();
    _serial = _serial.then((_) async {
      try {
        result.complete(await action());
      } on Object catch (error, stackTrace) {
        result.completeError(error, stackTrace);
      }
    });
    return result.future;
  }

  Future<SharedPreferences> get _instance async =>
      _preferences ?? await SharedPreferences.getInstance();
}
