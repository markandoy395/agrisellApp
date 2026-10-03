part of 'rider_route_controller.dart';

extension RiderRouteControllerMetrics on RiderRouteController {
  double get progressFraction {
    final route = activeRoute;
    final location = _lastLocation;
    if (route == null || location == null) return 0;
    return routeProgressFraction(location, route.points);
  }

  double get remainingDistanceKm {
    final route = activeRoute;
    final location = _lastLocation;
    if (route == null || location == null) return route?.distanceKm ?? 0;
    return remainingRouteDistanceMeters(location, route.points) / 1000;
  }

  int get remainingTravelMinutes {
    final route = activeRoute;
    if (route == null) return 0;
    return (route.estimatedTravelMinutes * (1 - progressFraction)).ceil().clamp(
      0,
      route.estimatedTravelMinutes,
    );
  }

  DateTime? get estimatedArrival => activeRoute == null
      ? null
      : DateTime.now().add(Duration(minutes: remainingTravelMinutes));

  RiderRouteInstruction? get nextInstruction {
    final route = activeRoute;
    if (route == null || route.instructions.isEmpty) return null;
    final location = _lastLocation;
    if (location == null || route.points.length < 2) {
      return route.instructions.first;
    }
    final progress = routeProgressFraction(location, route.points);
    for (final instruction in route.instructions) {
      final maneuverPoint = instruction.maneuverPoint;
      if (maneuverPoint == null) continue;
      final maneuverProgress = routeProgressFraction(
        maneuverPoint,
        route.points,
      );
      if (maneuverProgress > progress + 0.002) return instruction;
    }
    return route.instructions.last;
  }

  double get distanceToNextInstructionMeters {
    final route = activeRoute;
    final location = _lastLocation;
    final maneuverPoint = nextInstruction?.maneuverPoint;
    if (route == null || location == null || maneuverPoint == null) return 0;
    final currentProgress = routeProgressFraction(location, route.points);
    final maneuverProgress = routeProgressFraction(maneuverPoint, route.points);
    return ((maneuverProgress - currentProgress) * route.distanceKm * 1000)
        .clamp(0.0, double.infinity)
        .toDouble();
  }

  double get offRouteDistanceMeters {
    final route = activeRoute;
    final location = _lastLocation;
    if (route == null || location == null) return 0;
    return distanceFromRouteMeters(location, route.points);
  }
}
