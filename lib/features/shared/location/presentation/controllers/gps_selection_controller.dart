import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:geolocator/geolocator.dart';

import 'package:agresell_app/features/shared/location/data/gps_location_gateway.dart';

enum GpsSelectionState {
  idle,
  requestingPermission,
  acquiring,
  poorAccuracy,
  ready,
  serviceDisabled,
  permissionDenied,
  permissionDeniedForever,
  preciseLocationDisabled,
  error,
}

class GpsSelectionController extends ChangeNotifier {
  GpsSelectionController({GpsLocationGateway? gateway})
    : _gateway = gateway ?? GeolocatorGpsLocationGateway();

  static const preferredAccuracyMeters = 15.0;
  final GpsLocationGateway _gateway;
  StreamSubscription<Position>? _subscription;
  GpsSelectionState _state = GpsSelectionState.idle;
  Position? _bestPosition;
  String? _errorMessage;
  Future<void>? _starting;
  var _validSampleCount = 0;

  GpsSelectionState get state => _state;
  Position? get bestPosition => _bestPosition;
  String? get errorMessage => _errorMessage;
  bool get isListening => _subscription != null;

  Future<void> start() =>
      _starting ??= _start().whenComplete(() => _starting = null);

  Future<void> _start() async {
    await stop();
    _bestPosition = null;
    _validSampleCount = 0;
    _errorMessage = null;
    if (!await _gateway.isServiceEnabled()) {
      _setState(GpsSelectionState.serviceDisabled);
      return;
    }
    var permission = await _gateway.checkPermission();
    if (permission == LocationPermission.denied) {
      _setState(GpsSelectionState.requestingPermission);
      permission = await _gateway.requestPermission();
    }
    if (permission == LocationPermission.denied) {
      _setState(GpsSelectionState.permissionDenied);
      return;
    }
    if (permission == LocationPermission.deniedForever) {
      _setState(GpsSelectionState.permissionDeniedForever);
      return;
    }
    if (await _gateway.getAccuracyStatus() == LocationAccuracyStatus.reduced) {
      _setState(GpsSelectionState.preciseLocationDisabled);
      return;
    }
    _setState(GpsSelectionState.acquiring);
    _subscription = _gateway.positionStream().listen(
      _onPosition,
      onError: (_) {
        _errorMessage = 'GPS position could not be retrieved.';
        _setState(GpsSelectionState.error);
      },
    );
  }

  void _onPosition(Position position) {
    if (!position.accuracy.isFinite || position.accuracy <= 0) return;
    _validSampleCount++;
    final current = _bestPosition;
    if (current == null || position.accuracy < current.accuracy) {
      _bestPosition = position;
    }
    final best = _bestPosition!;
    _setState(
      best.accuracy <= preferredAccuracyMeters && _validSampleCount > 1
          ? GpsSelectionState.ready
          : best.accuracy > preferredAccuracyMeters
          ? GpsSelectionState.poorAccuracy
          : GpsSelectionState.acquiring,
    );
  }

  Future<void> stop() async {
    final subscription = _subscription;
    _subscription = null;
    await subscription?.cancel();
  }

  Future<bool> openAppSettings() => _gateway.openAppSettings();
  Future<bool> openLocationSettings() => _gateway.openLocationSettings();

  void _setState(GpsSelectionState value) {
    _state = value;
    notifyListeners();
  }

  @override
  void dispose() {
    unawaited(stop());
    super.dispose();
  }
}
