import 'dart:async';
import 'dart:convert';

import 'package:http/http.dart' as http;

import 'package:agresell_app/features/rider/deliveries/data/rider_osrm_parser.dart';
import 'package:agresell_app/features/shared/routing/domain/delivery_route.dart';
import 'package:agresell_app/features/rider/deliveries/domain/rider_road_access.dart';
import 'package:agresell_app/features/rider/deliveries/domain/rider_route_plan.dart';

abstract interface class RiderRoutingService {
  Future<List<RiderRoutePlan>> findRoutes({
    required String requestId,
    required String destinationKey,
    required DeliveryRoutePoint origin,
    required DeliveryRoutePoint destination,
  });
}

abstract interface class RiderRoadAccessService {
  Future<RiderRoadAccessSnap?> findNearestRoadAccess(DeliveryRoutePoint point);
}

class DisabledRiderRoadAccessService implements RiderRoadAccessService {
  const DisabledRiderRoadAccessService();

  @override
  Future<RiderRoadAccessSnap?> findNearestRoadAccess(
    DeliveryRoutePoint point,
  ) async => null;
}

class OsrmRiderRoutingService
    implements RiderRoutingService, RiderRoadAccessService {
  OsrmRiderRoutingService({http.Client? client, Uri? endpoint})
    : _client = client ?? http.Client(),
      _endpoint = endpoint ?? Uri.parse('https://router.project-osrm.org');

  final http.Client _client;
  final Uri _endpoint;
  final Map<String, ({DateTime storedAt, RiderRoadAccessSnap snap})>
  _roadAccessCache = {};

  static const _roadAccessCacheLifetime = Duration(minutes: 30);
  static const _maximumRoadAccessCacheEntries = 128;

  @override
  Future<List<RiderRoutePlan>> findRoutes({
    required String requestId,
    required String destinationKey,
    required DeliveryRoutePoint origin,
    required DeliveryRoutePoint destination,
  }) async {
    if (!_valid(origin) || !_valid(destination)) {
      throw const RiderRoutingException('Route coordinates are invalid.');
    }
    final coordinates =
        '${origin.longitude},${origin.latitude};'
        '${destination.longitude},${destination.latitude}';
    final uri = _endpoint
        .resolve('/route/v1/driving/$coordinates')
        .replace(
          queryParameters: const {
            'alternatives': '3',
            'steps': 'true',
            'geometries': 'geojson',
            'overview': 'full',
            'snapping': 'default',
          },
        );
    try {
      final response = await _client
          .get(uri, headers: const {'Accept': 'application/json'})
          .timeout(const Duration(seconds: 12));
      if (response.statusCode == 429) {
        throw const RiderRoutingException(
          'Road routing is busy. Keep the saved route and try again shortly.',
        );
      }
      if (response.statusCode != 200) {
        throw const RiderRoutingException(
          'Road routing service is unavailable.',
        );
      }
      return parseOsrmRiderRoutes(
        jsonDecode(response.body),
        requestId: requestId,
        destinationKey: destinationKey,
      );
    } on RiderRoutingException {
      rethrow;
    } on TimeoutException {
      throw const RiderRoutingException('Road routing took too long.');
    } on Object {
      throw const RiderRoutingException(
        'The road routing response could not be used.',
      );
    }
  }

  @override
  Future<RiderRoadAccessSnap?> findNearestRoadAccess(
    DeliveryRoutePoint point,
  ) async {
    if (!_valid(point)) {
      throw const RiderRoutingException('Road-access coordinates are invalid.');
    }
    final key =
        '${point.latitude.toStringAsFixed(5)}:'
        '${point.longitude.toStringAsFixed(5)}';
    final cached = _roadAccessCache[key];
    if (cached != null &&
        DateTime.now().difference(cached.storedAt) < _roadAccessCacheLifetime) {
      return cached.snap;
    }
    final uri = _endpoint
        .resolve(
          '/nearest/v1/driving/'
          '${point.longitude},${point.latitude}',
        )
        .replace(queryParameters: const {'number': '1'});
    try {
      final response = await _client
          .get(uri, headers: const {'Accept': 'application/json'})
          .timeout(const Duration(seconds: 8));
      if (response.statusCode != 200) return null;
      final root = Map<String, Object?>.from(jsonDecode(response.body) as Map);
      if (root['code'] != 'Ok') return null;
      final waypoints = root['waypoints'];
      if (waypoints is! List || waypoints.isEmpty) return null;
      final waypoint = Map<String, Object?>.from(waypoints.first as Map);
      final location = waypoint['location'];
      if (location is! List || location.length < 2) return null;
      final longitude = (location[0] as num).toDouble();
      final latitude = (location[1] as num).toDouble();
      final distance = (waypoint['distance'] as num?)?.toDouble() ?? 0;
      final snappedPoint = DeliveryRoutePoint(
        latitude: latitude,
        longitude: longitude,
      );
      if (!_valid(snappedPoint) || !distance.isFinite || distance < 0) {
        return null;
      }
      final snap = RiderRoadAccessSnap(
        point: snappedPoint,
        roadName: (waypoint['name'] as String? ?? '').trim(),
        distanceMeters: distance,
      );
      if (_roadAccessCache.length >= _maximumRoadAccessCacheEntries) {
        _roadAccessCache.remove(_roadAccessCache.keys.first);
      }
      _roadAccessCache[key] = (storedAt: DateTime.now(), snap: snap);
      return snap;
    } on TimeoutException {
      return null;
    } on Object {
      return null;
    }
  }
}

class RiderRoutingException implements Exception {
  const RiderRoutingException(this.message);
  final String message;
}

bool _valid(DeliveryRoutePoint point) =>
    point.latitude.isFinite &&
    point.longitude.isFinite &&
    point.latitude >= -90 &&
    point.latitude <= 90 &&
    point.longitude >= -180 &&
    point.longitude <= 180;
