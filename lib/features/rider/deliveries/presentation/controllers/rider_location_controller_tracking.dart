part of 'rider_location_controller.dart';

extension _RiderLocationTracking on RiderLocationController {
  Future<void> _startTracking() async {
    if (_positionSubscription != null) return;
    unawaited(_outbox.sync());
    if (_needsLocationRefresh) await refresh();
    if (!_trackingRequested ||
        _location == null ||
        _positionSubscription != null) {
      return;
    }
    _positionSubscription = _gateway
        .positionStream(settings: _streamLocationSettings)
        .listen(
          _setPosition,
          onError: (_) =>
              _setError('Live location updates are temporarily unavailable.'),
        );
  }

  Future<void> _restartTrackingStream() async {
    final subscription = _positionSubscription;
    _positionSubscription = null;
    await subscription?.cancel();
    if (_trackingRequested) await _startTracking();
  }

  LocationSettings get _currentLocationSettings => const LocationSettings(
    accuracy: LocationAccuracy.bestForNavigation,
    timeLimit: Duration(seconds: 15),
  );

  LocationSettings get _streamLocationSettings {
    if (!kIsWeb &&
        defaultTargetPlatform == TargetPlatform.android &&
        _liveSharingEnabled) {
      return AndroidSettings(
        accuracy: LocationAccuracy.bestForNavigation,
        distanceFilter: 20,
        intervalDuration: const Duration(seconds: 10),
        foregroundNotificationConfig: const ForegroundNotificationConfig(
          notificationTitle: 'AgriSell delivery navigation',
          notificationText: 'Sharing location for your active delivery.',
          notificationChannelName: 'Active delivery location',
          setOngoing: true,
        ),
      );
    }
    return const LocationSettings(
      accuracy: LocationAccuracy.high,
      distanceFilter: 20,
    );
  }

  void _setPosition(Position position) {
    if (!_isUsablePositionSample(position)) return;
    final location = RiderDeviceLocation(
      latitude: position.latitude,
      longitude: position.longitude,
      accuracyMeters: position.accuracy,
      altitudeMeters: position.altitude,
      timestamp: position.timestamp,
      speedMetersPerSecond: position.speed.isFinite && position.speed >= 0
          ? position.speed
          : 0,
      headingDegrees:
          position.heading.isFinite &&
              position.heading >= 0 &&
              position.heading <= 360
          ? position.heading
          : 0,
      isMocked: position.isMocked,
      isApproximate: _isApproximate,
    );
    _location = location;
    _state = _isApproximate
        ? RiderLocationState.approximateLocation
        : RiderLocationState.ready;
    _errorMessage = null;
    _scheduleFreshnessUpdate(location.timestamp);
    _notify();
    if (_currentRiderId != null) unawaited(_publishIfMeaningful(location));
  }

  bool _isUsablePositionSample(Position position) {
    if (!position.latitude.isFinite ||
        !position.longitude.isFinite ||
        position.latitude < -90 ||
        position.latitude > 90 ||
        position.longitude < -180 ||
        position.longitude > 180 ||
        !position.accuracy.isFinite ||
        position.accuracy < 0) {
      return false;
    }
    final age = _clock().difference(position.timestamp);
    return age >= -RiderLocationQualityRules.futureTolerance &&
        age <= RiderLocationQualityRules.maxAge;
  }

  void _scheduleFreshnessUpdate(DateTime capturedAt) {
    _freshnessTimer?.cancel();
    final remaining =
        RiderLocationQualityRules.maxAge - _clock().difference(capturedAt);
    _freshnessTimer = Timer(
      remaining.isNegative ? Duration.zero : remaining,
      _notify,
    );
  }

  Future<void> _publishIfMeaningful(RiderDeviceLocation location) async {
    final deliveryId = _sharingDeliveryId;
    final riderId = _currentRiderId;
    if (riderId == null) return;
    final quality = location.quality;
    if (quality == RiderLocationQuality.stale ||
        quality == RiderLocationQuality.unusable ||
        quality == RiderLocationQuality.mocked) {
      return;
    }
    final previous = _lastPublished;
    if (previous != null) {
      final elapsed = location.timestamp.difference(previous.capturedAt);
      final distance = Geolocator.distanceBetween(
        previous.latitude,
        previous.longitude,
        location.latitude,
        location.longitude,
      );
      if (elapsed < const Duration(minutes: 2) && distance < 25) return;
    }
    final update = RiderLocationUpdate(
      latitude: location.latitude,
      longitude: location.longitude,
      accuracyMeters: location.accuracyMeters,
      altitudeMeters: location.altitudeMeters,
      speedMetersPerSecond: location.speedMetersPerSecond,
      headingDegrees: location.headingDegrees,
      isMocked: location.isMocked,
      isApproximate: location.isApproximate,
      deliveryId: deliveryId,
      riderId: riderId,
      capturedAt: location.timestamp,
    );
    _lastPublished = update;
    await _outbox.record(update);
  }
}
