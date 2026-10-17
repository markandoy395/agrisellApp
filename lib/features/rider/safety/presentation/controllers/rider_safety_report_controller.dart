import 'package:flutter/foundation.dart';
import 'package:agresell_app/core/utils/async_operation_gate.dart';
import 'package:agresell_app/core/utils/async_request_scope.dart';

import 'package:agresell_app/core/services/agrisell_supabase.dart';
import 'package:agresell_app/features/rider/deliveries/data/rider_offline_action_queue.dart';
import 'package:agresell_app/features/rider/deliveries/domain/offline_delivery_action.dart';
import 'package:agresell_app/features/rider/deliveries/domain/delivery_status.dart';
import 'package:agresell_app/features/rider/deliveries/domain/delivery_status_update.dart';
import 'package:agresell_app/features/rider/safety/data/rider_safety_repository.dart';
import 'package:agresell_app/features/rider/safety/data/supabase_rider_safety_repository.dart';
import 'package:agresell_app/features/rider/safety/domain/rider_safety_report.dart';

class RiderSafetyReportController extends ChangeNotifier {
  RiderSafetyReportController({
    RiderSafetyRepository? repository,
    RiderOfflineActionQueue? offlineQueue,
  }) : _repository = repository ?? _defaultReportRepository(),
       _offlineQueue = offlineQueue ?? RiderOfflineActionQueue(),
       _ownsQueue = offlineQueue == null;

  final RiderSafetyRepository _repository;
  final RiderOfflineActionQueue _offlineQueue;
  final bool _ownsQueue;
  final Map<String, RiderSafetyReport> _reports = {};
  bool _backendReachable = true;
  String? _riderId;
  final _operations = AsyncOperationGate();
  final _scope = AsyncRequestScope();

  RiderSafetyReport? reportFor(String deliveryId) => _reports[deliveryId];

  Future<void> restore(String riderId) async {
    final ticket = _scope.begin('restore');
    _riderId = riderId;
    await _offlineQueue.initialize(riderId);
    if (!ticket.isCurrent) return;
    for (final action in _offlineQueue.actions.where(
      (item) => item.type == OfflineDeliveryActionType.safetyReport,
    )) {
      final report = _fromAction(action);
      _reports[report.deliveryId] = report;
    }
    notifyListeners();
  }

  Future<RiderSafetyReport> submit(RiderSafetyReport report) =>
      _operations.run(('submit', report.id), () => _submit(report));

  Future<RiderSafetyReport> _submit(RiderSafetyReport report) async {
    final ticket = _scope.begin(('submit', report.id));
    _riderId = report.riderId;
    await _offlineQueue.initialize(report.riderId);
    if (!ticket.isCurrent) return report;
    _reports[report.deliveryId] = report;
    notifyListeners();
    if (!_backendReachable) {
      await _queue(report);
      return report;
    }
    try {
      final saved = await _sendReport(report);
      if (!ticket.isCurrent) return report;
      _reports[report.deliveryId] = saved;
      notifyListeners();
      return saved;
    } catch (_) {
      if (!ticket.isCurrent) return report;
      await _queue(report);
      return report;
    }
  }

  void setBackendReachable(bool value) {
    _backendReachable = value;
    if (value) synchronize();
  }

  Future<RiderSafetyReport> _sendReport(RiderSafetyReport report) => _operations
      .run(('remote', report.id), () => _repository.submitReport(report));

  Future<void> synchronize() => _operations.run('sync', _synchronize);

  Future<void> _synchronize() async {
    final ticket = _scope.begin('sync');
    final riderId = _riderId;
    if (!_backendReachable || riderId == null) return;
    for (final action
        in _offlineQueue.actions
            .where(
              (item) =>
                  item.type == OfflineDeliveryActionType.safetyReport &&
                  item.status == OfflineDeliveryActionStatus.pending,
            )
            .toList()) {
      try {
        final report = _fromAction(action);
        final saved = await _sendReport(report);
        if (!ticket.isCurrent) return;
        _reports[saved.deliveryId] = saved;
        await _offlineQueue.acknowledge(action.localId);
      } on Exception {
        break;
      }
    }
    if (ticket.isCurrent) notifyListeners();
  }

  Future<void> _queue(RiderSafetyReport report) => _offlineQueue.add(
    riderId: report.riderId,
    deliveryId: report.deliveryId,
    type: OfflineDeliveryActionType.safetyReport,
    idempotencyKey: report.id,
    originalTimestamp: report.createdAt,
    payload: {
      'stage': report.stage.name,
      'latitude': report.location.latitude,
      'longitude': report.location.longitude,
      'accuracyMeters': report.location.accuracyMeters,
      'category': report.category.name,
      'description': report.description,
      'attachments': report.attachments,
      'actions': report.requestedActions.map((item) => item.name).toList(),
    },
  );

  RiderSafetyReport _fromAction(OfflineDeliveryAction action) =>
      RiderSafetyReport(
        id: action.idempotencyKey,
        deliveryId: action.deliveryId,
        riderId: action.riderId,
        stage: DeliveryStatus.values.byName(action.payload['stage'] as String),
        location: DeliveryStatusLocation(
          latitude: (action.payload['latitude'] as num).toDouble(),
          longitude: (action.payload['longitude'] as num).toDouble(),
          accuracyMeters: (action.payload['accuracyMeters'] as num).toDouble(),
          timestamp: action.originalTimestamp,
        ),
        createdAt: action.originalTimestamp,
        category: RiderSafetyCategory.values.byName(
          action.payload['category'] as String,
        ),
        description: action.payload['description'] as String,
        attachments: List<String>.from(action.payload['attachments'] as List),
        requestedActions: {
          for (final value in action.payload['actions'] as List)
            RiderSafetyResponseAction.values.byName(value as String),
        },
      );

  @override
  void dispose() {
    _scope.dispose();
    if (_ownsQueue) _offlineQueue.dispose();
    super.dispose();
  }
}

RiderSafetyRepository _defaultReportRepository() {
  if (AgrisellSupabase.isInitialized &&
      AgrisellSupabase.client.auth.currentUser != null) {
    return SupabaseRiderSafetyRepository();
  }
  return InMemoryRiderSafetyRepository();
}
