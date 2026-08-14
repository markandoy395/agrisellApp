import 'package:flutter_test/flutter_test.dart';

import 'package:agresell_app/features/rider/dashboard/domain/rider_availability.dart';
import 'package:agresell_app/features/rider/deliveries/data/rider_delivery_repository.dart';
import 'package:agresell_app/features/rider/deliveries/domain/delivery_acceptance.dart';
import 'package:agresell_app/features/rider/deliveries/domain/delivery_request.dart';
import 'package:agresell_app/features/rider/deliveries/domain/delivery_stage.dart';
import 'package:agresell_app/features/rider/deliveries/domain/rider_acceptance_state.dart';
import 'package:agresell_app/features/rider/profile/domain/rider_registration.dart';
import 'support/rider_acceptance_fixture.dart';

void main() {
  test('missing delivery is rejected', () async {
    final failure = await _failure(requestId: 'missing');
    expect(failure, DeliveryAcceptanceFailure.requestNotFound);
  });

  test('expired delivery is rejected', () async {
    final failure = await _failure(
      request: acceptanceRequest(
        expiresAt: acceptanceNow.subtract(const Duration(seconds: 1)),
      ),
    );
    expect(failure, DeliveryAcceptanceFailure.expired);
  });

  test('already-assigned delivery is rejected', () async {
    final failure = await _failure(
      request: acceptanceRequest(assignedRiderId: 'rider-b'),
    );
    expect(failure, DeliveryAcceptanceFailure.alreadyAssigned);
  });

  test('product no longer ready is rejected', () async {
    final failure = await _failure(
      request: acceptanceRequest(stage: DeliveryStage.cancelled),
    );
    expect(failure, DeliveryAcceptanceFailure.productNotReady);
  });

  test('Rider eligibility changed before acceptance', () async {
    final failure = await _failure(rider: acceptanceRider(allowed: false));
    expect(failure, DeliveryAcceptanceFailure.riderNotAllowed);
  });

  test('vehicle type changed before acceptance', () async {
    final failure = await _failure(
      rider: acceptanceRider(vehicleType: RiderVehicleType.bicycle),
    );
    expect(failure, DeliveryAcceptanceFailure.vehicleMismatch);
  });

  test('vehicle capacity changed before acceptance', () async {
    final failure = await _failure(rider: acceptanceRider(capacityKg: 5));
    expect(failure, DeliveryAcceptanceFailure.capacityMismatch);
  });

  test('Rider became Offline before acceptance', () async {
    final failure = await _failure(
      rider: acceptanceRider(availability: RiderAvailability.offline),
    );
    expect(failure, DeliveryAcceptanceFailure.riderOffline);
  });

  test('manually booked offline Rider can accept before expiration', () async {
    final repository = InMemoryRiderDeliveryRepository(
      requests: [
        acceptanceRequest(
          reservedRiderId: 'rider-a',
          reservedUntil: acceptanceNow.add(const Duration(minutes: 45)),
        ),
      ],
      riderStates: [acceptanceRider(availability: RiderAvailability.offline)],
      clock: () => acceptanceNow,
    );

    final receipt = await repository.acceptDelivery(acceptanceCommand());

    expect(receipt.request.assignedRiderId, 'rider-a');
  });

  test('expired offline booking cannot be accepted', () async {
    final failure = await _failure(
      request: acceptanceRequest(
        reservedRiderId: 'rider-a',
        reservedUntil: acceptanceNow.subtract(const Duration(seconds: 1)),
      ),
      rider: acceptanceRider(availability: RiderAvailability.offline),
    );
    expect(failure, DeliveryAcceptanceFailure.riderOffline);
  });

  test('unacceptable Rider location is rejected', () async {
    final failure = await _failure(rider: acceptanceRider(hasLocation: false));
    expect(failure, DeliveryAcceptanceFailure.locationUnacceptable);
  });

  test('incompatible service area is rejected', () async {
    final failure = await _failure(
      rider: acceptanceRider(serviceArea: 'Iligan'),
    );
    expect(failure, DeliveryAcceptanceFailure.serviceAreaMismatch);
  });

  test('active-delivery limit is revalidated', () async {
    final failure = await _failure(rider: acceptanceRider(activeCount: 1));
    expect(failure, DeliveryAcceptanceFailure.activeDeliveryLimit);
  });

  test('conflicting Rider assignment is rejected', () async {
    final failure = await _failure(
      rider: acceptanceRider(conflictingDeliveryId: 'delivery-previous'),
    );
    expect(failure, DeliveryAcceptanceFailure.conflictingAssignment);
  });
}

Future<DeliveryAcceptanceFailure> _failure({
  String requestId = 'delivery-1',
  DeliveryRequest? request,
  RiderAcceptanceState? rider,
}) {
  final repository = InMemoryRiderDeliveryRepository(
    requests: [request ?? acceptanceRequest()],
    riderStates: [rider ?? acceptanceRider()],
    clock: () => acceptanceNow,
  );
  return captureAcceptanceFailure(
    repository.acceptDelivery(acceptanceCommand(requestId: requestId)),
  );
}
