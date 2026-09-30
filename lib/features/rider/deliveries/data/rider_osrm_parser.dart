import 'package:agresell_app/features/rider/deliveries/data/rider_routing_service.dart';
import 'package:agresell_app/features/shared/routing/domain/delivery_route.dart';
import 'package:agresell_app/features/rider/deliveries/domain/rider_route_plan.dart';

List<RiderRoutePlan> parseOsrmRiderRoutes(
  Object? decoded, {
  required String requestId,
  required String destinationKey,
}) {
  final root = _object(decoded);
  if (root['code'] != 'Ok') {
    throw RiderRoutingException(
      root['message'] as String? ?? 'No accessible driving route was found.',
    );
  }
  final waypoints = _objects(root['waypoints']);
  final rawRoutes = _objects(root['routes']);
  if (waypoints.length < 2 || rawRoutes.isEmpty) {
    throw const RiderRoutingException('No accessible driving route was found.');
  }
  final candidates = <_RouteCandidate>[
    for (var index = 0; index < rawRoutes.length; index++)
      _RouteCandidate.fromJson(index, rawRoutes[index]),
  ];
  final fastest = candidates.reduce(
    (a, b) => a.durationSeconds <= b.durationSeconds ? a : b,
  );
  final shortest = candidates.reduce(
    (a, b) => a.distanceMeters <= b.distanceMeters ? a : b,
  );
  final ordered = <(RiderRoutePreference, _RouteCandidate)>[
    (RiderRoutePreference.fastest, fastest),
    if (shortest.index != fastest.index)
      (RiderRoutePreference.shortest, shortest),
    for (final candidate in candidates)
      if (candidate.index != fastest.index && candidate.index != shortest.index)
        (RiderRoutePreference.alternative, candidate),
  ];
  return [
    for (final item in ordered)
      item.$2.toPlan(
        preference: item.$1,
        requestId: requestId,
        destinationKey: destinationKey,
        waypoints: waypoints,
      ),
  ];
}

class _RouteCandidate {
  const _RouteCandidate({
    required this.index,
    required this.distanceMeters,
    required this.durationSeconds,
    required this.points,
    required this.instructions,
  });

  factory _RouteCandidate.fromJson(int index, Map<String, Object?> json) {
    final coordinates = _lists(_object(json['geometry'])['coordinates']);
    final distance = _number(json['distance']);
    final duration = _number(json['duration']);
    if (coordinates.length < 2 || distance <= 0 || duration <= 0) {
      throw const RiderRoutingException('Road route geometry is empty.');
    }
    return _RouteCandidate(
      index: index,
      distanceMeters: distance,
      durationSeconds: duration,
      points: [for (final coordinate in coordinates) _point(coordinate)],
      instructions: [
        for (final leg in _objects(json['legs']))
          for (final step in _objects(leg['steps'])) _instruction(step),
      ],
    );
  }

  final int index;
  final double distanceMeters;
  final double durationSeconds;
  final List<DeliveryRoutePoint> points;
  final List<RiderRouteInstruction> instructions;

  RiderRoutePlan toPlan({
    required RiderRoutePreference preference,
    required String requestId,
    required String destinationKey,
    required List<Map<String, Object?>> waypoints,
  }) {
    final origin = waypoints.first;
    final destination = waypoints.last;
    return RiderRoutePlan(
      id: '$destinationKey-$index-${distanceMeters.round()}',
      requestId: requestId,
      destinationKey: destinationKey,
      preference: preference,
      distanceKm: distanceMeters / 1000,
      estimatedTravelMinutes: (durationSeconds / 60).ceil(),
      snappedOrigin: _point(_list(origin['location'])),
      snappedDestination: _point(_list(destination['location'])),
      originRoadName: origin['name'] as String? ?? '',
      destinationRoadName: destination['name'] as String? ?? '',
      calculatedAt: DateTime.now(),
      points: points,
      instructions: instructions,
    );
  }
}

RiderRouteInstruction _instruction(Map<String, Object?> step) {
  final maneuver = _object(step['maneuver']);
  final type = maneuver['type'] as String? ?? 'continue';
  final modifier = (maneuver['modifier'] as String? ?? '').replaceAll('_', ' ');
  final road = step['name'] as String? ?? '';
  final action = switch (type) {
    'depart' => 'Start',
    'arrive' => 'Arrive at the destination',
    'turn' => 'Turn $modifier',
    'merge' => 'Merge $modifier',
    'fork' => 'Keep $modifier',
    'roundabout' || 'rotary' => 'Enter the roundabout',
    _ => 'Continue${modifier.isEmpty ? '' : ' $modifier'}',
  };
  return RiderRouteInstruction(
    text: road.isEmpty || type == 'arrive' ? action : '$action onto $road',
    distanceMeters: _number(step['distance']),
    durationSeconds: _number(step['duration']),
    maneuverPoint: _optionalPoint(maneuver['location']),
    maneuverType: type,
    maneuverModifier: modifier,
  );
}

DeliveryRoutePoint? _optionalPoint(Object? value) {
  if (value is! List || value.length < 2) return null;
  return _point(List<Object?>.from(value));
}

DeliveryRoutePoint _point(List<Object?> value) {
  if (value.length < 2) {
    throw const RiderRoutingException('Road route coordinate is malformed.');
  }
  return DeliveryRoutePoint(
    longitude: _number(value[0]),
    latitude: _number(value[1]),
  );
}

double _number(Object? value) => (value as num).toDouble();
Map<String, Object?> _object(Object? value) =>
    Map<String, Object?>.from(value as Map);
List<Object?> _list(Object? value) => List<Object?>.from(value as List);
List<List<Object?>> _lists(Object? value) => [
  for (final item in value as List) _list(item),
];
List<Map<String, Object?>> _objects(Object? value) => [
  for (final item in value as List) _object(item),
];
