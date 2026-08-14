import 'dart:async';

import 'package:agresell_app/features/rider/deliveries/data/rider_delivery_repository.dart';
import 'package:agresell_app/features/rider/deliveries/domain/delivery_acceptance.dart';
import 'package:agresell_app/features/rider/deliveries/domain/delivery_proof.dart';
import 'package:agresell_app/features/rider/deliveries/domain/delivery_request.dart';
import 'package:agresell_app/features/rider/deliveries/domain/delivery_stage.dart';
import 'package:agresell_app/features/rider/deliveries/domain/delivery_status.dart';
import 'package:agresell_app/features/rider/deliveries/domain/delivery_status_update.dart';
import 'package:agresell_app/features/rider/deliveries/domain/pickup_confirmation.dart';
import 'package:agresell_app/features/rider/deliveries/domain/rider_delivery_search.dart';
import 'package:agresell_app/features/rider/deliveries/domain/rider_request_query.dart';
import 'package:agresell_app/features/rider/deliveries/domain/rider_acceptance_state.dart';
import 'package:agresell_app/features/rider/profile/domain/rider_profile.dart';
import 'package:agresell_app/features/rider/deliveries/presentation/controllers/rider_delivery_controller.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test(
    'default repository starts empty until backend requests arrive',
    () async {
      final repository = InMemoryRiderDeliveryRepository();
      final requests = await repository.fetchRequests(riderId: 'rider-a');
      expect(requests, isEmpty);
    },
  );
  test('requests load without a current GPS fix', () async {
    final request = DeliveryRequest(
      id: 'delivery-without-gps',
      orderNumber: 'ORD-NO-GPS',
      productName: 'Fresh vegetables',
      sellerName: 'Farmer',
      buyerName: 'Buyer',
      pickupLocation: const DeliveryLocation(address: 'Farm pickup'),
      deliveryLocation: const DeliveryLocation(address: 'Buyer address'),
      pickupDeadline: DateTime.now().add(const Duration(hours: 2)),
      assignmentRequestId: 'farmer-request-1',
    );
    final controller = RiderDeliveryController(
      repository: InMemoryRiderDeliveryRepository(requests: [request]),
    );
    addTearDown(controller.dispose);
    controller.updateProfile(_profile(RiderVerificationStatus.verified));
    controller.setOnline(true);

    // Establish the rider identity before the environment check. The initial
    // unauthenticated state must transition to preview access even without GPS.
    await controller.load(riderId: 'rider-a');
    controller.updateRequestEnvironment(
      state: RiderRequestAccessState.locationUnavailable,
    );
    await Future<void>.delayed(Duration.zero);

    expect(controller.requests, contains(request));
    expect(controller.usesRegisteredLocationEstimate, isTrue);
    expect(controller.requestAccessState.canAcceptRequests, isFalse);
  });
  test('unverified riders cannot accept delivery requests', () async {
    final controller = RiderDeliveryController(
      repository: InMemoryRiderDeliveryRepository(requests: [_request()]),
    );
    addTearDown(controller.dispose);
    controller.updateProfile(_profile(RiderVerificationStatus.pending));
    final result = await controller.accept(
      requestId: 'delivery-1',
      riderId: 'a',
    );
    expect(result.isSuccess, isFalse);
    expect(result.failure, DeliveryAcceptanceFailure.riderNotAllowed);
  });
  test('secure acceptance assigns only the first eligible Rider', () async {
    final repository = InMemoryRiderDeliveryRepository(
      requests: [_request()],
      riderStates: [_riderState('rider-a'), _riderState('rider-b')],
    );
    final first = RiderDeliveryController(repository: repository);
    final second = RiderDeliveryController(repository: repository);
    addTearDown(first.dispose);
    addTearDown(second.dispose);
    for (final controller in [first, second]) {
      controller.updateProfile(_profile(RiderVerificationStatus.verified));
      controller.setOnline(true);
      controller.updateRequestEnvironment(
        state: RiderRequestAccessState.eligible,
        location: const RiderDeliverySearch(latitude: 8.48, longitude: 124.65),
        accuracyMeters: 5,
      );
    }
    await first.load(riderId: 'rider-a');
    await second.load(riderId: 'rider-b');
    final accepted = await first.accept(
      requestId: 'delivery-1',
      riderId: 'rider-a',
    );
    final otherRider = await second.accept(
      requestId: 'delivery-1',
      riderId: 'rider-b',
    );
    expect(accepted.isSuccess, isTrue);
    expect(otherRider.isSuccess, isFalse);
    expect(otherRider.failure, DeliveryAcceptanceFailure.alreadyAssigned);
  });
  test('cancelling an active delivery requires a reason', () async {
    final controller = RiderDeliveryController(
      repository: InMemoryRiderDeliveryRepository(requests: [_activeRequest()]),
    );
    addTearDown(controller.dispose);
    controller.updateProfile(_profile(RiderVerificationStatus.verified));
    await controller.applyAuthoritativeAvailability(
      RiderAvailability.deliveryReserved,
      loadRequests: false,
    );
    await controller.load(riderId: 'rider-a');
    final missingReason = await controller.cancel(
      requestId: 'delivery-1',
      riderId: 'rider-a',
      reason: '',
    );
    final cancelled = await controller.cancel(
      requestId: 'delivery-1',
      riderId: 'rider-a',
      reason: 'Vehicle issue',
    );
    expect(missingReason.isSuccess, isFalse);
    expect(cancelled.isSuccess, isTrue);
    expect(cancelled.request?.stage.name, 'cancelled');
  });
  test('pickup cannot be confirmed without proof', () async {
    final controller = RiderDeliveryController(
      repository: InMemoryRiderDeliveryRepository(requests: [_activeRequest()]),
    );
    addTearDown(controller.dispose);
    controller.updateProfile(_profile(RiderVerificationStatus.verified));
    await controller.applyAuthoritativeAvailability(
      RiderAvailability.deliveryReserved,
      loadRequests: false,
    );
    await controller.load(riderId: 'rider-a');
    await controller.advance(
      requestId: 'delivery-1',
      riderId: 'rider-a',
      nextStage: DeliveryStage.goingToPickup,
    );
    await controller.advance(
      requestId: 'delivery-1',
      riderId: 'rider-a',
      nextStage: DeliveryStage.arrivedAtPickup,
    );
    final missingProof = await controller.advance(
      requestId: 'delivery-1',
      riderId: 'rider-a',
      nextStage: DeliveryStage.pickedUp,
    );
    final confirmed = await controller.advance(
      requestId: 'delivery-1',
      riderId: 'rider-a',
      nextStage: DeliveryStage.pickedUp,
      proof: DeliveryProof(
        id: 'proof-1',
        type: DeliveryProofType.pickupOneTimeCode,
        secureReference: 'stored-proof-1',
        capturedAt: DateTime(2030),
      ),
    );
    expect(missingProof.isSuccess, isFalse);
    expect(confirmed.isSuccess, isTrue);
  });
  test(
    'nearby searches reuse cached pickup markers until the rider moves',
    () async {
      final repository = _CountingRepository(requests: [_request()]);
      final controller = RiderDeliveryController(repository: repository);
      addTearDown(controller.dispose);
      controller.updateProfile(_profile(RiderVerificationStatus.verified));
      controller.setOnline(true);
      controller.updateRequestEnvironment(
        state: RiderRequestAccessState.eligible,
        location: const RiderDeliverySearch(latitude: 8.48, longitude: 124.65),
        accuracyMeters: 5,
      );
      await controller.load(riderId: 'rider-a');
      await controller.updateNearbySearch(
        const RiderDeliverySearch(latitude: 8.48, longitude: 124.65),
      );
      await controller.updateNearbySearch(
        const RiderDeliverySearch(latitude: 8.4805, longitude: 124.65),
      );
      expect(repository.fetchCalls, 1);
      await controller.updateNearbySearch(
        const RiderDeliverySearch(latitude: 8.483, longitude: 124.65),
      );
      expect(repository.fetchCalls, 2);
    },
  );
  test('repeated pickup taps share one confirmation request', () async {
    final repository = _DelayedPickupRepository(requests: [_pickupRequest()]);
    final transitionLocation = DeliveryStatusLocation(
      latitude: 8.48,
      longitude: 124.65,
      accuracyMeters: 5,
      timestamp: DateTime.now(),
    );
    await repository.updateDeliveryStatus(
      DeliveryStatusUpdateCommand(
        deliveryId: 'delivery-1',
        riderId: 'rider-a',
        previousStatus: DeliveryStatus.arrivedAtPickup,
        newStatus: DeliveryStatus.waitingForProduct,
        idempotencyKey: 'waiting',
        location: transitionLocation,
      ),
    );
    await repository.updateDeliveryStatus(
      DeliveryStatusUpdateCommand(
        deliveryId: 'delivery-1',
        riderId: 'rider-a',
        previousStatus: DeliveryStatus.waitingForProduct,
        newStatus: DeliveryStatus.pickupConfirmationRequired,
        idempotencyKey: 'confirmation-required',
        location: transitionLocation,
      ),
    );
    final controller = RiderDeliveryController(repository: repository);
    addTearDown(controller.dispose);
    controller.updateProfile(_profile(RiderVerificationStatus.verified));
    await controller.applyAuthoritativeAvailability(
      RiderAvailability.deliveryReserved,
      loadRequests: false,
    );
    await controller.load(riderId: 'rider-a');
    final command = PickupCompletionCommand(
      deliveryId: 'delivery-1',
      riderId: 'rider-a',
      idempotencyKey: 'one-pickup-request',
      location: DeliveryStatusLocation(
        latitude: 8.48,
        longitude: 124.65,
        accuracyMeters: 5,
        timestamp: DateTime.now(),
      ),
      checklist: const PickupConditionChecklist(
        correctProduct: true,
        correctQuantity: true,
        correctWeight: true,
        securePackaging: true,
        notVisiblyDamaged: true,
        matchesRequest: true,
        fitsVehicle: true,
        handlingInstructionsReceived: true,
        confirmedQuantity: 2,
        confirmedWeightKg: 0,
      ),
      proofReferences: const {
        PickupConfirmationMethod.productPhoto: 'protected://product-photo',
        PickupConfirmationMethod.farmerConfirmation:
            'protected://farmer-confirmation',
      },
    );

    final first = controller.completePickup(command);
    final repeated = controller.completePickup(command);
    expect(identical(first, repeated), isTrue);
    expect(repository.completionCalls, 1);

    repository.release();
    expect((await first).isSuccess, isTrue);
    expect((await repeated).isSuccess, isTrue);
    expect(repository.completionCalls, 1);
  });
}

