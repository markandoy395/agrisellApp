part of 'rider_home_screen.dart';

extension _RiderHomeLocationLifecycle on _RiderHomeScreenState {
  void _syncLiveLocationSharing() {
    final riderId = _riderId;
    final active = riderId == null
        ? null
        : _deliveryController.requests
              .where(
                (request) =>
                    request.isAssignedTo(riderId) && !request.stage.isTerminal,
              )
              .firstOrNull;
    final allowed =
        active != null &&
        riderId != null &&
        RiderLiveLocationAccess.authorize(
          request: active,
          riderId: riderId,
          status: _deliveryController.statusFor(active),
        ).allowed;
    _locationController.setLiveSharing(
      allowed,
      deliveryId: allowed ? active.id : null,
      riderId: allowed ? riderId : null,
    );
    final shouldTrack =
        allowed ||
        (_isAppInForeground &&
            (_activeIndex == RiderHomeScreen.mapNavIndex ||
                _activeIndex == RiderHomeScreen.deliveriesNavIndex));
    if (_lastTrackingRequested == shouldTrack) return;
    _lastTrackingRequested = shouldTrack;
    if (shouldTrack) {
      unawaited(_locationController.startTracking());
    } else {
      unawaited(_locationController.stopTracking());
    }
  }

  Future<void> _refreshForegroundLocation() async {
    await _locationController.refresh();
    if (!mounted || !_isAppInForeground || _lastTrackingRequested != true)
      return;
    await _locationController.startTracking();
  }
}
