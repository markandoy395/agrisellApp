import 'dart:async';

import 'package:geolocator/geolocator.dart';
import 'package:agresell_app/features/farmer/profile/data/farmer_farm_service.dart';
import 'package:agresell_app/features/shared/location/data/gps_location_gateway.dart';

abstract final class FarmerFarmLocationCoordinator {
  static Future<({double latitude, double longitude})> captureCoordinates({
    required GpsLocationGateway gpsGateway,
    bool openSettings = true,
  }) async {
    try {
      if (!await gpsGateway.isServiceEnabled()) {
        if (openSettings) await gpsGateway.openLocationSettings();
        throw const FarmerFarmException(
          'Turn on location services, then return to capture your farm location.',
        );
      }
      var permission = await gpsGateway.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await gpsGateway.requestPermission();
      }
      if (permission == LocationPermission.denied) {
        throw const FarmerFarmException(
          'Allow location access so we can capture your farm location.',
        );
      }
      if (permission == LocationPermission.deniedForever) {
        if (openSettings) await gpsGateway.openAppSettings();
        throw const FarmerFarmException(
          'Allow location permission in app settings, then return to capture your farm location.',
        );
      }
      if (await gpsGateway.getAccuracyStatus() ==
          LocationAccuracyStatus.reduced) {
        if (openSettings) await gpsGateway.openAppSettings();
        throw const FarmerFarmException(
          'Enable precise location, then return to capture your farm location.',
        );
      }
      final position = await gpsGateway.currentPosition(
        settings: const LocationSettings(
          accuracy: LocationAccuracy.bestForNavigation,
          timeLimit: Duration(seconds: 15),
        ),
      );
      if (!position.latitude.isFinite ||
          !position.longitude.isFinite ||
          position.latitude < -90 ||
          position.latitude > 90 ||
          position.longitude < -180 ||
          position.longitude > 180) {
        throw const FarmerFarmException(
          'GPS returned an invalid farm location. Try again.',
        );
      }
      return (latitude: position.latitude, longitude: position.longitude);
    } on FarmerFarmException {
      rethrow;
    } on TimeoutException {
      throw const FarmerFarmException(
        'Location took too long. Check your GPS signal and try again.',
      );
    } catch (_) {
      throw const FarmerFarmException(
        'Current farm location could not be captured. Try again.',
      );
    }
  }
}
