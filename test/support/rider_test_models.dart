import 'package:agresell_app/features/rider/deliveries/domain/delivery_request.dart';
import 'package:agresell_app/features/rider/deliveries/domain/delivery_stage.dart';
import 'package:agresell_app/features/rider/profile/domain/rider_profile.dart';

RiderProfile verifiedRiderProfile() => const RiderProfile(
  id: 'rider-a',
  logisticCompanyId: null,
  licenseNumber: 'LICENSE-1',
  fullName: 'Rider One',
  firstName: 'Rider',
  lastName: 'One',
  vehicleType: RiderVehicleType.motorcycle,
  vehiclePlateNumber: 'ABC123',
  availabilityStatus: RiderAvailability.offline,
  rating: 4.8,
  contactNumber: '09123456789',
  email: 'rider@example.com',
  gpsLatitude: 8.48,
  gpsLongitude: 124.65,
  totalDeliveries: 10,
  employmentStatus: RiderEmploymentStatus.active,
  profilePhotoUrl: null,
  serviceArea: 'Cagayan de Oro',
  serviceRadiusKm: 15,
  capacityKg: 150,
);

DeliveryRequest assignedDeliveryRequest() => DeliveryRequest(
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
