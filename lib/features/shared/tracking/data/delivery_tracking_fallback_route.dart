import 'dart:math' as math;
import 'package:latlong2/latlong.dart';

/// Helper to generate fallback routes and calculate distance when routing service is unavailable.
abstract final class DeliveryTrackingFallbackRoute {
  static List<LatLng> createPoints({
    required LatLng start,
    required LatLng end,
    LatLng? pickup,
  }) {
    final points = <LatLng>[];
    points.add(start);
    if (pickup != null) {
      final midPickup = LatLng(
        (start.latitude + pickup.latitude) / 2 + 0.001,
        (start.longitude + pickup.longitude) / 2 - 0.001,
      );
      points.add(midPickup);
      points.add(pickup);
      final midEnd = LatLng(
        (pickup.latitude + end.latitude) / 2 - 0.001,
        (pickup.longitude + end.longitude) / 2 + 0.001,
      );
      points.add(midEnd);
    } else {
      final mid = LatLng(
        (start.latitude + end.latitude) / 2 + 0.0015,
        (start.longitude + end.longitude) / 2 - 0.0015,
      );
      points.add(mid);
    }
    points.add(end);
    return points;
  }

  static double calculateDistanceKm(List<LatLng> points) {
    if (points.length < 2) return 0.0;
    const distanceCalculator = Distance();
    double totalMeters = 0;
    for (var i = 0; i < points.length - 1; i++) {
      totalMeters += distanceCalculator.as(
        LengthUnit.Meter,
        points[i],
        points[i + 1],
      );
    }
    return totalMeters / 1000;
  }

  static int estimateMinutes(double distanceKm) =>
      math.max(5, (distanceKm * 3.5).ceil());
}
