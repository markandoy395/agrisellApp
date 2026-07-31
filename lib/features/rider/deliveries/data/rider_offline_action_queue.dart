import 'dart:math';

import 'package:flutter/foundation.dart';

import '../domain/offline_delivery_action.dart';
import 'rider_delivery_foundation_repositories.dart';
import 'shared_preferences_rider_offline_queue.dart';

part 'rider_offline_action_queue_rules.dart';

class RiderOfflineActionQueue extends ChangeNotifier {
  RiderOfflineActionQueue({
    OfflineQueueRepository? repository,
    DateTime Function()? clock,
    Random? random,
    this.maxLocationActions = 200,
  }) : _repository = repository ?? SharedPreferencesRiderOfflineQueue(),
       _clock = clock ?? DateTime.now,
       _random = random ?? Random.secure();

  final OfflineQueueRepository _repository;
  final DateTime Function() _clock;
  final Random _random;
  final int maxLocationActions;
  String? _riderId;
  List<OfflineDeliveryAction> _actions = const [];

  List<OfflineDeliveryAction> get actions => List.unmodifiable(_actions);
  int get pendingCount => _actions.where(_isPending).length;
  int get attentionCount => _actions
      .where(
        (action) =>
            action.status == OfflineDeliveryActionStatus.requiresAttention ||
            action.status == OfflineDeliveryActionStatus.failed ||
            action.status == OfflineDeliveryActionStatus.conflict,
      )
      .length;
  int get failedCount => _actions
      .where((action) => action.status == OfflineDeliveryActionStatus.failed)
      .length;
  int get requiresAttentionCount => _actions
      .where(
        (action) =>
            action.status == OfflineDeliveryActionStatus.requiresAttention ||
            action.status == OfflineDeliveryActionStatus.conflict,
      )
      .length;

  Future<void> initialize(String riderId) async {
    _riderId = riderId;
    final stored = await _repository.loadAll(riderId);
    _actions = _ordered(
      stored.map((action) {
        if (action.status == OfflineDeliveryActionStatus.synchronizing ||
            action.status == OfflineDeliveryActionStatus.processing) {
          return action.copyWith(status: OfflineDeliveryActionStatus.pending);
        }
        return action;
      }).toList(),
    );
    await _persist();
    notifyListeners();
  }

  Future<OfflineDeliveryAction> add({
    required String riderId,
    required String deliveryId,
    required OfflineDeliveryActionType type,
    required Map<String, Object?> payload,
    required DateTime originalTimestamp,
    String? idempotencyKey,
    String? dependencyId,
    int? maxRetries,
  }) async {
    if (_riderId != riderId) await initialize(riderId);
    final key = idempotencyKey ?? _newId('idem');
    final duplicate = _actions.where((action) => action.idempotencyKey == key);
    if (duplicate.isNotEmpty) return duplicate.first;
    final action = OfflineDeliveryAction(
      localId: _newId('local'),
      idempotencyKey: key,
      riderId: riderId,
      deliveryId: deliveryId,
      type: type,
      status: OfflineDeliveryActionStatus.pending,
      payload: payload,
      originalTimestamp: originalTimestamp,
      createdAt: _clock(),
      maxRetries: maxRetries ?? _retryLimit(type),
      sequence: _nextSequence,
      dependencyId: dependencyId,
    );
    _actions = _compactLocations(_ordered([..._actions, action]));
    await _persist();
    notifyListeners();
    return action;
  }

  Future<void> update(OfflineDeliveryAction action) async {
    _actions = _ordered([
      for (final item in _actions)
        if (item.localId == action.localId) action else item,
    ]);
    await _persist();
    notifyListeners();
  }

  Future<void> acknowledge(String localId) async {
    _actions = _actions
        .where((action) => action.localId != localId)
        .toList(growable: false);
    await _persist();
    notifyListeners();
  }

  Future<bool> retry(String localId) async {
    final match = _actions.where((action) => action.localId == localId);
    if (match.isEmpty ||
        match.first.status == OfflineDeliveryActionStatus.requiresAttention ||
        match.first.status == OfflineDeliveryActionStatus.conflict ||
        match.first.status == OfflineDeliveryActionStatus.cancelled) {
      return false;
    }
    await update(
      match.first.copyWith(
        status: OfflineDeliveryActionStatus.pending,
        retryCount: 0,
        clearLastError: true,
        clearNextAttempt: true,
      ),
    );
    return true;
  }

  OfflineDeliveryAction? firstOpenFor({
    required String deliveryId,
    required OfflineDeliveryActionType type,
  }) {
    for (final action in _actions) {
      if (action.deliveryId == deliveryId &&
          action.type == type &&
          action.status != OfflineDeliveryActionStatus.cancelled) {
        return action;
      }
    }
    return null;
  }

  Future<void> safeCleanup() async {
    _actions = _actions
        .where((action) {
          if (action.containsEvidence) return true;
          return action.status != OfflineDeliveryActionStatus.synchronized &&
              action.status != OfflineDeliveryActionStatus.cancelled;
        })
        .toList(growable: false);
    await _persist();
    notifyListeners();
  }

  int get _nextSequence =>
      _actions.fold<int>(
        0,
        (largest, action) => max(largest, action.sequence),
      ) +
      1;

  List<OfflineDeliveryAction> _compactLocations(
    List<OfflineDeliveryAction> actions,
  ) {
    final locations = actions.where(_isLocation).toList();
    if (locations.length <= maxLocationActions) return actions;
    final keep = locations
        .where((item) => item.payload['important'] == true)
        .map((item) => item.localId)
        .toSet();
    for (final item in locations.reversed) {
      if (keep.length >= maxLocationActions) break;
      keep.add(item.localId);
    }
    return actions
        .where(
          (action) => !_isLocation(action) || keep.contains(action.localId),
        )
        .toList(growable: false);
  }

  Future<void> _persist() async {
    final riderId = _riderId;
    if (riderId != null) await _repository.replaceAll(riderId, _actions);
  }

  String _newId(String prefix) =>
      '$prefix-${_clock().microsecondsSinceEpoch}-${_random.nextInt(1 << 32)}';
}
