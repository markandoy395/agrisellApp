import 'package:agresell_app/features/rider/dashboard/domain/rider_availability.dart';
import 'package:agresell_app/features/rider/deliveries/domain/rider_delivery_search.dart';
import 'package:agresell_app/features/rider/deliveries/domain/rider_matching_context.dart';
import 'package:agresell_app/features/rider/deliveries/domain/rider_request_query.dart';
import 'package:agresell_app/features/rider/profile/domain/rider_registration.dart';

/// Server-owned Rider facts used during acceptance revalidation.
/// Clients send only Rider/request identity and an idempotency key.
class RiderAcceptanceState {
  const RiderAcceptanceState({
    required this.riderId,
    required this.isAllowedToDeliver,
    required this.availability,
    required this.vehicleType,
    required this.activeDeliveryCount,
    this.maximumActiveDeliveries = 1,
    this.capacityKg,
    this.serviceArea = '',
    this.serviceRadiusKm,
    this.registeredLatitude,
    this.registeredLongitude,
    this.location,
    this.gpsAccuracyMeters,
    this.maximumGpsAccuracyMeters = 50,
    this.handlingCapabilityKeys = const <String>{},
    this.conflictingDeliveryId,
  });

  final String riderId;
  final bool isAllowedToDeliver;
  final RiderAvailability availability;
  final RiderVehicleType vehicleType;
  final double? capacityKg;
  final String serviceArea;
  final double? serviceRadiusKm;
  final double? registeredLatitude;
  final double? registeredLongitude;
  final RiderDeliverySearch? location;
  final double? gpsAccuracyMeters;
  final double maximumGpsAccuracyMeters;
  final int activeDeliveryCount;
  final int maximumActiveDeliveries;
  final Set<String> handlingCapabilityKeys;
  final String? conflictingDeliveryId;

  RiderMatchingContext get matching => RiderMatchingContext(
    riderId: riderId,
    availability: availability,
    vehicleType: vehicleType,
    capacityKg: capacityKg,
    serviceArea: serviceArea,
    serviceRadiusKm: serviceRadiusKm,
    registeredLatitude: registeredLatitude,
    registeredLongitude: registeredLongitude,
    location: location,
    gpsAccuracyMeters: gpsAccuracyMeters,
    maximumGpsAccuracyMeters: maximumGpsAccuracyMeters,
    activeDeliveryCount: activeDeliveryCount,
    maximumActiveDeliveries: maximumActiveDeliveries,
    handlingCapabilityKeys: handlingCapabilityKeys,
  );

  RiderAcceptanceState reserve(String deliveryId) => RiderAcceptanceState(
    riderId: riderId,
    isAllowedToDeliver: isAllowedToDeliver,
    availability: RiderAvailability.deliveryReserved,
    vehicleType: vehicleType,
    activeDeliveryCount: activeDeliveryCount + 1,
    maximumActiveDeliveries: maximumActiveDeliveries,
    capacityKg: capacityKg,
    serviceArea: serviceArea,
    serviceRadiusKm: serviceRadiusKm,
    registeredLatitude: registeredLatitude,
    registeredLongitude: registeredLongitude,
    location: location,
    gpsAccuracyMeters: gpsAccuracyMeters,
    maximumGpsAccuracyMeters: maximumGpsAccuracyMeters,
    handlingCapabilityKeys: handlingCapabilityKeys,
    conflictingDeliveryId: maximumActiveDeliveries > 1 ? null : deliveryId,
  );

  RiderAcceptanceState release() => RiderAcceptanceState(
    riderId: riderId,
    isAllowedToDeliver: isAllowedToDeliver,
    availability: activeDeliveryCount <= 1
        ? RiderAvailability.onlineAvailable
        : RiderAvailability.deliveryReserved,
    vehicleType: vehicleType,
    activeDeliveryCount: (activeDeliveryCount - 1).clamp(
      0,
      maximumActiveDeliveries,
    ),
    maximumActiveDeliveries: maximumActiveDeliveries,
    capacityKg: capacityKg,
    serviceArea: serviceArea,
    serviceRadiusKm: serviceRadiusKm,
    registeredLatitude: registeredLatitude,
    registeredLongitude: registeredLongitude,
    location: location,
    gpsAccuracyMeters: gpsAccuracyMeters,
    maximumGpsAccuracyMeters: maximumGpsAccuracyMeters,
    handlingCapabilityKeys: handlingCapabilityKeys,
  );
}
