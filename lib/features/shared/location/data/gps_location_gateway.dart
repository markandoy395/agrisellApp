import 'package:geolocator/geolocator.dart';

abstract interface class GpsLocationGateway {
  Future<bool> isServiceEnabled();
  Future<LocationPermission> checkPermission();
  Future<LocationPermission> requestPermission();
  Future<LocationAccuracyStatus> getAccuracyStatus();
  Future<Position> currentPosition({required LocationSettings settings});
  Stream<Position> positionStream({LocationSettings? settings});
  Future<bool> openAppSettings();
  Future<bool> openLocationSettings();
}

class GeolocatorGpsLocationGateway implements GpsLocationGateway {
  @override
  Future<LocationPermission> checkPermission() => Geolocator.checkPermission();

  @override
  Future<LocationAccuracyStatus> getAccuracyStatus() =>
      Geolocator.getLocationAccuracy();

  @override
  Future<Position> currentPosition({required LocationSettings settings}) =>
      Geolocator.getCurrentPosition(locationSettings: settings);

  @override
  Future<bool> isServiceEnabled() => Geolocator.isLocationServiceEnabled();

  @override
  Future<bool> openAppSettings() => Geolocator.openAppSettings();

  @override
  Future<bool> openLocationSettings() => Geolocator.openLocationSettings();

  @override
  Stream<Position> positionStream({LocationSettings? settings}) =>
      Geolocator.getPositionStream(
        locationSettings:
            settings ??
            const LocationSettings(
              accuracy: LocationAccuracy.bestForNavigation,
              distanceFilter: 0,
            ),
      );

  @override
  Future<LocationPermission> requestPermission() =>
      Geolocator.requestPermission();
}
