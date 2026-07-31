import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:agresell_app/features/rider/deliveries/domain/delivery_status.dart';
import 'package:agresell_app/features/rider/deliveries/domain/delivery_status_event.dart';
import 'package:agresell_app/features/rider/deliveries/presentation/widgets/rider_delivery_progress_timeline.dart';

void main() {
  testWidgets('timeline presents the Phase 5 stages in logistics order', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: RiderDeliveryProgressTimeline(
            currentStatus: DeliveryStatus.goingToBuyer,
            events: [
              _event(DeliveryStatus.accepted),
              _event(DeliveryStatus.goingToPickup),
              _event(DeliveryStatus.arrivedAtPickup, withLocation: true),
              _event(DeliveryStatus.waitingForProduct),
              _event(DeliveryStatus.pickupConfirmationRequired),
              _event(DeliveryStatus.productPickedUp),
              _event(DeliveryStatus.goingToBuyer),
            ],
          ),
        ),
      ),
    );

    for (final label in const [
      'Accepted',
      'Going to pickup',
      'Arrived at pickup',
      'Waiting for product',
      'Product picked up',
      'Going to buyer',
      'Arrived at destination',
      'Waiting for buyer',
      'Product delivered',
      'Delivery completed',
    ]) {
      expect(find.text(label), findsOneWidget);
    }
    expect(find.textContaining('Location'), findsOneWidget);
    expect(find.byIcon(Icons.check_rounded), findsNWidgets(5));
  });
}

DeliveryStatusEvent _event(
  DeliveryStatus status, {
  bool withLocation = false,
}) => DeliveryStatusEvent(
  eventId: status.name,
  deliveryId: 'delivery-1',
  previousStatus: DeliveryStatus.accepted,
  newStatus: status,
  riderId: 'rider-a',
  timestamp: DateTime(2030),
  latitude: withLocation ? 8.48 : null,
  longitude: withLocation ? 124.65 : null,
  accuracyMeters: withLocation ? 5 : null,
  note: status == DeliveryStatus.waitingForProduct ? 'Packing' : null,
  source: DeliveryEventSource.online,
  syncStatus: DeliveryEventSyncStatus.synchronized,
);
