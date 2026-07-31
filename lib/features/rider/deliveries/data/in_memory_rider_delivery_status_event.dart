part of 'rider_delivery_repository.dart';

extension _InMemoryRiderDeliveryStatusEvent on InMemoryRiderDeliveryRepository {
  DeliveryStatusEvent _eventFor(
    DeliveryStatusUpdateCommand command,
    int index,
  ) => DeliveryStatusEvent(
    eventId: 'status-${command.deliveryId}-$index',
    deliveryId: command.deliveryId,
    previousStatus: command.previousStatus,
    newStatus: command.newStatus,
    riderId: command.riderId,
    timestamp: _clock(),
    latitude: command.location?.latitude,
    longitude: command.location?.longitude,
    accuracyMeters: command.location?.accuracyMeters,
    locationTimestamp: command.location?.timestamp,
    isManualArrivalOverride: command.manualArrivalOverride,
    note: (command.note?.trim().isEmpty ?? true) ? null : command.note?.trim(),
    reasonCode:
        command.reasonCode ??
        (command.manualArrivalOverride ? command.manualOverrideReason : null),
    proofReference: command.proofReference,
    source: command.source,
    syncStatus: DeliveryEventSyncStatus.synchronized,
  );
}
