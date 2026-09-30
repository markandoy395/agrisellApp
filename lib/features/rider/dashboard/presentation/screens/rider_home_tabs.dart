part of 'rider_home_screen.dart';

extension _RiderHomeTabs on _RiderHomeScreenState {
  Future<void> _openSafetySupport() async {
    final profile = RiderRegistrationService.instance.currentProfile;
    await showAppSafetySheet(
      context: context,
      role: 'rider',
      userName: profile?.fullName,
      userContact: profile?.contactNumber,
      userEmail: profile?.email,
    );
  }

  Widget _buildTab(int index, RiderProfile? profile) {
    return switch (index) {
      RiderHomeScreen.homeNavIndex => RiderKeepAliveTab(
        child: RiderDashboardScreen(
          profile: profile,
          deliveryController: _deliveryController,
          availabilityController: _availabilityController,
          dashboardController: _dashboardController,
          riderId: _riderId,
          onOpenDeliveries: () =>
              _selectTab(RiderHomeScreen.deliveriesNavIndex),
          onOpenMap: () => _selectTab(RiderHomeScreen.mapNavIndex),
          onOpenMessages: () => _selectTab(RiderHomeScreen.messagesNavIndex),
          onOpenEarnings: _openEarnings,
          onOpenNotifications: _openNotifications,
          onSafetySupport: _openSafetySupport,
        ),
      ),
      RiderHomeScreen.deliveriesNavIndex => RiderKeepAliveTab(
        child: RiderDeliveriesScreen(
          profile: profile,
          deliveryController: _deliveryController,
          riderId: _riderId,
          locationController: _locationController,
          onRetryLocation: () => unawaited(
            _availabilityController.refreshEnvironment(refreshLocation: true),
          ),
          onOpenLocationSettings: () =>
              unawaited(_locationController.openLocationSettings()),
          onOpenAppSettings: () =>
              unawaited(_locationController.openAppSettings()),
          onOpenProfile: () => _selectTab(RiderHomeScreen.profileNavIndex),
          onOpenConversation: _openDeliveryConversation,
        ),
      ),
      RiderHomeScreen.mapNavIndex => RiderKeepAliveTab(
        child: RiderMapScreen(
          profile: profile,
          deliveryController: _deliveryController,
          locationController: _locationController,
          availabilityController: _availabilityController,
          isActive: _activeIndex == RiderHomeScreen.mapNavIndex,
          onOpenList: () => _selectTab(RiderHomeScreen.homeNavIndex),
        ),
      ),
      RiderHomeScreen.messagesNavIndex => RiderKeepAliveTab(
        child: RiderMessagesScreen(
          riderId: _riderId ?? '',
          controller: _messagesController,
          access: _conversationAccess,
          onAttachmentRequested: _captureCommunicationAttachment,
        ),
      ),
      RiderHomeScreen.profileNavIndex => RiderKeepAliveTab(
        child: RiderProfileScreen(
          profile: profile,
          analyticsController: _analyticsController,
          deliveryController: _deliveryController,
          prepareForLogout: _availabilityController.prepareForLogout,
        ),
      ),
      _ => const SizedBox.shrink(),
    };
  }

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
    if (deliveryId == null) {
      _showCommunicationMessage(
        'An active delivery is required to share an attachment.',
      );
      return null;
    }
    if (action.type == RiderCommunicationActionType.shareLocation &&
        _deliveryController.currentRiderLocation == null) {
      _showCommunicationMessage(
        'Current GPS location is unavailable. Enable precise location and try again.',
      );
      return null;
    }
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

  void _showCommunicationMessage(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(
      context,
    ).showAppSnackBar(SnackBar(content: Text(message)));
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
