import 'package:agresell_app/features/rider/deliveries/domain/delivery_payment.dart';
import 'package:agresell_app/features/rider/deliveries/domain/delivery_request.dart';
import 'package:agresell_app/features/rider/deliveries/domain/delivery_request_metadata.dart';
import 'package:agresell_app/features/rider/deliveries/domain/delivery_stage.dart';
import 'package:agresell_app/features/rider/deliveries/domain/rider_acceptance_state.dart';
import 'package:agresell_app/features/rider/deliveries/domain/rider_delivery_search.dart';
import 'package:agresell_app/features/rider/profile/domain/rider_profile.dart';

final batchNow = DateTime(2032, 1, 1, 8);

DeliveryRequest batchRequest({
  required String id,
  double weightKg = 20,
  double pickupLatitude = 8.481,
  double pickupLongitude = 124.651,
  double deliveryLatitude = 8.49,
  double deliveryLongitude = 124.66,
  Duration pickupWindow = const Duration(hours: 2),
  Duration deliveryWindow = const Duration(hours: 4),
  DeliveryStage stage = DeliveryStage.readyForPickup,
  String? assignedRiderId,
  String compatibilityGroup = 'produce',
  bool exclusive = false,
  List<ProductHandlingRequirement> handling = const [],
  double earning = 180,
  CashOnDeliveryRequirement? cashOnDelivery,
}) => DeliveryRequest(
  id: id,
  orderNumber: 'ORD-$id',
  productName: 'Product $id',
  productCategory: 'Produce',
  sellerName: 'Seller $id',
  buyerName: 'Buyer $id',
  pickupLocation: DeliveryLocation(
    address: 'Pickup $id',
    latitude: pickupLatitude,
    longitude: pickupLongitude,
  ),
  deliveryLocation: DeliveryLocation(
    address: 'Delivery $id',
    latitude: deliveryLatitude,
    longitude: deliveryLongitude,
  ),
  pickupDeadline: batchNow.add(pickupWindow),
  deliveryDeadline: batchNow.add(deliveryWindow),
  availableAt: batchNow.subtract(const Duration(minutes: 5)),
  expiresAt: batchNow.add(const Duration(hours: 1)),
  serviceArea: 'Cagayan de Oro',
  totalWeightKg: weightKg,
  requiredCapacityKg: weightKg,
  requiredVehicleTypes: const {RiderVehicleType.motorcycle},
  handlingRequirements: handling,
  transportCompatibilityGroup: compatibilityGroup,
  requiresExclusiveTransport: exclusive,
  distanceKm: 1,
  estimatedTravelMinutes: 5,
  pickupToDeliveryDistanceKm: 2,
  pickupToDeliveryMinutes: 10,
  deliveryFee: earning,
  cashOnDelivery: cashOnDelivery,
  paymentMethod: cashOnDelivery == null ? 'prepaid' : 'cash_on_delivery',
  stage: stage,
  assignedRiderId: assignedRiderId,
);

RiderAcceptanceState batchRiderState({
  double capacityKg = 100,
  int maximumActiveDeliveries = 3,
}) => RiderAcceptanceState(
  riderId: 'rider-a',
  isAllowedToDeliver: true,
  availability: RiderAvailability.onlineAvailable,
  vehicleType: RiderVehicleType.motorcycle,
  activeDeliveryCount: 0,
  maximumActiveDeliveries: maximumActiveDeliveries,
  capacityKg: capacityKg,
  serviceArea: 'Cagayan de Oro',
  serviceRadiusKm: 20,
  registeredLatitude: 8.48,
  registeredLongitude: 124.65,
  location: const RiderDeliverySearch(latitude: 8.48, longitude: 124.65),
  gpsAccuracyMeters: 5,
  handlingCapabilityKeys: const {'fragileProtection', 'temperatureSensitive'},
);

RiderProfile batchRiderProfile() => const RiderProfile(
  id: 'rider-a',
  logisticCompanyId: null,
  licenseNumber: 'LICENSE-1',
  fullName: 'Batch Rider',
  firstName: 'Batch',
  lastName: 'Rider',
  vehicleType: RiderVehicleType.motorcycle,
  vehiclePlateNumber: 'BATCH-1',
  availabilityStatus: RiderAvailability.offline,
  rating: 4.9,
  contactNumber: '09123456789',
  email: 'batch@example.com',
  gpsLatitude: 8.48,
  gpsLongitude: 124.65,
  totalDeliveries: 10,
  employmentStatus: RiderEmploymentStatus.active,
  profilePhotoUrl: null,
  serviceArea: 'Cagayan de Oro',
  serviceRadiusKm: 20,
  capacityKg: 100,
  handlingCapabilityKeys: {'fragileProtection', 'temperatureSensitive'},
  maximumActiveDeliveries: 3,
);
