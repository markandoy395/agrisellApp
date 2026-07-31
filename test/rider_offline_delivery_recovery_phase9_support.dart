part of 'rider_offline_delivery_recovery_phase9_test.dart';

RiderOfflineActionQueue _queue(SharedPreferences preferences) =>
    RiderOfflineActionQueue(
      repository: SharedPreferencesRiderOfflineQueue(preferences: preferences),
    );

DeliveryRequest _request({DeliveryStage stage = DeliveryStage.accepted}) =>
    DeliveryRequest(
      id: 'delivery-1',
      orderNumber: 'ORD-1',
      productName: 'Produce',
      sellerName: 'Seller',
      buyerName: 'Buyer',
      pickupLocation: const DeliveryLocation(address: 'Pickup'),
      deliveryLocation: const DeliveryLocation(address: 'Delivery'),
      pickupDeadline: DateTime(2030),
      deliveryFee: 50,
      stage: stage,
      assignedRiderId: stage == DeliveryStage.readyForPickup ? null : 'rider-1',
    );

DeliveryStatusLocation _location() => DeliveryStatusLocation(
  latitude: 8.48,
  longitude: 124.65,
  accuracyMeters: 8,
  timestamp: DateTime.now(),
);

RiderProfile _profile() => const RiderProfile(
  id: 'rider-1',
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
  employmentStatus: RiderEmploymentStatus.active,
  profilePhotoUrl: null,
);
