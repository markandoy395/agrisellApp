part of '../rider_safety_problem_phase11_test.dart';

RiderSafetyReport _safetyReport() => RiderSafetyReport(
  id: 'safety-1',
  deliveryId: 'delivery-1',
  riderId: 'rider-1',
  stage: DeliveryStatus.goingToBuyer,
  location: _statusLocation(),
  createdAt: DateTime(2026, 7, 15),
  category: RiderSafetyCategory.roadClosure,
  description: 'Flooding blocks the safe route.',
  attachments: const ['protected://reports/safety-photo'],
  requestedActions: const {
    RiderSafetyResponseAction.contactSupport,
    RiderSafetyResponseAction.shareLocationWithSupport,
  },
);

Future<RiderDeliveryController> _controller(
  InMemoryRiderDeliveryRepository repository, {
  RiderOfflineActionQueue? queue,
}) async {
  final controller = RiderDeliveryController(
    repository: repository,
    offlineQueue: queue,
  );
  controller.updateProfile(_profile());
  await controller.applyAuthoritativeAvailability(
    RiderAvailability.deliveryReserved,
    loadRequests: false,
  );
  await controller.load(riderId: 'rider-1');
  controller.updateCurrentRiderLocation(
    RiderLocation(
      latitude: 8.49,
      longitude: 124.66,
      accuracyMeters: 6,
      timestamp: DateTime.now(),
    ),
  );
  return controller;
}

RiderOfflineActionQueue _queue() =>
    RiderOfflineActionQueue(repository: MemoryOfflineQueueRepository());

DeliveryStatusLocation _statusLocation() => DeliveryStatusLocation(
  latitude: 8.49,
  longitude: 124.66,
  accuracyMeters: 6,
  timestamp: DateTime(2026, 7, 15),
);

DeliveryRequest _request() => DeliveryRequest(
  id: 'delivery-1',
  orderNumber: 'AGR-1',
  productName: 'Vegetables',
  sellerName: 'Farm',
  buyerName: 'Buyer',
  pickupLocation: const DeliveryLocation(address: 'Pickup'),
  deliveryLocation: const DeliveryLocation(address: 'Destination'),
  pickupDeadline: DateTime(2030),
  stage: DeliveryStage.accepted,
  assignedRiderId: 'rider-1',
);

RiderProfile _profile() => const RiderProfile(
  id: 'rider-1',
  logisticCompanyId: null,
  licenseNumber: 'LICENSE-1',
  fullName: 'Rider One',
  firstName: 'Rider',
  lastName: 'One',
  vehicleType: RiderVehicleType.motorcycle,
  vehiclePlateNumber: 'ABC123',
  availabilityStatus: RiderAvailability.offline,
  rating: 0,
  contactNumber: 'private',
  email: 'private@example.com',
  gpsLatitude: 8.48,
  gpsLongitude: 124.65,
  totalDeliveries: 0,
  employmentStatus: RiderEmploymentStatus.active,
  profilePhotoUrl: null,
);
