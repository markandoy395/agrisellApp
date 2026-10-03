import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:geolocator/geolocator.dart';

import 'package:agresell_app/features/rider/deliveries/data/rider_location_outbox.dart';
import 'package:agresell_app/features/rider/deliveries/data/supabase_rider_location_remote.dart';
import 'package:agresell_app/core/services/agrisell_supabase.dart';
import 'package:agresell_app/features/rider/deliveries/domain/rider_location.dart';
import 'package:agresell_app/features/rider/deliveries/domain/rider_location_quality.dart';
import 'package:agresell_app/features/shared/location/data/gps_location_gateway.dart';

part 'rider_location_controller_tracking.dart';
part 'rider_location_controller_refresh.dart';

enum RiderLocationState {
  idle,
  loading,
  ready,
  serviceDisabled,
  permissionDenied,
  permissionDeniedForever,
  approximateLocation,
  timedOut,
  error,
}

class RiderDeviceLocation extends RiderLocation {
  const RiderDeviceLocation({
    required super.latitude,
    required super.longitude,
    required super.accuracyMeters,
    required super.timestamp,
    super.altitudeMeters,
    super.speedMetersPerSecond,
    super.headingDegrees,
    super.isMocked,
    super.isApproximate,
  });
}

class RiderLocationController extends ChangeNotifier {
  RiderLocationController({
    RiderLocationOutbox? outbox,
    GpsLocationGateway? gateway,
    DateTime Function()? clock,
  }) : _outbox =
           outbox ??
           RiderLocationOutbox(
             remote: AgrisellSupabase.isInitialized
                 ? SupabaseRiderLocationRemoteDataSource()
                 : null,
           ),
       _gateway = gateway ?? GeolocatorGpsLocationGateway(),
       _clock = clock ?? DateTime.now;
  static const _cachedLocationMaxAge = Duration(minutes: 2);
  final RiderLocationOutbox _outbox;
  final GpsLocationGateway _gateway;
  final DateTime Function() _clock;
  RiderLocationState _state = RiderLocationState.idle;
  RiderDeviceLocation? _location;
  String? _errorMessage;
  StreamSubscription<Position>? _positionSubscription;
  Timer? _freshnessTimer;
  Future<void>? _trackingStart;
  var _trackingRequested = false;
  var _liveSharingEnabled = false;
  var _isApproximate = false;
  LocationPermission? _permission;
  String? _sharingDeliveryId;
  String? _currentRiderId;
  RiderLocationUpdate? _lastPublished;
  RiderLocationState get state => _state;
  RiderDeviceLocation? get location => _location;
  String? get errorMessage => _errorMessage;
  bool get supportsDeviceSettings => !kIsWeb;
  bool get isLiveSharing => _liveSharingEnabled;
  bool get isApproximate => _isApproximate;
  bool get isBackgroundRestricted =>
      _liveSharingEnabled && _permission == LocationPermission.whileInUse;
  RiderLocationQuality? get quality => _location?.quality;
  String? get operationalWarning {
    if (isBackgroundRestricted) {
      return 'Background location is restricted. Keep AgriSell open or allow '
          'background location in device settings.';
    }
    if (_isApproximate) {
      return 'Precise location is off. Arrival actions require an accurate fix.';
    }
    return _errorMessage;
  }

  void setLiveSharing(bool enabled, {String? deliveryId, String? riderId}) {
    final changed =
        _liveSharingEnabled != enabled ||
        _sharingDeliveryId != deliveryId ||
        (riderId != null && _currentRiderId != riderId);
    if (!changed) return;
    _liveSharingEnabled = enabled;
    _sharingDeliveryId = enabled ? deliveryId : null;
    if (riderId != null) _currentRiderId = riderId;
    _lastPublished = null;
    if (_positionSubscription != null) unawaited(_restartTrackingStream());
    notifyListeners();
  }

  void setCurrentRiderId(String? riderId) {
    if (_currentRiderId == riderId) return;
    _currentRiderId = riderId;
    _lastPublished = null;
  }

  Future<void> startTracking() {
    _trackingRequested = true;
    return _trackingStart ??= _startTracking().whenComplete(
      () => _trackingStart = null,
    );
  }

  Future<void> stopTracking() async {
    _trackingRequested = false;
    final subscription = _positionSubscription;
    _positionSubscription = null;
    await subscription?.cancel();
  }

  Future<bool> openLocationSettings() => _gateway.openLocationSettings();
  Future<bool> openAppSettings() => _gateway.openAppSettings();

  Future<bool> publishCurrentLocation() async {
    final location = _location;
    if (_currentRiderId == null || location == null) return false;
    await _publishIfMeaningful(location);
    return _outbox.sync();
  }

  Future<void> refresh({bool requestPermission = false}) =>
      _refreshLocation(requestPermission: requestPermission);

  bool get _needsLocationRefresh {
    final location = _location;
    return location == null ||
        _clock().difference(location.timestamp) > _cachedLocationMaxAge;
  }

  void _setUnavailableState(RiderLocationState state) {
    _state = state;
    if (state == RiderLocationState.serviceDisabled ||
        state == RiderLocationState.permissionDenied ||
        state == RiderLocationState.permissionDeniedForever) {
      _location = null;
    }
    notifyListeners();
  }

  void _notify() => notifyListeners();

  void _setError(
    String message, {
    RiderLocationState state = RiderLocationState.error,
  }) {
    _errorMessage = message;
    if (_location == null) _state = state;
    notifyListeners();
  }

  @override
  void dispose() {
    _freshnessTimer?.cancel();
    unawaited(stopTracking());
    super.dispose();
  }
}
