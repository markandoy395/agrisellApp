part of 'rider_availability_controller.dart';

extension RiderAvailabilityControllerSynchronization
    on RiderAvailabilityController {
  Future<RiderInternetStatus> _checkConnectivity() {
    final existing = _connectivityCheck;
    if (existing != null) return existing;
    final request = _connectivity.checkConnectivity();
    _connectivityCheck = request;
    return request.whenComplete(() {
      if (identical(_connectivityCheck, request)) _connectivityCheck = null;
    });
  }

  RiderGpsStatus get gpsStatus => switch (locationController.state) {
    RiderLocationState.idle ||
    RiderLocationState.loading => RiderGpsStatus.checking,
    RiderLocationState.serviceDisabled => RiderGpsStatus.disabled,
    RiderLocationState.permissionDenied => RiderGpsStatus.permissionDenied,
    RiderLocationState.permissionDeniedForever =>
      RiderGpsStatus.permissionDeniedForever,
    RiderLocationState.approximateLocation =>
      RiderGpsStatus.approximateLocation,
    RiderLocationState.timedOut => RiderGpsStatus.timedOut,
    RiderLocationState.ready
        when (locationController.location?.accuracyMeters ?? 0) >
            poorAccuracyThresholdMeters =>
      RiderGpsStatus.poorAccuracy,
    RiderLocationState.ready => RiderGpsStatus.ready,
    RiderLocationState.error => RiderGpsStatus.unavailable,
  };

  RiderAvailabilityWarning? _markPoorAccuracy() {
    _warning = RiderAvailabilityWarning.poorGpsAccuracy;
    return null;
  }

  Future<bool> prepareForLogout() async {
    if (deliveryController.hasActiveDelivery ||
        availability == RiderAvailability.offline) {
      return true;
    }
    return (await setOnline(false)).isSuccess;
  }

  void clearWarning() {
    _warning = null;
    if (_syncState == RiderAvailabilitySyncState.error) {
      _syncState = RiderAvailabilitySyncState.idle;
    }
    _notify();
  }

  void _setInternetStatus(RiderInternetStatus status) {
    _internetStatus = status;
    if (status == RiderInternetStatus.online) {
      _reconnectTimer?.cancel();
      _reconnectTimer = null;
    } else if (status == RiderInternetStatus.offline ||
        status == RiderInternetStatus.backendUnavailable) {
      _scheduleReconnectChecks();
    }
  }

  void _scheduleReconnectChecks() {
    if (_isDisposed) return;
    if (_reconnectTimer != null || reconnectCheckInterval <= Duration.zero) {
      return;
    }
    _reconnectTimer = Timer.periodic(reconnectCheckInterval, (_) async {
      _internetStatus = RiderInternetStatus.reconnecting;
      _notify();
      final status = await _checkConnectivity();
      if (status == RiderInternetStatus.online) {
        if (_isDisposed) return;
        _setInternetStatus(status);
        _notify();
        await _restoreAuthoritativeStatus();
      } else if (!_isDisposed) {
        _setInternetStatus(status);
        _notify();
      }
    });
  }

  void _onConnectivityChanged(RiderInternetStatus status) {
    if (_isDisposed) return;
    final wasUnavailable = _internetStatus != RiderInternetStatus.online;
    _setInternetStatus(status);
    _notify();
    if (status == RiderInternetStatus.online && wasUnavailable) {
      unawaited(_restoreAuthoritativeStatus());
    }
  }

  Future<void> _restoreAuthoritativeStatus() {
    if (_isDisposed) return Future<void>.value();
    final existing = _restoreRequest;
    if (existing != null) return existing;
    final request = _restoreStatus();
    _restoreRequest = request;
    return request.whenComplete(() {
      if (identical(_restoreRequest, request)) _restoreRequest = null;
    });
  }

  Future<void> _restoreStatus() async {
    final riderId = _riderId;
    if (riderId == null || riderId.isEmpty) return;
    _syncState = RiderAvailabilitySyncState.synchronizing;
    _notify();
    try {
      final pendingWorkStatus = _pendingWorkStatus;
      if (pendingWorkStatus != null) {
        await _repository.saveAvailability(riderId, pendingWorkStatus);
        if (_isDisposed) return;
        _pendingWorkStatus = null;
      }
      final serverStatus = await _repository.loadAvailability(riderId);
      if (_isDisposed) return;
      var resolvedStatus = serverStatus;
      if (deliveryController.hasActiveDelivery &&
          !serverStatus.isHandlingDelivery) {
        resolvedStatus = availability.isHandlingDelivery
            ? availability
            : RiderAvailability.deliveryReserved;
        await _repository.saveAvailability(riderId, resolvedStatus);
        if (_isDisposed) return;
      }
      _lastObservedAvailability = resolvedStatus;
      await deliveryController.applyAuthoritativeAvailability(resolvedStatus);
      _syncState = RiderAvailabilitySyncState.idle;
      if (_warning == RiderAvailabilityWarning.synchronizationFailed) {
        _warning = null;
      }
    } catch (_) {
      _warning = RiderAvailabilityWarning.synchronizationFailed;
      _syncState = RiderAvailabilitySyncState.error;
    }
    _notify();
  }

  void _onDeliveryStatusChanged() {
    if (_isDisposed) return;
    final status = deliveryController.status.availability;
    if (_lastObservedAvailability == status) return;
    _lastObservedAvailability = status;
    final riderId = _riderId;
    if (riderId == null || riderId.isEmpty) return;
    _pendingWorkStatus = status;
    if (_internetStatus != RiderInternetStatus.online) return;
    _workStatusSync ??= _synchronizeWorkStatuses(
      riderId,
    ).whenComplete(() => _workStatusSync = null);
  }

  Future<void> _synchronizeWorkStatuses(String riderId) async {
    _syncState = RiderAvailabilitySyncState.synchronizing;
    _notify();
    try {
      while (_pendingWorkStatus != null) {
        final status = _pendingWorkStatus!;
        _pendingWorkStatus = null;
        try {
          await _repository.saveAvailability(riderId, status);
        } catch (_) {
          _pendingWorkStatus = status;
          rethrow;
        }
      }
      _syncState = RiderAvailabilitySyncState.idle;
    } catch (_) {
      _warning = RiderAvailabilityWarning.synchronizationFailed;
      _syncState = RiderAvailabilitySyncState.error;
    }
    _notify();
  }
}
