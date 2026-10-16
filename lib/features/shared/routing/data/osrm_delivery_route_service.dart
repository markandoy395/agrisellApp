import 'dart:async';
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

import '../domain/delivery_route.dart';
import '../domain/delivery_route_service.dart';

class OsrmDeliveryRouteService implements DeliveryRouteService {
  OsrmDeliveryRouteService({http.Client? client, Uri? endpoint})
    : _client = client ?? http.Client(),
      _endpoint = endpoint ?? Uri.parse('https://router.project-osrm.org');

  final http.Client _client;
  final Uri _endpoint;

  @override
  Future<DeliveryRouteInfo?> findRoute({
    required DeliveryRoutePoint origin,
    required DeliveryRoutePoint destination,
  }) async {
    final coordinates =
        '${origin.longitude},${origin.latitude};${destination.longitude},${destination.latitude}';
    final uri = _endpoint
        .resolve('/route/v1/driving/$coordinates')
        .replace(
          queryParameters: const {'overview': 'full', 'geometries': 'geojson'},
        );

    try {
      final response = await _client
          .get(uri, headers: const {'Accept': 'application/json'})
          .timeout(const Duration(seconds: 10));

      if (response.statusCode != 200) return null;
      return await compute(_parseRoute, response.bodyBytes);
    } catch (_) {
      return null;
    }
  }
}

// Route geometries can contain thousands of points; keep decoding and model
// construction together so neither blocks native UI frames.
DeliveryRouteInfo? _parseRoute(Uint8List bytes) {
  final data = jsonDecode(utf8.decode(bytes));
  if (data is! Map<String, dynamic> || data['code'] != 'Ok') return null;

  final routes = data['routes'] as List<dynamic>?;
  if (routes == null || routes.isEmpty) return null;

  final route = routes.first as Map<String, dynamic>;
  final distanceMeters = (route['distance'] as num?)?.toDouble() ?? 0.0;
  final durationSeconds = (route['duration'] as num?)?.toDouble() ?? 0.0;
  final distanceKm = distanceMeters / 1000.0;
  final estimatedTravelMinutes = (durationSeconds / 60.0).ceil();

  final geometry = route['geometry'] as Map<String, dynamic>?;
  final coordinatesList = geometry?['coordinates'] as List<dynamic>? ?? [];
  final points = <DeliveryRoutePoint>[];

  for (final rawCoord in coordinatesList) {
    if (rawCoord is List && rawCoord.length >= 2) {
      final lng = (rawCoord[0] as num).toDouble();
      final lat = (rawCoord[1] as num).toDouble();
      points.add(DeliveryRoutePoint(latitude: lat, longitude: lng));
    }
  }

  return DeliveryRouteInfo(
    distanceKm: distanceKm,
    estimatedTravelMinutes: estimatedTravelMinutes,
    points: points,
  );
}
