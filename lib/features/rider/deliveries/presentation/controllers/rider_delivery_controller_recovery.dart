part of 'rider_delivery_controller.dart';

extension RiderDeliveryControllerRecovery on RiderDeliveryController {
  Map<String, Object?> recoveryDataFor(String scope) {
    final value = _recoveryData[scope];
    return value is Map
        ? Map.unmodifiable(Map<String, Object?>.from(value))
        : const {};
  }

  Future<void> saveRecoveryData(
    String scope,
    Map<String, Object?> value,
  ) async {
    _recoveryData = Map.unmodifiable({..._recoveryData, scope: value});
    _notify();
    await _persistState();
  }

  Future<void> clearRecoveryData(String scope) async {
    if (!_recoveryData.containsKey(scope)) return;
    _recoveryData = Map.unmodifiable({
      for (final entry in _recoveryData.entries)
        if (entry.key != scope) entry.key: entry.value,
    });
    _notify();
    await _persistState();
  }

  Future<void> _clearResolvedProblemDrafts() async {
    final retained = <String, Object?>{};
    for (final entry in _recoveryData.entries) {
      if (!entry.key.startsWith('draftReport:')) {
        retained[entry.key] = entry.value;
        continue;
      }
      final deliveryId = entry.key.substring('draftReport:'.length);
      final hasOpenReport = _offlineQueue.actions.any(
        (action) =>
            action.deliveryId == deliveryId &&
            action.type == OfflineDeliveryActionType.problemReport,
      );
      if (hasOpenReport) retained[entry.key] = entry.value;
    }
    if (retained.length == _recoveryData.length) return;
    _recoveryData = Map.unmodifiable(retained);
    _notify();
  }
}
