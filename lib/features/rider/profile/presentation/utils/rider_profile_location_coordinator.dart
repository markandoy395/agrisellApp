import 'package:geolocator/geolocator.dart';

import 'package:agresell_app/features/shared/location/data/gps_location_gateway.dart';

abstract final class RiderProfileLocationCoordinator {
  static Future<Position> captureCurrentLocation(
    GpsLocationGateway gpsGateway,
  ) async {
    if (!await gpsGateway.isServiceEnabled()) {
      await gpsGateway.openLocationSettings();
      throw Exception('Turn on location services, then try saving again.');
    }
    var permission = await gpsGateway.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await gpsGateway.requestPermission();
    }
    if (permission == LocationPermission.denied) {
      throw Exception(
        'Allow location access so we can capture your exact location.',
      );
    }
    if (permission == LocationPermission.deniedForever) {
      await gpsGateway.openAppSettings();
      throw Exception(
        'Allow location permission in app settings, then try saving again.',
      );
    }
    if (await gpsGateway.getAccuracyStatus() ==
        LocationAccuracyStatus.reduced) {
      await gpsGateway.openAppSettings();
      throw Exception('Enable precise location, then try saving again.');
    }
    return gpsGateway.currentPosition(
      settings: const LocationSettings(
        accuracy: LocationAccuracy.bestForNavigation,
        timeLimit: Duration(seconds: 15),
      ),
    );
  }
}
