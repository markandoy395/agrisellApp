part of 'rider_home_screen.dart';

extension _RiderHomeLifecycle on _RiderHomeScreenState {
  void _consumePendingPushAction() {
    final action = PushNotificationService.instance.takePendingAction();
    if (action == null) return;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) _openPushAction(action);
    });
  }

  void _openPushAction(PushNotificationAction action) {
    switch (action.destination) {
      case 'orders' || 'deliveries':
        unawaited(_selectTab(RiderHomeScreen.deliveriesNavIndex));
        return;
      case 'messages':
        unawaited(_selectTab(RiderHomeScreen.messagesNavIndex));
        return;
      case 'account':
        unawaited(_selectTab(RiderHomeScreen.profileNavIndex));
        return;
      default:
        _openNotifications();
    }
  }

  void _handleLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _isAppInForeground = true;
      _syncLiveLocationSharing();
      final backgroundedAt = _backgroundedAt;
      _backgroundedAt = null;
      final shouldRefreshRiderState =
          backgroundedAt == null ||
          DateTime.now().difference(backgroundedAt) >=
              _dashboardController.staleAfter;
      if (shouldRefreshRiderState ||
          _availabilityController.internetStatus ==
              RiderInternetStatus.unknown) {
        unawaited(_availabilityController.refreshEnvironment());
      }
      unawaited(_deliveryController.synchronizeOfflineActions());
      if (shouldRefreshRiderState) {
        unawaited(_refreshRiderProfile());
        final riderId = _riderId;
        if (riderId != null) {
          unawaited(_dashboardController.load(riderId: riderId));
        }
      }
      return;
    }
    if (state == AppLifecycleState.paused ||
        state == AppLifecycleState.hidden ||
        state == AppLifecycleState.detached) {
      _backgroundedAt ??= DateTime.now();
      _isAppInForeground = false;
      _syncLiveLocationSharing();
    }
  }

  void _syncAvailability() {
    _syncLiveLocationSharing();
    _syncCompletedCount();
    final profile = RiderRegistrationService.instance.currentProfile;
    final availability = _deliveryController.status.availability;
    final availabilityChanged = _lastAvailability != availability;
    _lastAvailability = availability;
    if (profile != null && profile.availabilityStatus != availability) {
      RiderRegistrationService.instance.updateCurrentAvailability(availability);
      _rebuildForProfileChange();
    }
    if (availabilityChanged) unawaited(_dashboardController.refresh());
  }

  void _syncCompletedCount() {
    final now = DateTime.now();
    final count = _deliveryController.completionHistory.where((record) {
      final date = record.completedAt.toLocal();
      return date.year == now.year &&
          date.month == now.month &&
          date.day == now.day;
    }).length;
    if (_lastCompletedToday == count) return;
    _lastCompletedToday = count;
    _dashboardController.applyLocalCompletedToday(count);
  }

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
        (_isAppInForeground && _activeIndex == RiderHomeScreen.mapNavIndex);
    if (_lastTrackingRequested == shouldTrack) return;
    _lastTrackingRequested = shouldTrack;
    if (shouldTrack) {
      unawaited(_locationController.startTracking());
    } else {
      unawaited(_locationController.stopTracking());
    }
  }

  void _syncRequestEnvironment() {
    final location = _locationController.location;
    final profile = RiderRegistrationService.instance.currentProfile;
    final search = location == null
        ? null
        : RiderDeliverySearch(
            latitude: location.latitude,
            longitude: location.longitude,
            radiusKm: profile?.serviceRadiusKm ?? 15,
          );
    _deliveryController.setBackendReachable(
      _availabilityController.internetStatus == RiderInternetStatus.online,
    );
    _messagesController.setBackendReachable(
      _availabilityController.internetStatus == RiderInternetStatus.online,
    );
    _safetyController.setBackendReachable(
      _availabilityController.internetStatus == RiderInternetStatus.online,
    );
    _deliveryController.updateCurrentRiderLocation(location);
    final state = _requestAccessFor(profile, search);
    _deliveryController.updateRequestEnvironment(
      state: state,
      location: state.usesRegisteredLocationEstimate ? null : search,
      accuracyMeters: location?.accuracyMeters,
    );
  }

  RiderRequestAccessState _requestAccessFor(
    RiderProfile? profile,
    RiderDeliverySearch? currentLocation,
  ) {
    if (_riderId == null || profile == null) {
      return RiderRequestAccessState.unauthenticated;
    }
    final availability = _deliveryController.status.availability;
    final canContinueBatch =
        availability.isHandlingDelivery &&
        _deliveryController.activeDeliveryRequests.length <
            profile.maximumActiveDeliveries;
    if (!availability.canReceiveRequests && !canContinueBatch) {
      return _deliveryController.hasActiveDelivery
          ? RiderRequestAccessState.activeDeliveryLimit
          : RiderRequestAccessState.offline;
    }
    final internet = _availabilityController.internetStatus;
    if (internet == RiderInternetStatus.offline) {
      return RiderRequestAccessState.noInternet;
    }
    if (internet == RiderInternetStatus.backendUnavailable) {
      return RiderRequestAccessState.backendUnavailable;
    }
    final gps = _availabilityController.gpsStatus;
    if (gps == RiderGpsStatus.disabled) {
      return RiderRequestAccessState.gpsDisabled;
    }
    if (gps == RiderGpsStatus.permissionDenied ||
        gps == RiderGpsStatus.permissionDeniedForever ||
        gps == RiderGpsStatus.approximateLocation) {
      return RiderRequestAccessState.permissionDenied;
    }
    if (gps == RiderGpsStatus.poorAccuracy) {
      return RiderRequestAccessState.poorGpsAccuracy;
    }
    if (gps != RiderGpsStatus.ready || currentLocation == null) {
      return RiderRequestAccessState.locationUnavailable;
    }
    return RiderRequestAccessState.eligible;
  }
}