class _DelayedPickupRepository extends InMemoryRiderDeliveryRepository {
  _DelayedPickupRepository({required super.requests});
  final _gate = Completer<void>();
  var completionCalls = 0;

  void release() => _gate.complete();

  @override
  Future<PickupCompletionResult> completePickup(
    PickupCompletionCommand command,
  ) async {
    completionCalls++;
    await _gate.future;
    return super.completePickup(command);
  }
}

class _CountingRepository extends InMemoryRiderDeliveryRepository {
  _CountingRepository({required super.requests});
  var fetchCalls = 0;
  @override
  Future<List<DeliveryRequest>> fetchRequests({
    required String riderId,
    RiderDeliverySearch? search,
  }) {
    fetchCalls++;
    return super.fetchRequests(riderId: riderId, search: search);
  }

  @override
  Future<RiderRequestPage> fetchNearbyRequests(RiderRequestQuery query) {
    fetchCalls++;
    return super.fetchNearbyRequests(query);
  }
}

DeliveryRequest _request() => DeliveryRequest(
  id: 'delivery-1',
  orderNumber: 'ORD-1',
  productName: 'Produce',
  sellerName: 'Seller',
  buyerName: 'Buyer',
  pickupLocation: const DeliveryLocation(address: 'Pickup'),
  deliveryLocation: const DeliveryLocation(address: 'Delivery'),
  pickupDeadline: DateTime(2030),
  deliveryDeadline: DateTime(2030, 1, 2),
  expiresAt: DateTime(2030),
  serviceArea: 'Cagayan de Oro',
  totalWeightKg: 10,
  distanceKm: 2,
  estimatedTravelMinutes: 10,
  pickupToDeliveryDistanceKm: 3,
  pickupToDeliveryMinutes: 15,
);
DeliveryRequest _activeRequest() => DeliveryRequest(
  id: 'delivery-1',
  orderNumber: 'ORD-1',
  productName: 'Produce',
  sellerName: 'Seller',
  buyerName: 'Buyer',
  pickupLocation: const DeliveryLocation(address: 'Pickup'),
  deliveryLocation: const DeliveryLocation(address: 'Delivery'),
  pickupDeadline: DateTime(2030),
  stage: DeliveryStage.accepted,
  assignedRiderId: 'rider-a',
);
DeliveryRequest _pickupRequest() => DeliveryRequest(
  id: 'delivery-1',
  orderNumber: 'ORD-1',
  productName: 'Produce',
  sellerName: 'Seller',
  buyerName: 'Buyer',
  pickupLocation: const DeliveryLocation(address: 'Pickup'),
  deliveryLocation: const DeliveryLocation(address: 'Delivery'),
  pickupDeadline: DateTime(2030),
  stage: DeliveryStage.arrivedAtPickup,
  assignedRiderId: 'rider-a',
);
RiderProfile _profile(RiderVerificationStatus status) => RiderProfile(
  id: 'rider-profile',
  logisticCompanyId: null,
  licenseNumber: 'LICENSE-1',
  fullName: 'Rider',
  firstName: 'Rider',
  lastName: '',
  vehicleType: RiderVehicleType.motorcycle,
  vehiclePlateNumber: 'ABC123',
  availabilityStatus: RiderAvailability.offline,
  rating: 0,
  contactNumber: '09123456789',
  email: 'rider@example.com',
  gpsLatitude: 8.48,
  gpsLongitude: 124.65,
  totalDeliveries: 0,
  employmentStatus: status == RiderVerificationStatus.verified
      ? RiderEmploymentStatus.active
      : RiderEmploymentStatus.pending,
  profilePhotoUrl: null,
  serviceArea: 'Cagayan de Oro',
  serviceRadiusKm: 15,
  capacityKg: 150,
);
RiderAcceptanceState _riderState(String id) => RiderAcceptanceState(
  riderId: id,
  isAllowedToDeliver: true,
  availability: RiderAvailability.onlineAvailable,
  vehicleType: RiderVehicleType.motorcycle,
  capacityKg: 150,
  serviceArea: 'Cagayan de Oro',
  serviceRadiusKm: 15,
  registeredLatitude: 8.48,
  registeredLongitude: 124.65,
  location: const RiderDeliverySearch(latitude: 8.48, longitude: 124.65),
  gpsAccuracyMeters: 5,
  activeDeliveryCount: 0,
);
