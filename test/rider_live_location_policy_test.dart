import 'package:flutter_test/flutter_test.dart';

import 'package:agresell_app/features/rider/deliveries/data/rider_live_location_store.dart';
import 'package:agresell_app/features/rider/deliveries/data/rider_location_outbox.dart';
import 'package:agresell_app/features/rider/deliveries/domain/delivery_request.dart';
import 'package:agresell_app/features/rider/deliveries/domain/delivery_stage.dart';
import 'package:agresell_app/features/rider/deliveries/domain/delivery_status.dart';
import 'package:agresell_app/features/rider/deliveries/domain/rider_live_location_policy.dart';

void main() {
  final now = DateTime.now();
  final request = DeliveryRequest(
    id: 'delivery-1',
    orderNumber: 'ORDER-1',
    productName: 'Produce',
    sellerName: 'Farmer',
    buyerName: 'Buyer',
    pickupLocation: const DeliveryLocation(address: 'Farm'),
    deliveryLocation: const DeliveryLocation(address: 'Buyer'),
    pickupDeadline: DateTime(2030),
    stage: DeliveryStage.goingToPickup,
    assignedRiderId: 'rider-1',
  );

  test(
    'sharing starts in every operational stage and stops in terminal stages',
    () {
      const operational = {
        DeliveryStatus.goingToPickup,
        DeliveryStatus.arrivedAtPickup,
        DeliveryStatus.waitingForProduct,
        DeliveryStatus.pickupConfirmationRequired,
        DeliveryStatus.productPickedUp,
        DeliveryStatus.goingToBuyer,
        DeliveryStatus.arrivedAtDelivery,
        DeliveryStatus.waitingForBuyer,
        DeliveryStatus.deliveryConfirmationRequired,
      };
      for (final status in operational) {
        expect(isLiveLocationSharingStage(status), isTrue, reason: status.name);
      }
      for (final status in {
        DeliveryStatus.deliveryCompleted,
        DeliveryStatus.cancelled,
        DeliveryStatus.failed,
        DeliveryStatus.returned,
        DeliveryStatus.reassigned,
      }) {
        expect(
          isLiveLocationSharingStage(status),
          isFalse,
          reason: status.name,
        );
      }
    },
  );

  test('duplicate point is ignored and invalid point is rejected', () async {
    final store = InMemoryRiderLiveLocationStore(
      participants: {
        request.id: {'buyer-1'},
      },
      clock: () => now,
    );
    final first = _update(now);
    await store.publish(
      request: request,
      status: DeliveryStatus.goingToPickup,
      update: first,
    );
    await store.publish(
      request: request,
      status: DeliveryStatus.goingToPickup,
      update: _update(now.add(const Duration(seconds: 2))),
    );
    expect(
      await store.latest(deliveryId: request.id, participantId: 'buyer-1'),
      same(first),
    );
    await expectLater(
      store.publish(
        request: request,
        status: DeliveryStatus.goingToPickup,
        update: _update(now.subtract(const Duration(minutes: 2))),
      ),
      throwsA(isA<RiderLiveLocationAccessException>()),
    );
  });

  test(
    'only assigned rider can publish and stop the tracking record',
    () async {
      final store = InMemoryRiderLiveLocationStore(
        participants: {
          request.id: {'buyer-1'},
        },
        clock: () => now,
      );
      await expectLater(
        store.publish(
          request: request,
          status: DeliveryStatus.goingToPickup,
          update: _update(now, riderId: 'other-rider'),
        ),
        throwsA(isA<RiderLiveLocationAccessException>()),
      );
      await store.publish(
        request: request,
        status: DeliveryStatus.goingToPickup,
        update: _update(now),
      );
      await store.stop(deliveryId: request.id, riderId: 'rider-1');
      await expectLater(
        store.latest(deliveryId: request.id, participantId: 'buyer-1'),
        throwsA(isA<RiderLiveLocationAccessException>()),
      );
    },
  );
}

RiderLocationUpdate _update(DateTime at, {String riderId = 'rider-1'}) =>
    RiderLocationUpdate(
      latitude: 8.48,
      longitude: 124.65,
      accuracyMeters: 8,
      capturedAt: at,
      deliveryId: 'delivery-1',
      riderId: riderId,
    );
