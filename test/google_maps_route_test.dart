import 'package:flutter_test/flutter_test.dart';

import 'package:agresell_app/features/rider/deliveries/domain/delivery_location.dart';
import 'package:agresell_app/features/rider/deliveries/domain/delivery_status_update.dart';
import 'package:agresell_app/features/rider/deliveries/domain/google_maps_route.dart';

void main() {
  test(
    'builds Google Maps directions from current GPS to buyer coordinates',
    () {
      final route = GoogleMapsRoute.directionsUri(
        origin: DeliveryStatusLocation(
          latitude: 8.481,
          longitude: 124.651,
          accuracyMeters: 7,
          timestamp: DateTime.now(),
        ),
        destination: const DeliveryLocation(
          address: 'Buyer address',
          latitude: 8.495,
          longitude: 124.672,
        ),
      );

      expect(route?.host, 'www.google.com');
      expect(route?.path, '/maps/dir/');
      expect(route?.queryParameters['api'], '1');
      expect(route?.queryParameters['origin'], '8.481,124.651');
      expect(route?.queryParameters['destination'], '8.495,124.672');
      expect(route?.queryParameters['travelmode'], 'driving');
      expect(route?.queryParameters['dir_action'], 'navigate');
    },
  );

  test('rejects unavailable, stale, approximate, and mocked rider GPS', () {
    const destination = DeliveryLocation(
      address: 'Buyer address',
      latitude: 8.495,
      longitude: 124.672,
    );
    for (final origin in <DeliveryStatusLocation?>[
      null,
      DeliveryStatusLocation(
        latitude: 8.481,
        longitude: 124.651,
        accuracyMeters: 7,
        timestamp: DateTime.now().subtract(const Duration(minutes: 2)),
      ),
      DeliveryStatusLocation(
        latitude: 8.481,
        longitude: 124.651,
        accuracyMeters: 7,
        timestamp: DateTime.now(),
        isApproximate: true,
      ),
      DeliveryStatusLocation(
        latitude: 8.481,
        longitude: 124.651,
        accuracyMeters: 7,
        timestamp: DateTime.now(),
        isMocked: true,
      ),
    ]) {
      expect(
        GoogleMapsRoute.directionsUri(origin: origin, destination: destination),
        isNull,
      );
    }
  });

  test('rejects missing and out-of-range buyer coordinates', () {
    final origin = DeliveryStatusLocation(
      latitude: 8.481,
      longitude: 124.651,
      accuracyMeters: 7,
      timestamp: DateTime.now(),
    );
    for (final destination in const [
      DeliveryLocation(address: 'Missing'),
      DeliveryLocation(address: 'Bad latitude', latitude: 91, longitude: 124),
      DeliveryLocation(address: 'Bad longitude', latitude: 8, longitude: 181),
    ]) {
      expect(
        GoogleMapsRoute.directionsUri(origin: origin, destination: destination),
        isNull,
      );
    }
  });

  test('rejects non-finite buyer coordinates', () {
    final origin = DeliveryStatusLocation(
      latitude: 8.481,
      longitude: 124.651,
      accuracyMeters: 7,
      timestamp: DateTime.now(),
    );
    for (final destination in [
      const DeliveryLocation(
        address: 'Infinite latitude',
        latitude: double.infinity,
        longitude: 124,
      ),
      const DeliveryLocation(
        address: 'Not-a-number longitude',
        latitude: 8,
        longitude: double.nan,
      ),
    ]) {
      expect(
        GoogleMapsRoute.directionsUri(origin: origin, destination: destination),
        isNull,
      );
    }
  });
}
