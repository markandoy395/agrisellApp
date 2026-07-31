import 'package:agresell_app/features/rider/deliveries/domain/delivery_proof.dart';
import 'package:agresell_app/features/rider/deliveries/domain/delivery_errors.dart';
import 'package:agresell_app/features/rider/deliveries/domain/delivery_outcome.dart';
import 'package:agresell_app/features/rider/deliveries/domain/delivery_payment.dart';
import 'package:agresell_app/features/rider/deliveries/domain/delivery_location.dart';
import 'package:agresell_app/features/rider/deliveries/domain/delivery_priority.dart';
import 'package:agresell_app/features/rider/deliveries/domain/delivery_route.dart';
import 'package:agresell_app/features/rider/deliveries/domain/delivery_request_metadata.dart';
import 'package:agresell_app/features/rider/deliveries/domain/delivery_stage.dart';
import 'package:agresell_app/features/rider/profile/domain/rider_registration.dart';

export 'package:agresell_app/features/rider/deliveries/domain/delivery_location.dart';
export 'package:agresell_app/features/rider/deliveries/domain/delivery_priority.dart';

part 'delivery_request_actions.dart';

class DeliveryRequest {
  DeliveryRequest({
    required this.id,
    required this.orderNumber,
    required this.productName,
    required this.sellerName,
    required this.buyerName,
    required this.pickupLocation,
    required this.deliveryLocation,
    required this.pickupDeadline,
    this.productImageUrl,
    this.quantityDescription = '',
    this.productCategory = '',
    this.productDescription = '',
    this.totalWeightKg,
    this.packageDimensions,
    this.distanceKm,
    this.estimatedTravelMinutes,
    this.pickupToDeliveryDistanceKm,
    this.pickupToDeliveryMinutes,
    this.deliveryFee = 0,
    this.feeBreakdown,
    this.priority = DeliveryPriority.standard,
    this.paymentMethod = '',
    this.cashOnDelivery,
    this.pickupInstructions = '',
    this.deliveryInstructions = '',
    this.deliveryDeadline,
    this.availableAt,
    this.expiresAt,
    this.serviceArea = '',
    this.requiredCapacityKg,
    Iterable<RiderVehicleType> requiredVehicleTypes = const [],
    Iterable<ProductHandlingRequirement> handlingRequirements = const [],
    this.cancellationConditions = '',
    this.transportCompatibilityGroup = '',
    this.requiresExclusiveTransport = false,
    this.route,
    this.stage = DeliveryStage.readyForPickup,
    this.assignedRiderId,
    this.reservedRiderId,
    this.reservedUntil,
    this.outcome,
    this.closedAt,
    Iterable<DeliveryProof> proofs = const <DeliveryProof>[],
    Iterable<String> declinedRiderIds = const <String>[],
  }) : assert(id.trim().isNotEmpty),
       assert(orderNumber.trim().isNotEmpty),
       proofs = List<DeliveryProof>.unmodifiable(proofs),
       requiredVehicleTypes = Set<RiderVehicleType>.unmodifiable(
         requiredVehicleTypes,
       ),
       handlingRequirements = List<ProductHandlingRequirement>.unmodifiable(
         handlingRequirements,
       ),
       declinedRiderIds = Set<String>.unmodifiable(declinedRiderIds);

  final String id;
  final String orderNumber;
  final String productName;
  final String sellerName;
  final String buyerName;
  final DeliveryLocation pickupLocation;
  final DeliveryLocation deliveryLocation;
  final DateTime pickupDeadline;
  final String? productImageUrl;
  final String quantityDescription;
  final String productCategory;
  final String productDescription;
  final double? totalWeightKg;
  final PackageDimensions? packageDimensions;
  final double? distanceKm;
  final int? estimatedTravelMinutes;
  final double? pickupToDeliveryDistanceKm;
  final int? pickupToDeliveryMinutes;
  final double deliveryFee;
  final DeliveryFeeBreakdown? feeBreakdown;
  final DeliveryPriority priority;
  final String paymentMethod;
  final CashOnDeliveryRequirement? cashOnDelivery;
  final String pickupInstructions;
  final String deliveryInstructions;
  final DateTime? deliveryDeadline;
  final DateTime? availableAt;
  final DateTime? expiresAt;
  final String serviceArea;
  final double? requiredCapacityKg;
  final Set<RiderVehicleType> requiredVehicleTypes;
  final List<ProductHandlingRequirement> handlingRequirements;
  final String cancellationConditions;
  final String transportCompatibilityGroup;
  final bool requiresExclusiveTransport;
  final DeliveryRouteInfo? route;
  final DeliveryStage stage;
  final String? assignedRiderId;
  final String? reservedRiderId;
  final DateTime? reservedUntil;
  final DeliveryOutcome? outcome;
  final DateTime? closedAt;
  final List<DeliveryProof> proofs;
  final Set<String> declinedRiderIds;

  bool isAssignedTo(String riderId) => assignedRiderId == riderId;
  bool get isCashOnDelivery =>
      cashOnDelivery != null ||
      RiderPaymentMethodDetails.fromBackendValue(paymentMethod) ==
          RiderPaymentMethod.cashOnDelivery;
  bool isDeclinedBy(String riderId) => declinedRiderIds.contains(riderId);

  bool isAvailableTo(String riderId, {DateTime? at}) {
    final now = at ?? DateTime.now();
    return stage == DeliveryStage.readyForPickup &&
        assignedRiderId == null &&
        (expiresAt == null || expiresAt!.isAfter(now)) &&
        (reservedRiderId == null ||
            reservedRiderId == riderId ||
            reservedUntil == null ||
            !reservedUntil!.isAfter(now)) &&
        !isDeclinedBy(riderId);
  }

  bool isVisibleTo(String riderId) =>
      isAvailableTo(riderId) || isAssignedTo(riderId);

  double? get routeDistanceKm => route?.distanceKm ?? distanceKm;

  int? get routeEstimatedTravelMinutes =>
      route?.estimatedTravelMinutes ?? estimatedTravelMinutes;

  double? get totalTripDistanceKm =>
      routeDistanceKm == null || pickupToDeliveryDistanceKm == null
      ? null
      : routeDistanceKm! + pickupToDeliveryDistanceKm!;

  int? get totalTripMinutes =>
      routeEstimatedTravelMinutes == null || pickupToDeliveryMinutes == null
      ? null
      : routeEstimatedTravelMinutes! + pickupToDeliveryMinutes!;
}
