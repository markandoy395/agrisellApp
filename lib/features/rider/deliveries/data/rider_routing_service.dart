import 'dart:async';
import 'dart:convert';

import 'package:http/http.dart' as http;

import 'package:agresell_app/features/rider/deliveries/data/rider_osrm_parser.dart';
import 'package:agresell_app/features/rider/deliveries/domain/delivery_route.dart';
import 'package:agresell_app/features/rider/deliveries/domain/rider_route_plan.dart';

abstract interface class RiderRoutingService {
  Future<List<RiderRoutePlan>> findRoutes({
    required String requestId,
    required String destinationKey,
    required DeliveryRoutePoint origin,
    required DeliveryRoutePoint destination,
  });
}

class OsrmRiderRoutingService implements RiderRoutingService {
  OsrmRiderRoutingService({http.Client? client, Uri? endpoint})
    : _client = client ?? http.Client(),
      _endpoint = endpoint ?? Uri.parse('https://router.project-osrm.org');

  final http.Client _client;
  final Uri _endpoint;

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
