import 'package:flutter_test/flutter_test.dart';

import 'package:agresell_app/features/rider/deliveries/domain/delivery_status.dart';
import 'package:agresell_app/features/rider/deliveries/domain/delivery_status_event.dart';
import 'package:agresell_app/features/rider/deliveries/domain/offline_delivery_action.dart';

void main() {
  test('status event serializes and deserializes every foundation field', () {
    final timestamp = DateTime.utc(2030, 4, 5, 6, 7);
    final event = DeliveryStatusEvent(
      eventId: 'event-1',
      deliveryId: 'delivery-1',
      previousStatus: DeliveryStatus.arrivedAtPickup,
      newStatus: DeliveryStatus.waitingForProduct,
      riderId: 'rider-1',
      timestamp: timestamp,
      latitude: 8.4822,
      longitude: 124.6472,
      accuracyMeters: 4.5,
      note: 'Seller is packing the produce.',
      reasonCode: 'PRODUCT_PREPARATION',
      proofReference: 'proof://secure-1',
      source: DeliveryEventSource.offline,
      syncStatus: DeliveryEventSyncStatus.pending,
    );

    final restored = DeliveryStatusEvent.fromJson(event.toJson());

    expect(restored.eventId, event.eventId);
    expect(restored.deliveryId, event.deliveryId);
    expect(restored.previousStatus, event.previousStatus);
    expect(restored.newStatus, event.newStatus);
    expect(restored.riderId, event.riderId);
    expect(restored.timestamp.isAtSameMomentAs(timestamp), isTrue);
    expect(restored.latitude, event.latitude);
    expect(restored.longitude, event.longitude);
    expect(restored.accuracyMeters, event.accuracyMeters);
    expect(restored.note, event.note);
    expect(restored.reasonCode, event.reasonCode);
    expect(restored.proofReference, event.proofReference);
    expect(restored.source, DeliveryEventSource.offline);
    expect(restored.syncStatus, DeliveryEventSyncStatus.pending);
  });

  test('offline queued action round-trips without a sync engine', () {
    final queuedAt = DateTime.utc(2030, 1, 2);
    final action = OfflineDeliveryAction(
      id: 'queue-1',
      deliveryId: 'delivery-1',
      riderId: 'rider-1',
      type: OfflineDeliveryActionType.updateStatus,
      status: OfflineDeliveryActionStatus.pending,
      payload: const <String, Object?>{
        'status': 'arrived_at_pickup',
        'accuracyMeters': 5,
      },
      queuedAt: queuedAt,
      attemptCount: 2,
    );

    final restored = OfflineDeliveryAction.fromJson(action.toJson());

    expect(restored.id, action.id);
    expect(restored.deliveryId, action.deliveryId);
    expect(restored.riderId, action.riderId);
    expect(restored.type, action.type);
    expect(restored.status, action.status);
    expect(restored.payload, action.payload);
    expect(restored.queuedAt.isAtSameMomentAs(queuedAt), isTrue);
    expect(restored.attemptCount, 2);
  });
}
