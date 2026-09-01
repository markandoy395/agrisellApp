import 'dart:convert';

import 'package:agresell_app/features/rider/deliveries/data/rider_routing_service.dart';
import 'package:agresell_app/features/rider/deliveries/domain/delivery_route.dart';
import 'package:agresell_app/features/rider/deliveries/domain/rider_route_plan.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';

void main() {
  test(
    'OSRM response creates road geometry, options, and directions',
    () async {
      late Uri requestedUri;
      final service = OsrmRiderRoutingService(
        client: MockClient((request) async {
          requestedUri = request.url;
          return http.Response(jsonEncode(_response), 200);
        }),
      );

      final routes = await service.findRoutes(
        requestId: 'delivery-1',
        destinationKey: 'delivery-1:pickup',
        origin: const DeliveryRoutePoint(latitude: 8.48, longitude: 124.65),
        destination: const DeliveryRoutePoint(
          latitude: 8.49,
          longitude: 124.66,
        ),
      );

      expect(requestedUri.queryParameters['geometries'], 'geojson');
      expect(requestedUri.queryParameters['steps'], 'true');
      expect(routes, hasLength(2));
      expect(routes.first.preference, RiderRoutePreference.fastest);
      expect(routes.last.preference, RiderRoutePreference.shortest);
      expect(routes.first.points[1].latitude, 8.485);
      expect(routes.first.points[1].longitude, 124.655);
      expect(routes.first.originRoadName, 'National Highway');
      expect(
        routes.first.instructions.first.text,
        contains('National Highway'),
      );
      expect(routes.first.instructions.first.maneuverType, 'depart');
    },
  );

  test('OSRM failure states return safe routing errors', () async {
    final busy = OsrmRiderRoutingService(
      client: MockClient((_) async => http.Response('{}', 429)),
    );
    final noRoute = OsrmRiderRoutingService(
      client: MockClient(
        (_) async => http.Response(
          jsonEncode({'code': 'NoRoute', 'message': 'No route'}),
          200,
        ),
      ),
    );

    await expectLater(
      busy.findRoutes(
        requestId: 'delivery-1',
        destinationKey: 'delivery-1:pickup',
        origin: const DeliveryRoutePoint(latitude: 8.48, longitude: 124.65),
        destination: const DeliveryRoutePoint(
          latitude: 8.49,
          longitude: 124.66,
        ),
      ),
      throwsA(isA<RiderRoutingException>()),
    );
    await expectLater(
      noRoute.findRoutes(
        requestId: 'delivery-1',
        destinationKey: 'delivery-1:pickup',
        origin: const DeliveryRoutePoint(latitude: 8.48, longitude: 124.65),
        destination: const DeliveryRoutePoint(
          latitude: 8.49,
          longitude: 124.66,
        ),
      ),
      throwsA(isA<RiderRoutingException>()),
    );
    await expectLater(
      busy.findRoutes(
        requestId: 'delivery-1',
        destinationKey: 'delivery-1:pickup',
        origin: const DeliveryRoutePoint(latitude: double.nan, longitude: 0),
        destination: const DeliveryRoutePoint(
          latitude: 8.49,
          longitude: 124.66,
        ),
      ),
      throwsA(isA<RiderRoutingException>()),
    );
  });

  test('OSRM nearest-road snap is parsed and cached', () async {
    var calls = 0;
    final service = OsrmRiderRoutingService(
      client: MockClient((request) async {
        calls++;
        expect(request.url.path, contains('/nearest/v1/driving/'));
        return http.Response(
          jsonEncode({
            'code': 'Ok',
            'waypoints': [
              {
                'distance': 18.5,
                'name': 'National Highway',
                'location': [124.6502, 8.4802],
              },
            ],
          }),
          200,
        );
      }),
    );
    const source = DeliveryRoutePoint(latitude: 8.48, longitude: 124.65);

    final first = await service.findNearestRoadAccess(source);
    final second = await service.findNearestRoadAccess(source);

    expect(calls, 1);
    expect(first?.roadName, 'National Highway');
    expect(first?.distanceMeters, 18.5);
    expect(first?.point.latitude, 8.4802);
    expect(second?.point.longitude, 124.6502);
  });
}

const _response = <String, Object>{
  'code': 'Ok',
  'waypoints': [
    {
      'name': 'National Highway',
      'location': [124.6501, 8.4801],
    },
    {
      'name': 'Market Road',
      'location': [124.6599, 8.4899],
    },
  ],
  'routes': [
    {
      'distance': 1000.0,
      'duration': 100.0,
      'geometry': {
        'type': 'LineString',
        'coordinates': [
          [124.6501, 8.4801],
          [124.655, 8.485],
          [124.6599, 8.4899],
        ],
      },
      'legs': [
        {
          'steps': [
            {
              'distance': 1000.0,
              'duration': 100.0,
              'name': 'National Highway',
              'maneuver': {
                'type': 'depart',
                'location': [124.6501, 8.4801],
              },
            },
          ],
        },
      ],
    },
    {
      'distance': 800.0,
      'duration': 120.0,
      'geometry': {
        'type': 'LineString',
        'coordinates': [
          [124.6501, 8.4801],
          [124.6599, 8.4899],
        ],
      },
      'legs': [
        {
          'steps': [
            {
              'distance': 800.0,
              'duration': 120.0,
              'name': 'Market Road',
              'maneuver': {
                'type': 'turn',
                'modifier': 'left',
                'location': [124.6501, 8.4801],
              },
            },
          ],
        },
      ],
    },
  ],
};
