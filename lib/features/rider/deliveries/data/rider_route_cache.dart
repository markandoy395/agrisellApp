import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import 'package:agresell_app/features/rider/deliveries/domain/delivery_route.dart';
import 'package:agresell_app/features/rider/deliveries/domain/rider_route_plan.dart';

class CachedRiderRoutes {
  const CachedRiderRoutes({required this.routes, required this.selectedIndex});
  final List<RiderRoutePlan> routes;
  final int selectedIndex;
}

class RiderRouteCache {
  RiderRouteCache({this.preferences});

  static const _key = 'active_rider_routes_v1';
  final SharedPreferences? preferences;

  Future<CachedRiderRoutes?> load() async {
    try {
      final encoded = (await _instance).getString(_key);
      if (encoded == null) return null;
      final json = Map<String, Object?>.from(jsonDecode(encoded) as Map);
      final routes = [
        for (final item in json['routes'] as List)
          _routeFromJson(Map<String, Object?>.from(item as Map)),
      ];
      if (routes.isEmpty) return null;
      final selected = (json['selectedIndex'] as num?)?.toInt() ?? 0;
      return CachedRiderRoutes(
        routes: routes,
        selectedIndex: selected.clamp(0, routes.length - 1),
      );
    } catch (_) {
      return null;
    }
  }

  Future<void> save(List<RiderRoutePlan> routes, int selectedIndex) async {
    if (routes.isEmpty) return;
    await (await _instance).setString(
      _key,
      jsonEncode({
        'selectedIndex': selectedIndex,
        'routes': [for (final route in routes) _routeToJson(route)],
      }),
    );
  }

  Future<void> clear() async => (await _instance).remove(_key);

  Future<SharedPreferences> get _instance async =>
      preferences ?? await SharedPreferences.getInstance();
}

Map<String, Object?> _routeToJson(RiderRoutePlan route) => {
  'id': route.id,
  'requestId': route.requestId,
  'destinationKey': route.destinationKey,
  'preference': route.preference.name,
  'distanceKm': route.distanceKm,
  'estimatedTravelMinutes': route.estimatedTravelMinutes,
  'snappedOrigin': _pointToJson(route.snappedOrigin),
  'snappedDestination': _pointToJson(route.snappedDestination),
  'originRoadName': route.originRoadName,
  'destinationRoadName': route.destinationRoadName,
  'calculatedAt': route.calculatedAt.toUtc().toIso8601String(),
  'points': [for (final point in route.points) _pointToJson(point)],
  'instructions': [
    for (final instruction in route.instructions)
      {
        'text': instruction.text,
        'distanceMeters': instruction.distanceMeters,
        'durationSeconds': instruction.durationSeconds,
        'maneuverPoint': instruction.maneuverPoint == null
            ? null
            : _pointToJson(instruction.maneuverPoint!),
        'maneuverType': instruction.maneuverType,
        'maneuverModifier': instruction.maneuverModifier,
      },
  ],
};

RiderRoutePlan _routeFromJson(Map<String, Object?> json) => RiderRoutePlan(
  id: json['id'] as String,
  requestId: json['requestId'] as String,
  destinationKey: json['destinationKey'] as String,
  preference: RiderRoutePreference.values.byName(json['preference'] as String),
  distanceKm: (json['distanceKm'] as num).toDouble(),
  estimatedTravelMinutes: (json['estimatedTravelMinutes'] as num).toInt(),
  snappedOrigin: _pointFromJson(json['snappedOrigin']),
  snappedDestination: _pointFromJson(json['snappedDestination']),
  originRoadName: json['originRoadName'] as String? ?? '',
  destinationRoadName: json['destinationRoadName'] as String? ?? '',
  calculatedAt: DateTime.parse(json['calculatedAt'] as String).toLocal(),
  points: [for (final item in json['points'] as List) _pointFromJson(item)],
  instructions: [
    for (final item in json['instructions'] as List)
      _instructionFromJson(Map<String, Object?>.from(item as Map)),
  ],
);

Map<String, double> _pointToJson(DeliveryRoutePoint point) => {
  'latitude': point.latitude,
  'longitude': point.longitude,
};

DeliveryRoutePoint _pointFromJson(Object? value) {
  final json = Map<String, Object?>.from(value as Map);
  return DeliveryRoutePoint(
    latitude: (json['latitude'] as num).toDouble(),
    longitude: (json['longitude'] as num).toDouble(),
  );
}

RiderRouteInstruction _instructionFromJson(Map<String, Object?> json) =>
    RiderRouteInstruction(
      text: json['text'] as String,
      distanceMeters: (json['distanceMeters'] as num).toDouble(),
      durationSeconds: (json['durationSeconds'] as num).toDouble(),
      maneuverPoint: json['maneuverPoint'] == null
          ? null
          : _pointFromJson(json['maneuverPoint']),
      maneuverType: json['maneuverType'] as String? ?? 'continue',
      maneuverModifier: json['maneuverModifier'] as String? ?? '',
    );
