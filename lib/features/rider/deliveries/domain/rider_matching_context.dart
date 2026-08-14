import 'package:agresell_app/features/rider/dashboard/domain/rider_availability.dart';
import 'package:agresell_app/features/rider/deliveries/domain/delivery_request.dart';
import 'package:agresell_app/features/rider/deliveries/domain/rider_delivery_search.dart';
import 'package:agresell_app/features/rider/deliveries/domain/rider_registered_service_area.dart';
import 'package:agresell_app/features/rider/profile/domain/rider_registration.dart';

/// Separates registration-owned coverage from the Rider's current device GPS.
class RiderMatchingContext {
  const RiderMatchingContext({
    required this.riderId,
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
    this.allowRegisteredLocationEstimate = false,
    this.handlingCapabilityKeys = const <String>{},
  });

  final String riderId;
  final RiderAvailability availability;
  final RiderVehicleType vehicleType;
  final double? capacityKg;
  final String serviceArea;
  final double? serviceRadiusKm;
  final double? registeredLatitude;
  final double? registeredLongitude;

  /// Current device GPS only. It must never be replaced by registration GPS.
  final RiderDeliverySearch? location;
  final double? gpsAccuracyMeters;
  final double maximumGpsAccuracyMeters;
  final bool allowRegisteredLocationEstimate;
  final int activeDeliveryCount;
  final int maximumActiveDeliveries;
  final Set<String> handlingCapabilityKeys;

  RiderRegisteredServiceArea get registeredServiceArea =>
      RiderRegisteredServiceArea(
        name: serviceArea,
        latitude: registeredLatitude,
        longitude: registeredLongitude,
        radiusKm: serviceRadiusKm,
      );

  bool get hasUsableCurrentGps =>
      location != null &&
      gpsAccuracyMeters != null &&
      gpsAccuracyMeters! <= maximumGpsAccuracyMeters;

  bool get usesRegisteredLocationEstimate =>
      location == null && allowRegisteredLocationEstimate;

  RiderDeliverySearch? get estimateOrigin =>
      location ??
      (usesRegisteredLocationEstimate ? registeredServiceArea.center : null);

  double? pickupDistanceKm(DeliveryRequest request) {
    final origin = estimateOrigin;
    if (origin == null || !request.pickupLocation.hasCoordinates) {
      return request.routeDistanceKm;
    }
    return origin.distanceTo(
      latitude: request.pickupLocation.latitude!,
      longitude: request.pickupLocation.longitude!,
    );
  }

  int? pickupTravelMinutes(DeliveryRequest request) {
    final routeDistance = request.routeDistanceKm;
    final routeMinutes = request.routeEstimatedTravelMinutes;
    final distance = pickupDistanceKm(request);
    if (routeDistance == null || routeDistance <= 0 || routeMinutes == null) {
      return routeMinutes;
    }
    if (distance == null) return routeMinutes;
    return (routeMinutes * distance / routeDistance).ceil().clamp(1, 1440);
  }

  bool get isCurrentLocationInsideRegisteredServiceArea =>
      location != null &&
      registeredServiceArea.containsCurrentLocation(location!);

  bool containsPickupFromCurrentLocation(DeliveryLocation pickup) {
    final currentLocation = location;
    if (currentLocation == null || !pickup.hasCoordinates) return true;
    return currentLocation.distanceTo(
          latitude: pickup.latitude!,
          longitude: pickup.longitude!,
        ) <=
        currentLocation.radiusKm;
  }
}
