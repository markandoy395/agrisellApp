import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../domain/offline_delivery_action.dart';
import 'rider_delivery_foundation_repositories.dart';

class SharedPreferencesRiderOfflineQueue implements OfflineQueueRepository {
  factory SharedPreferencesRiderOfflineQueue({
    SharedPreferences? preferences,
  }) => SharedPreferencesRiderOfflineQueue._(preferences);

  SharedPreferencesRiderOfflineQueue._(this._preferences);

  static const _prefix = 'rider_offline_actions_v2_';
  final SharedPreferences? _preferences;

  @override
  Future<void> enqueue(OfflineDeliveryAction action) async {
    final actions = await loadAll(action.riderId);
    final duplicate = actions.any(
      (item) =>
          item.localId == action.localId ||
          item.idempotencyKey == action.idempotencyKey,
    );
    if (!duplicate) await replaceAll(action.riderId, [...actions, action]);
  }

  @override
  Future<List<OfflineDeliveryAction>> loadPending(String riderId) async {
    final actions = await loadAll(riderId);
    return actions
        .where(
          (action) =>
              action.status == OfflineDeliveryActionStatus.pending ||
              action.status == OfflineDeliveryActionStatus.synchronizing ||
              action.status == OfflineDeliveryActionStatus.processing,
        )
        .toList(growable: false);
  }

  @override
  Future<List<OfflineDeliveryAction>> loadAll(String riderId) async {
    if (riderId.isEmpty) return const [];
    final preferences = await _instance;
    final encoded = preferences.getString('$_prefix$riderId');
    if (encoded == null) return const [];
    final values = jsonDecode(encoded) as List;
    return values
        .map(
          (value) => OfflineDeliveryAction.fromJson(
            Map<String, Object?>.from(value as Map),
          ),
        )
        .toList(growable: false);
  }

  @override
  Future<void> replace(OfflineDeliveryAction action) async {
    final actions = await loadAll(action.riderId);
    var found = false;
    final updated = [
      for (final item in actions)
        if (item.localId == action.localId) ...[action] else item,
    ];
    found = actions.any((item) => item.localId == action.localId);
    await replaceAll(action.riderId, found ? updated : [...updated, action]);
  }

  @override
  Future<void> replaceAll(
    String riderId,
    List<OfflineDeliveryAction> actions,
  ) async {
    final preferences = await _instance;
    final key = '$_prefix$riderId';
    if (actions.isEmpty) {
      await preferences.remove(key);
      return;
    }
    final ordered = [...actions]
      ..sort((a, b) {
        final sequence = a.sequence.compareTo(b.sequence);
        return sequence != 0
            ? sequence
            : a.originalTimestamp.compareTo(b.originalTimestamp);
      });
    await preferences.setString(
      key,
      jsonEncode(ordered.map((action) => action.toJson()).toList()),
    );
  }

  @override
  Future<void> remove(String actionId) async {
    final preferences = await _instance;
    for (final key in preferences.getKeys().where(
      (item) => item.startsWith(_prefix),
    )) {
      final riderId = key.substring(_prefix.length);
      final actions = await loadAll(riderId);
      final updated = actions
          .where((action) => action.localId != actionId)
          .toList();
      if (updated.length != actions.length) {
        await replaceAll(riderId, updated);
        return;
      }
    }
  }

  Future<SharedPreferences> get _instance async =>
      _preferences ?? await SharedPreferences.getInstance();
}
