import 'dart:math' as math;

class RiderDeliverySearch {
  const RiderDeliverySearch({
    required this.latitude,
    required this.longitude,
    this.radiusKm = 15,
  }) : assert(radiusKm > 0);

  final double latitude;
  final double longitude;
  final double radiusKm;

  /// Nearby requests do not need a new fetch for every small GPS movement.
  bool hasMovedBeyond(
    RiderDeliverySearch other, {
    double distanceMeters = 250,
  }) {
    final latitudeDelta = _toRadians(latitude - other.latitude);
    final longitudeDelta = _toRadians(longitude - other.longitude);
    final latitudeRadians = _toRadians(latitude);
    final otherLatitudeRadians = _toRadians(other.latitude);
    final haversine =
        math.sin(latitudeDelta / 2) * math.sin(latitudeDelta / 2) +
        math.cos(latitudeRadians) *
            math.cos(otherLatitudeRadians) *
            math.sin(longitudeDelta / 2) *
            math.sin(longitudeDelta / 2);
    final distance =
        12742000 * math.atan2(math.sqrt(haversine), math.sqrt(1 - haversine));
    return distance > distanceMeters || radiusKm != other.radiusKm;
  }

  double distanceTo({required double latitude, required double longitude}) {
    final latitudeDelta = _toRadians(latitude - this.latitude);
    final longitudeDelta = _toRadians(longitude - this.longitude);
    final latitudeRadians = _toRadians(latitude);
    final currentLatitudeRadians = _toRadians(this.latitude);
    final haversine =
        math.sin(latitudeDelta / 2) * math.sin(latitudeDelta / 2) +
        math.cos(latitudeRadians) *
            math.cos(currentLatitudeRadians) *
            math.sin(longitudeDelta / 2) *
            math.sin(longitudeDelta / 2);
    return 6371 *
        2 *
        math.atan2(math.sqrt(haversine), math.sqrt(1 - haversine));
  }

  static double _toRadians(double degrees) => degrees * math.pi / 180;
}
