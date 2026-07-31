class DeliveryRoutePoint {
  const DeliveryRoutePoint({required this.latitude, required this.longitude});

  final double latitude;
  final double longitude;
}

/// Route information calculated by the routing service, when available.
class DeliveryRouteInfo {
  DeliveryRouteInfo({
    required this.distanceKm,
    required this.estimatedTravelMinutes,
    Iterable<DeliveryRoutePoint> points = const [],
    this.trafficSummary,
  }) : points = List<DeliveryRoutePoint>.unmodifiable(points);

  final double distanceKm;
  final int estimatedTravelMinutes;
  final List<DeliveryRoutePoint> points;
  final String? trafficSummary;

  bool get hasGeometry => points.length > 1;
}
