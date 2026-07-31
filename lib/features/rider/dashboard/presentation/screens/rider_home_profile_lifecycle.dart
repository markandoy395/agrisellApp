part of 'rider_home_screen.dart';

extension _RiderHomeProfileLifecycle on _RiderHomeScreenState {
  void _initializeControllers() {
    WidgetsBinding.instance.addObserver(this);
    _ownsDelivery =
        widget.deliveryController == null &&
        widget.availabilityController == null;
    _ownsAvailability = widget.availabilityController == null;
    _ownsDashboard = widget.dashboardController == null;
    _ownsLocation = widget.locationController == null && _ownsAvailability;
    _deliveryController =
        widget.deliveryController ??
        widget.availabilityController?.deliveryController ??
        RiderDeliveryController(
          stateStore: SharedPreferencesRiderDeliveryStateStore(),
        );
    _locationController =
        widget.locationController ??
        widget.availabilityController?.locationController ??
        RiderLocationController();
    _ownsMessages = widget.messagesController == null;
    _messagesController =
        widget.messagesController ??
        RiderMessagesController(offlineQueue: _deliveryController.offlineQueue);
    _availabilityController =
        widget.availabilityController ??
        RiderAvailabilityController(
          deliveryController: _deliveryController,
          locationController: _locationController,
        );
    _dashboardController =
        widget.dashboardController ?? RiderDashboardController();
    _analyticsController = RiderAnalyticsController(
      repository:
          AgrisellSupabase.isInitialized &&
              AgrisellSupabase.client.auth.currentUser != null
          ? SupabaseRiderAnalyticsRepository()
          : RiderDeliveryAnalyticsRepository(
              completionRecords: () => _deliveryController.completionHistory,
            ),
    );
    _safetyController = RiderSafetyController(
      offlineQueue: _deliveryController.offlineQueue,
    );
    _pageController = PageController(initialPage: _activeIndex);
    final profile = RiderRegistrationService.instance.currentProfile;
    _profile = profile;
    _riderId = profile?.id;
    _locationController.setCurrentRiderId(_riderId);
    _deliveryController.updateProfile(profile);
    _lastAvailability = _deliveryController.status.availability;
    _deliveryController.addListener(_syncAvailability);
    _availabilityController.addListener(_syncRequestEnvironment);
    _locationController.addListener(_syncRequestEnvironment);
    RiderRegistrationService.instance.addListener(_rebuildForProfileChange);
    _syncLiveLocationSharing();
    unawaited(_initializeRiderState());
  }

  Future<void> _initializeRiderState() async {
    if (AgrisellSupabase.isInitialized) {
      if (mounted) _updateState(() => _profileLoading = true);
      try {
        final profile = await RiderRegistrationService.instance
            .loadCurrentProfile();
        _profile = profile;
        _riderId = profile?.id;
        _locationController.setCurrentRiderId(_riderId);
        _deliveryController.updateProfile(profile);
        _profileError = profile == null
            ? 'The Rider profile could not be found.'
            : null;
      } on RiderRegistrationException catch (error) {
        _profileError = error.message;
      } finally {
        if (mounted) _updateState(() => _profileLoading = false);
      }
      if (_riderId == null) return;
    }
    final riderId = _riderId ?? '';
    await _deliveryController.restore(riderId: riderId);
    await Future.wait([
      _availabilityController.initialize(riderId: riderId),
      _dashboardController.load(riderId: riderId),
      _deliveryController.refreshCompletionHistory(riderId: riderId),
    ]);
    _syncCompletedCount();
    _syncLiveLocationSharing();
    _syncRequestEnvironment();
  }

  void _rebuildForProfileChange() {
    final profile = RiderRegistrationService.instance.currentProfile;
    _profile = profile;
    _riderId = profile?.id;
    _locationController.setCurrentRiderId(_riderId);
    _deliveryController.updateProfile(profile);
    if (mounted) _updateState(() {});
  }

  void _disposeControllers() {
    WidgetsBinding.instance.removeObserver(this);
    _deliveryController.removeListener(_syncAvailability);
    _availabilityController.removeListener(_syncRequestEnvironment);
    _locationController.removeListener(_syncRequestEnvironment);
    RiderRegistrationService.instance.removeListener(_rebuildForProfileChange);
    _locationController.setLiveSharing(false);
    _pageController.dispose();
    _safetyController.dispose();
    _analyticsController.dispose();
    if (_ownsDashboard) _dashboardController.dispose();
    if (_ownsAvailability) _availabilityController.dispose();
    if (_ownsLocation) _locationController.dispose();
    if (_ownsMessages) _messagesController.dispose();
    if (_ownsDelivery) _deliveryController.dispose();
  }
}
