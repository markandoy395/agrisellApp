import 'dart:async';

import 'package:flutter/foundation.dart';

import 'package:agresell_app/core/services/agrisell_supabase.dart';
import 'package:agresell_app/features/rider/safety/data/rider_safety_repository.dart';
import 'package:agresell_app/features/rider/safety/data/supabase_rider_safety_repository.dart';
import 'package:agresell_app/features/rider/safety/domain/rider_safety_action.dart';
import 'package:agresell_app/features/rider/deliveries/data/rider_offline_action_queue.dart';
import 'package:agresell_app/features/rider/deliveries/domain/offline_delivery_action.dart';

class RiderSafetyController extends ChangeNotifier {
  factory RiderSafetyController({
    RiderSafetyRepository? repository,
    RiderOfflineActionQueue? offlineQueue,
  }) => RiderSafetyController._(
    repository ?? _defaultSafetyRepository(),
    offlineQueue,
  );

  RiderSafetyController._(this._repository, this._offlineQueue);

  final RiderSafetyRepository _repository;
  final RiderOfflineActionQueue? _offlineQueue;
  var _isSubmitting = false;
  String? _errorMessage;
  var _backendReachable = true;

  bool get isSubmitting => _isSubmitting;
  String? get errorMessage => _errorMessage;

  void setBackendReachable(bool reachable) {
    _backendReachable = reachable;
    if (reachable) unawaited(synchronizePendingReports());
  }

  Future<bool> submit({
    required String riderId,
    required RiderSafetyActionType type,
    String? reason,
  }) async {
    if (riderId.isEmpty ||
        (type.requiresReason && (reason?.trim().isEmpty ?? true))) {
      _errorMessage = 'A reason is required for this safety report.';
      notifyListeners();
      return false;
    }
    _isSubmitting = true;
    _errorMessage = null;
    notifyListeners();
    try {
      final timestamp = DateTime.now();
      if (!_backendReachable) {
        await _queue(
          RiderSafetyAction(
            id: 'safety-${timestamp.microsecondsSinceEpoch}',
            riderId: riderId,
            type: type,
            reason: reason?.trim(),
            createdAt: timestamp,
          ),
        );
        _errorMessage = 'Safety report saved. Waiting to synchronize.';
        return true;
      }
      await _repository.submit(
        RiderSafetyAction(
          id: 'safety-${timestamp.microsecondsSinceEpoch}',
          riderId: riderId,
          type: type,
          reason: reason?.trim(),
          createdAt: timestamp,
        ),
      );
      return true;
    } catch (_) {
      final timestamp = DateTime.now();
      try {
        await _queue(
          RiderSafetyAction(
            id: 'safety-${timestamp.microsecondsSinceEpoch}',
            riderId: riderId,
            type: type,
            reason: reason?.trim(),
            createdAt: timestamp,
          ),
        );
        _errorMessage = 'Safety report saved. Waiting to synchronize.';
        return true;
      } on Exception {
        _errorMessage = 'Safety request could not be submitted.';
        return false;
      }
    } finally {
      _isSubmitting = false;
      notifyListeners();
    }
  }

  Future<void> synchronizePendingReports() async {
    final queue = _offlineQueue;
    if (!_backendReachable || queue == null) return;
    for (final action
        in queue.actions
            .where(
              (item) =>
                  item.type == OfflineDeliveryActionType.safetyReport &&
                  item.status == OfflineDeliveryActionStatus.pending,
            )
            .toList()) {
      try {
        await _repository.submit(
          RiderSafetyAction(
            id: action.idempotencyKey,
            riderId: action.riderId,
            type: RiderSafetyActionType.values.byName(
              action.payload['type'] as String,
            ),
            reason: action.payload['reason'] as String?,
            createdAt: action.originalTimestamp,
          ),
        );
        await queue.acknowledge(action.localId);
      } on Exception {
        break;
      }
    }
  }

  Future<void> _queue(RiderSafetyAction action) async {
    final queue = _offlineQueue;
    if (queue == null) throw StateError('Offline safety queue is unavailable.');
    await queue.add(
      riderId: action.riderId,
      deliveryId: 'rider:${action.riderId}',
      type: OfflineDeliveryActionType.safetyReport,
      payload: {'type': action.type.name, 'reason': action.reason},
      originalTimestamp: action.createdAt,
      idempotencyKey: action.id,
    );
  }
}

RiderSafetyRepository _defaultSafetyRepository() {
  if (AgrisellSupabase.isInitialized &&
      AgrisellSupabase.client.auth.currentUser != null) {
    return SupabaseRiderSafetyRepository();
  }
  return InMemoryRiderSafetyRepository();
}
