part of '../rider_batch_repository_phase13_test.dart';

Future<_BatchHarness> _harness() async {
  final repository = InMemoryRiderDeliveryRepository(
    requests: [
      batchRequest(id: 'a'),
      batchRequest(id: 'b', pickupLatitude: 8.482, deliveryLatitude: 8.5),
    ],
    riderStates: [batchRiderState()],
    clock: () => batchNow,
  );
  final controller = RiderDeliveryController(repository: repository)
    ..updateProfile(batchRiderProfile())
    ..updateRequestEnvironment(
      state: RiderRequestAccessState.eligible,
      location: const RiderDeliverySearch(latitude: 8.48, longitude: 124.65),
      accuracyMeters: 5,
    );
  await controller.applyAuthoritativeAvailability(
    RiderAvailability.onlineAvailable,
    loadRequests: false,
  );
  await controller.load(riderId: 'rider-a');
  return _BatchHarness(repository, controller);
}

DeliveryAcceptanceCommand _accept(String id, String key) =>
    DeliveryAcceptanceCommand(
      requestId: id,
      riderId: 'rider-a',
      idempotencyKey: key,
    );

Future<void> _pickupWithProof(
  InMemoryRiderDeliveryRepository repository,
  String id,
  String proofId,
) async {
  await repository.advance(
    requestId: id,
    riderId: 'rider-a',
    nextStage: DeliveryStage.goingToPickup,
  );
  await repository.advance(
    requestId: id,
    riderId: 'rider-a',
    nextStage: DeliveryStage.arrivedAtPickup,
  );
  await repository.advance(
    requestId: id,
    riderId: 'rider-a',
    nextStage: DeliveryStage.pickedUp,
    proof: DeliveryProof(
      id: proofId,
      type: DeliveryProofType.productPhoto,
      secureReference: 'protected://$proofId',
      capturedAt: batchNow,
    ),
  );
}

class _BatchHarness {
  const _BatchHarness(this.repository, this.controller);
  final InMemoryRiderDeliveryRepository repository;
  final RiderDeliveryController controller;
}
