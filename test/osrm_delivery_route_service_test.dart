import 'dart:convert';

import 'package:agresell_app/features/shared/routing/data/osrm_delivery_route_service.dart';
import 'package:agresell_app/features/shared/routing/domain/delivery_route.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';

void main() {
  const origin = DeliveryRoutePoint(latitude: 8.4, longitude: 124.6);
  const destination = DeliveryRoutePoint(latitude: 8.5, longitude: 124.7);

  test(
    'large geometry survives isolate decoding with coordinate order intact',
    () async {
      final body = jsonEncode({
        'code': 'Ok',
        'routes': [
          {
            'distance': 12345,
            'duration': 121,
            'geometry': {
              'coordinates': List.generate(
                5000,
                (i) => [124.6 + i / 10000, 8.4],
              ),
            },
          },
        ],
      });
      final service = OsrmDeliveryRouteService(
        client: MockClient((_) async => http.Response(body, 200)),
      );
      final result = await service.findRoute(
        origin: origin,
        destination: destination,
      );
      expect(result!.distanceKm, 12.345);
      expect(result.estimatedTravelMinutes, 3);
      expect(result.points, hasLength(5000));
      expect(result.points.first.latitude, 8.4);
      expect(result.points.first.longitude, 124.6);
      expect(result.points.last.longitude, closeTo(125.0999, 0.000001));
    },
  );

  for (final body in [
    'invalid json',
    '{"code":"NoRoute"}',
    '{"code":"Ok","routes":[]}',
  ]) {
    test('unusable route response returns null: $body', () async {
      final service = OsrmDeliveryRouteService(
        client: MockClient((_) async => http.Response(body, 200)),
      );
      expect(
        await service.findRoute(origin: origin, destination: destination),
        isNull,
      );
    });
  }
}
