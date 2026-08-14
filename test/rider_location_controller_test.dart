import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:geolocator/geolocator.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:agresell_app/features/rider/deliveries/domain/rider_location_quality.dart';
import 'package:agresell_app/features/rider/deliveries/presentation/controllers/rider_location_controller.dart';
import 'package:agresell_app/features/shared/location/data/gps_location_gateway.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  setUp(() => SharedPreferences.setMockInitialValues({}));

  test('permission granted returns complete device GPS metadata', () async {
    final gateway = _Gateway(position: _position(accuracy: 8));
    final controller = RiderLocationController(gateway: gateway);
    addTearDown(controller.dispose);

    await controller.refresh();

    expect(controller.state, RiderLocationState.ready);
    expect(controller.location?.altitudeMeters, 42);
    expect(controller.location?.speedMetersPerSecond, 5);
    expect(controller.location?.headingDegrees, 90);
    expect(controller.quality, RiderLocationQuality.accurate);
  });

  test('unavailable Android speed and heading are normalized', () async {
    final gateway = _Gateway(position: _position(speed: -1, heading: -1));
    final controller = RiderLocationController(gateway: gateway);
    addTearDown(controller.dispose);

    await controller.refresh();

    expect(controller.location?.speedMetersPerSecond, 0);
    expect(controller.location?.headingDegrees, 0);
  });

  test('denied permission is requested only after explicit action', () async {
    final gateway = _Gateway(
      permission: LocationPermission.denied,
      requestedPermission: LocationPermission.whileInUse,
    );
    final controller = RiderLocationController(gateway: gateway);
    addTearDown(controller.dispose);

    await controller.refresh();
    expect(controller.state, RiderLocationState.permissionDenied);
    expect(gateway.permissionRequests, 0);

    await controller.refresh(requestPermission: true);
    expect(controller.state, RiderLocationState.ready);
    expect(gateway.permissionRequests, 1);
  });

  test('permanently denied and disabled GPS have distinct states', () async {
    final denied = RiderLocationController(
      gateway: _Gateway(permission: LocationPermission.deniedForever),
    );
    final disabled = RiderLocationController(
      gateway: _Gateway(serviceEnabled: false),
    );
    addTearDown(denied.dispose);
    addTearDown(disabled.dispose);

    await denied.refresh();
    await disabled.refresh();

    expect(denied.state, RiderLocationState.permissionDeniedForever);
    expect(disabled.state, RiderLocationState.serviceDisabled);
  });

  test('approximate location remains visible but is flagged', () async {
    final controller = RiderLocationController(
      gateway: _Gateway(accuracyStatus: LocationAccuracyStatus.reduced),
    );
    addTearDown(controller.dispose);

    await controller.refresh();

    expect(controller.state, RiderLocationState.approximateLocation);
    expect(controller.location, isNotNull);
    expect(controller.operationalWarning, contains('Precise'));
  });

  test('location timeout and poor accuracy are reported', () async {
    final timedOut = RiderLocationController(
      gateway: _Gateway(currentError: TimeoutException('timeout')),
    );
    final poor = RiderLocationController(
      gateway: _Gateway(position: _position(accuracy: 75)),
    );
    addTearDown(timedOut.dispose);
    addTearDown(poor.dispose);

    await timedOut.refresh();
    await poor.refresh();

    expect(timedOut.state, RiderLocationState.timedOut);
    expect(poor.quality, RiderLocationQuality.poor);
  });

  test('stale GPS sample is rejected instead of becoming ready', () async {
    final controller = RiderLocationController(
      gateway: _Gateway(
        position: _position(
          timestamp: DateTime.now().subtract(const Duration(minutes: 2)),
        ),
      ),
    );
    addTearDown(controller.dispose);

    await controller.refresh();

    expect(controller.location, isNull);
    expect(controller.state, RiderLocationState.error);
  });

  test('repeated tracking start creates one position stream', () async {
    final gateway = _Gateway();
    final controller = RiderLocationController(gateway: gateway);
    addTearDown(controller.dispose);

    await Future.wait([controller.startTracking(), controller.startTracking()]);

    expect(gateway.streamStarts, 1);
  });

  test('active sharing reports while-in-use background restriction', () async {
    final controller = RiderLocationController(gateway: _Gateway());
    addTearDown(controller.dispose);
    await controller.refresh();

    controller.setLiveSharing(
      true,
      deliveryId: 'delivery-1',
      riderId: 'rider-1',
    );

    expect(controller.isBackgroundRestricted, isTrue);
    expect(controller.operationalWarning, contains('Background'));
  });
}

Position _position({
  double accuracy = 8,
  double speed = 5,
  double heading = 90,
  DateTime? timestamp,
}) => Position(
  longitude: 124.65,
  latitude: 8.48,
  timestamp: timestamp ?? DateTime.now(),
  accuracy: accuracy,
  altitude: 42,
  altitudeAccuracy: 2,
  heading: heading,
  headingAccuracy: 3,
  speed: speed,
  speedAccuracy: 1,
  isMocked: false,
);

class _Gateway implements GpsLocationGateway {
  _Gateway({
    this.serviceEnabled = true,
    this.permission = LocationPermission.whileInUse,
    this.requestedPermission = LocationPermission.whileInUse,
    this.accuracyStatus = LocationAccuracyStatus.precise,
    Position? position,
    this.currentError,
  }) : position = position ?? _position();

  final bool serviceEnabled;
  final LocationPermission permission;
  final LocationPermission requestedPermission;
  final LocationAccuracyStatus accuracyStatus;
  final Position position;
  final Object? currentError;
  final positions = StreamController<Position>.broadcast();
  var permissionRequests = 0;
  var streamStarts = 0;

  @override
  Future<LocationPermission> checkPermission() async => permission;

  @override
  Future<Position> currentPosition({required LocationSettings settings}) async {
    final error = currentError;
    if (error != null) throw error;
    return position;
  }

  @override
  Future<LocationAccuracyStatus> getAccuracyStatus() async => accuracyStatus;

  @override
  Future<bool> isServiceEnabled() async => serviceEnabled;

  @override
  Future<bool> openAppSettings() async => true;

  @override
  Future<bool> openLocationSettings() async => true;

  @override
  Stream<Position> positionStream({LocationSettings? settings}) {
    streamStarts++;
    return positions.stream;
  }

  @override
  Future<LocationPermission> requestPermission() async {
    permissionRequests++;
    return requestedPermission;
  }
}
