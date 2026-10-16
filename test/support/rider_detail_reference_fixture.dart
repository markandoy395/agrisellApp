import 'package:agresell_app/features/rider/deliveries/domain/delivery_request.dart';
import 'package:agresell_app/features/rider/deliveries/domain/delivery_stage.dart';
import 'package:agresell_app/features/rider/deliveries/domain/delivery_payment.dart';
import 'package:agresell_app/features/rider/deliveries/domain/delivery_request_metadata.dart';
import 'package:agresell_app/features/rider/deliveries/domain/delivery_proof.dart';
import 'package:agresell_app/features/rider/profile/domain/rider_registration.dart';
import 'package:agresell_app/features/shared/routing/domain/delivery_route.dart';

DeliveryRequest referenceDetailRequest({
  bool active = false,
  bool geometry = true,
}) => DeliveryRequest(
  id: 'delivery-reference',
  orderNumber: '#AG-2030-00521',
  productName: 'Fresh Vegetables Box (5kg)',
  productCategory: 'Vegetables',
  productImageUrl: 'assets/images/vege.jpeg',
  productDescription:
      'Assorted fresh farm vegetables. Keep in a cool and dry condition.',
  sellerName: 'Dela Cruz Farm',
  buyerName: 'Rivera Residence',
  pickupLocation: const DeliveryLocation(
    address: 'San Jose Farmers Market, San Jose, Nueva Ecija',
    latitude: 15.49,
    longitude: 120.97,
  ),
  deliveryLocation: const DeliveryLocation(
    address: 'Rivera Residence, Cabanatuan City, Nueva Ecija',
    latitude: 15.48,
    longitude: 120.98,
  ),
  pickupDeadline: DateTime(2030, 4, 22, 10),
  deliveryDeadline: DateTime(2030, 4, 22, 12),
  expiresAt: DateTime(2030, 4, 22, 9, 30),
  distanceKm: 2.4,
  estimatedTravelMinutes: 8,
  pickupToDeliveryDistanceKm: 6.8,
  pickupToDeliveryMinutes: 18,
  quantityDescription: '1 box',
  totalWeightKg: 5,
  packageDimensions: const PackageDimensions(
    lengthCm: 30,
    widthCm: 20,
    heightCm: 15,
  ),
  pickupInstructions: 'Look for the stall near the main gate.',
  deliveryInstructions: 'Leave at the gate and contact the buyer.',
  deliveryFee: 80,
  feeBreakdown: const DeliveryFeeBreakdown(
    baseFee: 60,
    pickupDistanceFee: 15,
    productWeightFee: 5,
  ),
  requiredVehicleTypes: const {RiderVehicleType.motorcycle},
  requiredCapacityKg: 30,
  handlingRequirements: const [
    ProductHandlingRequirement(type: ProductHandlingType.perishable),
  ],
  cashOnDelivery: const CashOnDeliveryRequirement(amountToCollect: 1250),
  paymentMethod: 'Cash on Delivery',
  priority: DeliveryPriority.high,
  cancellationConditions: 'May be cancelled if not accepted before expiry.',
  stage: active ? DeliveryStage.goingToPickup : DeliveryStage.readyForPickup,
  assignedRiderId: active ? 'rider-a' : null,
  route: geometry
      ? DeliveryRouteInfo(
          distanceKm: 2.4,
          estimatedTravelMinutes: 8,
          points: const [
            DeliveryRoutePoint(latitude: 15.489, longitude: 120.965),
            DeliveryRoutePoint(latitude: 15.49, longitude: 120.968),
            DeliveryRoutePoint(latitude: 15.49, longitude: 120.97),
          ],
        )
      : null,
  proofs: active
      ? [
          DeliveryProof(
            id: 'proof',
            type: DeliveryProofType.productPhoto,
            secureReference: 'https://example.invalid/evidence.jpg',
            capturedAt: DateTime(2030, 4, 22, 9, 32),
            latitude: 15.49,
            longitude: 120.97,
          ),
        ]
      : [],
);
