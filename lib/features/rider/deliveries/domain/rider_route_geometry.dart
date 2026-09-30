import 'dart:math' as math;

import 'package:agresell_app/features/shared/routing/domain/delivery_route.dart';

const _earthRadiusMeters = 6371000.0;

double routePointDistanceMeters(
  DeliveryRoutePoint first,
  DeliveryRoutePoint second,
) {
  final latitudeDelta = _radians(second.latitude - first.latitude);
  final longitudeDelta = _radians(second.longitude - first.longitude);
  final firstLatitude = _radians(first.latitude);
  final secondLatitude = _radians(second.latitude);
  final value =
      math.sin(latitudeDelta / 2) * math.sin(latitudeDelta / 2) +
      math.cos(firstLatitude) *
          math.cos(secondLatitude) *
          math.sin(longitudeDelta / 2) *
          math.sin(longitudeDelta / 2);
  return _earthRadiusMeters *
      2 *
      math.atan2(math.sqrt(value), math.sqrt(1 - value));
}

DeliveryRoutePoint nearestPointOnRoute(
  DeliveryRoutePoint point,
  List<DeliveryRoutePoint> route,
) {
  if (route.length < 2) return route.isEmpty ? point : route.first;
  var nearest = route.first;
  var nearestDistance = double.infinity;
  for (var index = 0; index < route.length - 1; index++) {
    final candidate = _nearestPointOnSegment(
      point,
      route[index],
      route[index + 1],
    );
    final distance = routePointDistanceMeters(point, candidate);
    if (distance < nearestDistance) {
      nearest = candidate;
      nearestDistance = distance;
    }
  }
  return nearest;
}

double distanceFromRouteMeters(
  DeliveryRoutePoint point,
  List<DeliveryRoutePoint> route,
) => routePointDistanceMeters(point, nearestPointOnRoute(point, route));

double routeProgressFraction(
  DeliveryRoutePoint point,
  List<DeliveryRoutePoint> route,
) {
  if (route.length < 2) return route.isEmpty ? 0 : 1;
  var total = 0.0;
  for (var index = 0; index < route.length - 1; index++) {
    total += routePointDistanceMeters(route[index], route[index + 1]);
  }
  if (total == 0) return 1;
  var before = 0.0;
  var nearestDistance = double.infinity;
  var progress = 0.0;
  for (var index = 0; index < route.length - 1; index++) {
    final start = route[index];
    final end = route[index + 1];
    final candidate = _nearestPointOnSegment(point, start, end);
    final distance = routePointDistanceMeters(point, candidate);
    if (distance < nearestDistance) {
      nearestDistance = distance;
      final segment = routePointDistanceMeters(start, end);
      final travelled = routePointDistanceMeters(start, candidate);
      progress = (before + travelled.clamp(0, segment)) / total;
    }
    before += routePointDistanceMeters(start, end);
  }
  return progress.clamp(0.0, 1.0);
}

double remainingRouteDistanceMeters(
  DeliveryRoutePoint point,
  List<DeliveryRoutePoint> route,
) {
  if (route.length < 2) return 0;
  var total = 0.0;
  for (var index = 0; index < route.length - 1; index++) {
    total += routePointDistanceMeters(route[index], route[index + 1]);
  }
  return total * (1 - routeProgressFraction(point, route));
}

DeliveryRoutePoint _nearestPointOnSegment(
  DeliveryRoutePoint point,
  DeliveryRoutePoint start,
  DeliveryRoutePoint end,
) {
  final latitudeScale = math.cos(_radians(point.latitude));
  final x = point.longitude * latitudeScale;
  final y = point.latitude;
  final startX = start.longitude * latitudeScale;
  final endX = end.longitude * latitudeScale;
  final deltaX = endX - startX;
  final deltaY = end.latitude - start.latitude;
  final lengthSquared = deltaX * deltaX + deltaY * deltaY;
  if (lengthSquared == 0) return start;
  final ratio =
      (((x - startX) * deltaX + (y - start.latitude) * deltaY) / lengthSquared)
          .clamp(0.0, 1.0);
  return DeliveryRoutePoint(
    latitude: start.latitude + deltaY * ratio,
    longitude: start.longitude + (end.longitude - start.longitude) * ratio,
  );
}

double _radians(double degrees) => degrees * math.pi / 180;
