import 'package:agresell_app/features/rider/deliveries/data/rider_delivery_repository.dart';
import 'package:agresell_app/features/rider/deliveries/domain/delivery_acceptance.dart';
import 'package:agresell_app/features/rider/deliveries/domain/delivery_proof.dart';
import 'package:agresell_app/features/rider/deliveries/domain/delivery_request.dart';
import 'package:agresell_app/features/rider/deliveries/domain/delivery_stage.dart';
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
