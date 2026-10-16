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
        child: AnimatedBuilder(
          animation: _dashboardController,
          builder: (context, _) => RiderDeliveriesScreen(
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
            onOpenMap: () => _selectTab(RiderHomeScreen.mapNavIndex),
            onOpenNotifications: _openNotifications,
            unreadNotifications:
                _dashboardController.metrics.unreadNotificationCount,
          ),
        ),
      ),
      RiderHomeScreen.mapNavIndex => RiderKeepAliveTab(
        child: AnimatedBuilder(
          animation: _dashboardController,
          builder: (context, _) => RiderMapScreen(
            profile: profile,
            deliveryController: _deliveryController,
            locationController: _locationController,
            availabilityController: _availabilityController,
            isActive: _activeIndex == RiderHomeScreen.mapNavIndex,
            onOpenList: () => _selectTab(RiderHomeScreen.deliveriesNavIndex),
            onOpenNotifications: _openNotifications,
            unreadNotifications:
                _dashboardController.metrics.unreadNotificationCount,
            onOpenConversation: _openDeliveryConversation,
          ),
        ),
      ),
      RiderHomeScreen.messagesNavIndex => RiderKeepAliveTab(
        child: AnimatedBuilder(
          animation: _dashboardController,
          builder: (context, _) => RiderMessagesScreen(
            riderId: _riderId ?? '',
            controller: _messagesController,
            access: _conversationAccess,
            onOpenNotifications: _openNotifications,
            unreadNotifications:
                _dashboardController.metrics.unreadNotificationCount,
          ),
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
