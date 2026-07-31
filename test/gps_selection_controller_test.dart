import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:geolocator/geolocator.dart';

import 'package:agresell_app/features/shared/location/data/gps_location_gateway.dart';
import 'package:agresell_app/features/shared/location/presentation/controllers/gps_selection_controller.dart';

void main() {
  test('waits for and keeps the most accurate GPS result', () async {
    final gateway = _FakeGpsGateway();
    final controller = GpsSelectionController(gateway: gateway);
    addTearDown(controller.dispose);

    await controller.start();
    expect(controller.state, GpsSelectionState.acquiring);

    gateway.positions.add(_position(accuracy: 80));
    await Future<void>.delayed(Duration.zero);
    expect(controller.state, GpsSelectionState.poorAccuracy);
    expect(controller.bestPosition?.accuracy, 80);

    gateway.positions.add(_position(accuracy: 10));
    await Future<void>.delayed(Duration.zero);
    expect(controller.state, GpsSelectionState.ready);
    expect(controller.bestPosition?.accuracy, 10);

    gateway.positions.add(_position(accuracy: 30));
    await Future<void>.delayed(Duration.zero);
    expect(controller.bestPosition?.accuracy, 10);
  });

  test('reports reduced accuracy before opening a GPS stream', () async {
    final gateway = _FakeGpsGateway(
      accuracyStatus: LocationAccuracyStatus.reduced,
    );
    final controller = GpsSelectionController(gateway: gateway);
    addTearDown(controller.dispose);

    await controller.start();

    expect(controller.state, GpsSelectionState.preciseLocationDisabled);
    expect(controller.isListening, isFalse);
  });

  test('reports denied permission explicitly', () async {
    final gateway = _FakeGpsGateway(
      permission: LocationPermission.denied,
      requestedPermission: LocationPermission.denied,
    );
    final controller = GpsSelectionController(gateway: gateway);
    addTearDown(controller.dispose);

    await controller.start();

    expect(controller.state, GpsSelectionState.permissionDenied);
  });
}

Position _position({required double accuracy}) => Position(
  longitude: 124.6472,
  latitude: 8.4822,
  timestamp: DateTime.now(),
  accuracy: accuracy,
  altitude: 0,
  altitudeAccuracy: 0,
  heading: 0,
  headingAccuracy: 0,
  speed: 0,
  speedAccuracy: 0,
);

class _FakeGpsGateway implements GpsLocationGateway {
  _FakeGpsGateway({
    this.permission = LocationPermission.whileInUse,
    this.requestedPermission = LocationPermission.whileInUse,
    this.accuracyStatus = LocationAccuracyStatus.precise,
  });

  final positions = StreamController<Position>.broadcast();
  final LocationPermission permission;
  final LocationPermission requestedPermission;
  final LocationAccuracyStatus accuracyStatus;

  @override
  Future<Position> currentPosition({
    required LocationSettings settings,
  }) async => _position(accuracy: 10);

  @override
  Future<LocationPermission> checkPermission() async => permission;
  @override
  Future<LocationAccuracyStatus> getAccuracyStatus() async => accuracyStatus;
  @override
  Future<bool> isServiceEnabled() async => true;
  @override
  Future<bool> openAppSettings() async => true;
  @override
  Future<bool> openLocationSettings() async => true;
  @override
  Stream<Position> positionStream({LocationSettings? settings}) =>
      positions.stream;
  @override
  Future<LocationPermission> requestPermission() async => requestedPermission;
}
