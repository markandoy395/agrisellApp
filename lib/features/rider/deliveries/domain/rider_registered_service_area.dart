import 'package:agresell_app/features/rider/deliveries/domain/delivery_request.dart';
import 'package:agresell_app/features/rider/deliveries/domain/rider_delivery_search.dart';

/// Registration-owned coverage data. This is deliberately separate from the
/// device's current GPS position used for distance and route estimates.
class RiderRegisteredServiceArea {
  const RiderRegisteredServiceArea({
    required this.name,
    required this.latitude,
    required this.longitude,
    required this.radiusKm,
  });

  final String name;
  final double? latitude;
  final double? longitude;
  final double? radiusKm;

  bool get hasName => name.trim().isNotEmpty;
  bool get hasCoordinates =>
      latitude != null &&
      longitude != null &&
      latitude!.isFinite &&
      longitude!.isFinite &&
      latitude! >= -90 &&
      latitude! <= 90 &&
      longitude! >= -180 &&
      longitude! <= 180;
  bool get hasValidRadius =>
      radiusKm != null && radiusKm!.isFinite && radiusKm! > 0;
  bool get isConfigured => hasName && hasCoordinates && hasValidRadius;

  RiderDeliverySearch? get center => hasCoordinates
      ? RiderDeliverySearch(
          latitude: latitude!,
          longitude: longitude!,
          radiusKm: radiusKm ?? 15,
        )
      : null;

  bool matchesArea(String requestArea) =>
      hasName && requestArea.trim().toLowerCase() == name.trim().toLowerCase();

  bool containsPickup(DeliveryLocation pickup) {
    final serviceCenter = center;
    if (serviceCenter == null || !pickup.hasCoordinates) return true;
    return serviceCenter.distanceTo(
          latitude: pickup.latitude!,
          longitude: pickup.longitude!,
        ) <=
        radiusKm!;
  }

  bool containsCurrentLocation(RiderDeliverySearch location) {
    final serviceCenter = center;
    return serviceCenter != null &&
        serviceCenter.distanceTo(
              latitude: location.latitude,
              longitude: location.longitude,
            ) <=
            radiusKm!;
  }
}
