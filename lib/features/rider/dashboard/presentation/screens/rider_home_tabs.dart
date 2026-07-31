part of 'rider_home_screen.dart';

extension _RiderHomeTabs on _RiderHomeScreenState {
  Future<void> _openSafetySupport() async {
    final riderId = _riderId;
    if (riderId == null) return;
    final type = await showRiderSafetySheet(context);
    if (type == null || !mounted) return;
    final reason = await showRiderSafetyReasonDialog(context, type);
    if (type.requiresReason && reason == null) return;
    final success = await _safetyController.submit(
      riderId: riderId,
      type: type,
      reason: reason,
    );
    if (!mounted) return;
    final message = success
        ? _safetyController.errorMessage ?? '${type.label} sent to support.'
        : _safetyController.errorMessage ?? 'Support is unavailable.';
    ScaffoldMessenger.of(
      context,
    ).showAppSnackBar(SnackBar(content: Text(message)));
  }

  List<Widget> _tabs(RiderProfile? profile) => [
    RiderKeepAliveTab(
      child: RiderDashboardScreen(
        profile: profile,
        deliveryController: _deliveryController,
        availabilityController: _availabilityController,
        dashboardController: _dashboardController,
        riderId: _riderId,
        onOpenDeliveries: () => _selectTab(RiderHomeScreen.deliveriesNavIndex),
        onOpenMap: () => _selectTab(RiderHomeScreen.mapNavIndex),
        onOpenMessages: () => _selectTab(RiderHomeScreen.messagesNavIndex),
        onOpenEarnings: _openEarnings,
        onOpenNotifications: _openNotifications,
        onSafetySupport: _openSafetySupport,
      ),
    ),
    RiderKeepAliveTab(
      child: RiderDeliveriesScreen(
        profile: profile,
        deliveryController: _deliveryController,
        riderId: _riderId,
        onRetryLocation: () => unawaited(
          _availabilityController.refreshEnvironment(refreshLocation: true),
        ),
        onOpenLocationSettings: () =>
            unawaited(_locationController.openLocationSettings()),
        onOpenAppSettings: () =>
            unawaited(_locationController.openAppSettings()),
        onOpenProfile: () => _selectTab(RiderHomeScreen.profileNavIndex),
      ),
    ),
    RiderKeepAliveTab(
      child: RiderMapScreen(
        profile: profile,
        deliveryController: _deliveryController,
        locationController: _locationController,
        availabilityController: _availabilityController,
        isActive: _activeIndex == RiderHomeScreen.mapNavIndex,
        onOpenList: () => _selectTab(RiderHomeScreen.homeNavIndex),
      ),
    ),
    RiderKeepAliveTab(
      child: RiderMessagesScreen(
        riderId: _riderId ?? '',
        controller: _messagesController,
        access: _conversationAccess,
        onAttachmentRequested: _captureCommunicationAttachment,
      ),
    ),
    RiderKeepAliveTab(
      child: RiderProfileScreen(
        profile: profile,
        analyticsController: _analyticsController,
        deliveryController: _deliveryController,
        prepareForLogout: _availabilityController.prepareForLogout,
      ),
    ),
  ];

  RiderConversationAccess get _conversationAccess => RiderConversationAccess(
    activeDeliveryIds: {
      for (final request in _deliveryController.requests)
        if (request.isAssignedTo(_riderId ?? '') && !request.stage.isTerminal)
          request.id,
    },
    historyDeliveryIds: {
      for (final record in _deliveryController.completionHistory)
        record.request.id,
    },
    supportAuthorized: (_riderId ?? '').isNotEmpty,
  );

  Future<String?> _captureCommunicationAttachment(
    RiderCommunicationAction action,
  ) async {
    final activeId = _deliveryController.requests
        .where(
          (request) =>
              request.isAssignedTo(_riderId ?? '') && !request.stage.isTerminal,
        )
        .firstOrNull
        ?.id;
    final deliveryId = action.deliveryId ?? activeId;
    if (deliveryId == null) return null;
    try {
      return switch (action.type) {
        RiderCommunicationActionType.attachPhoto =>
          await _communicationStorage.capturePhoto(deliveryId: deliveryId),
        RiderCommunicationActionType.shareLocation =>
          _deliveryController.currentRiderLocation == null
              ? null
              : await _communicationStorage.saveAttestation(
                  deliveryId: deliveryId,
                  method: DeliveryConfirmationMethod.gpsLocation,
                ),
        RiderCommunicationActionType.call ||
        RiderCommunicationActionType.contactSupport => null,
      };
    } on DeliveryProofStorageException catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showAppSnackBar(SnackBar(content: Text(error.message)));
      }
      return null;
    }
  }

  void _openEarnings() {
    Navigator.of(context).push(
      agrisellPageRoute<void>(
        builder: (_) => RiderEarningsScreen(
          riderId: _riderId ?? '',
          controller: _analyticsController,
        ),
      ),
    );
  }
}
