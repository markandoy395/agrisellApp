import 'package:agresell_app/features/rider/dashboard/domain/rider_availability.dart';
import 'package:agresell_app/features/rider/deliveries/domain/delivery_acceptance.dart';
import 'package:agresell_app/features/rider/deliveries/domain/delivery_request.dart';
import 'package:agresell_app/features/rider/deliveries/domain/delivery_stage.dart';
import 'package:agresell_app/features/rider/deliveries/domain/rider_acceptance_state.dart';
import 'package:agresell_app/features/rider/deliveries/domain/rider_delivery_search.dart';
import 'package:agresell_app/features/rider/profile/domain/rider_registration.dart';

final acceptanceNow = DateTime(2028, 1, 1, 9);

DeliveryRequest acceptanceRequest({
  String id = 'delivery-1',
  DeliveryStage stage = DeliveryStage.readyForPickup,
  String? assignedRiderId,
  DateTime? expiresAt,
  double weightKg = 20,
  Set<RiderVehicleType> vehicleTypes = const {RiderVehicleType.motorcycle},
}) => DeliveryRequest(
  id: id,
  orderNumber: 'AGR-$id',
  productName: 'Fresh Tomatoes',
  productCategory: 'Produce',
  sellerName: 'Carmen Farm',
  buyerName: 'Private buyer',
  pickupLocation: const DeliveryLocation(address: 'Carmen Market'),
  deliveryLocation: const DeliveryLocation(address: 'Uptown'),
  pickupDeadline: acceptanceNow.add(const Duration(hours: 1)),
  deliveryDeadline: acceptanceNow.add(const Duration(hours: 2)),
  availableAt: acceptanceNow.subtract(const Duration(minutes: 5)),
  expiresAt: expiresAt ?? acceptanceNow.add(const Duration(minutes: 30)),
  serviceArea: 'Cagayan de Oro',
  totalWeightKg: weightKg,
  requiredCapacityKg: weightKg,
  requiredVehicleTypes: vehicleTypes,
  distanceKm: 2,
  estimatedTravelMinutes: 10,
  pickupToDeliveryDistanceKm: 4,
  pickupToDeliveryMinutes: 20,
  deliveryFee: 180,
  stage: stage,
  assignedRiderId: assignedRiderId,
);

RiderAcceptanceState acceptanceRider({
  String id = 'rider-a',
  bool allowed = true,
  RiderAvailability availability = RiderAvailability.onlineAvailable,
  RiderVehicleType vehicleType = RiderVehicleType.motorcycle,
  double capacityKg = 100,
  String serviceArea = 'Cagayan de Oro',
  double serviceRadiusKm = 15,
  double registeredLatitude = 8.48,
  double registeredLongitude = 124.65,
  bool hasLocation = true,
  double accuracyMeters = 5,
  int activeCount = 0,
  int maximumActive = 1,
  String? conflictingDeliveryId,
}) => RiderAcceptanceState(
  riderId: id,
  isAllowedToDeliver: allowed,
  availability: availability,
  vehicleType: vehicleType,
  capacityKg: capacityKg,
  serviceArea: serviceArea,
  serviceRadiusKm: serviceRadiusKm,
  registeredLatitude: registeredLatitude,
  registeredLongitude: registeredLongitude,
  location: hasLocation
      ? const RiderDeliverySearch(latitude: 8.48, longitude: 124.65)
      : null,
  gpsAccuracyMeters: hasLocation ? accuracyMeters : null,
  activeDeliveryCount: activeCount,
  maximumActiveDeliveries: maximumActive,
  conflictingDeliveryId: conflictingDeliveryId,
);

DeliveryAcceptanceCommand acceptanceCommand({
  String requestId = 'delivery-1',
  String riderId = 'rider-a',
  String key = 'acceptance-key',
}) => DeliveryAcceptanceCommand(
  requestId: requestId,
  riderId: riderId,
  idempotencyKey: key,
);

Future<DeliveryAcceptanceFailure> captureAcceptanceFailure(
  Future<DeliveryAcceptanceReceipt> future,
) async {
  try {
    await future;
  } on DeliveryAcceptanceException catch (error) {
    return error.failure;
  }
  throw StateError('Expected acceptance to fail.');
}
