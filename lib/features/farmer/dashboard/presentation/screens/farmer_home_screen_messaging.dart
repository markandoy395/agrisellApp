part of 'farmer_home_screen.dart';

extension _FarmerHomeScreenMessaging on _FarmerHomeScreenState {
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
        unawaited(_selectTab(FarmerHomeScreen.reserveNavIndex));
        return;
      case 'messages':
        unawaited(_selectTab(FarmerHomeScreen.messageNavIndex));
        return;
      case 'products':
        unawaited(_selectTab(FarmerHomeScreen.productNavIndex));
        return;
      case 'account':
        unawaited(_selectTab(FarmerHomeScreen.profileNavIndex));
        return;
      default:
        return;
    }
  }

  Future<void> _loadMessageUnreadCount() async {
    try {
      final repository =
          widget.messagingRepository ?? currentMarketplaceMessagingRepository();
      final conversations = await repository.loadConversations();
      if (!mounted) return;
      _setMessageUnreadCount(
        conversations.fold(0, (total, item) => total + item.unreadCount),
      );
    } on Object {
      // Keep the last reliable badge when an unread refresh is unavailable.
    }
  }

  void _handlePageChanged(int index) {
    if (index == _activeNavIndex) return;
    _updateUi(() {
      _activeNavIndex = index;
    });
  }

  void _setMessageUnreadCount(int count) {
    _setBadgeCount(FarmerHomeScreen.messageNavIndex, count);
  }

  Future<void> _loadNotificationUnreadCount() async {
    final userId = AuthSessionService.instance.currentAccount?.id;
    final cachedCount = await loadCachedUnreadHomeNotificationCount(
      role: AuthRole.farmer,
      userId: userId,
    );
    if (mounted) _setNotificationUnreadCount(cachedCount);
    final count = await loadUnreadHomeNotificationCount(
      role: AuthRole.farmer,
      userId: userId,
    );
    if (mounted) _setNotificationUnreadCount(count);
  }

  void _setNotificationUnreadCount(int count) {
    _setBadgeCount(FarmerHomeScreen.notificationNavIndex, count);
  }

  void _syncReserveBadge() {
    if (!mounted) return;
    _setBadgeCount(
      FarmerHomeScreen.reserveNavIndex,
      OrderController.instance.activeFarmerReservationCount,
    );
  }

  void _setBadgeCount(int index, int count) {
    final normalized = count < 0 ? 0 : count;
    if ((_badgeCounts[index] ?? 0) == normalized) return;
    _updateUi(() {
      if (normalized == 0) {
        _badgeCounts.remove(index);
      } else {
        _badgeCounts[index] = normalized;
      }
    });
  }

  void _openNotification(HomeNotification notification) {
    switch (notification.destination) {
      case HomeNotificationDestination.orders ||
          HomeNotificationDestination.deliveries:
        unawaited(_selectTab(FarmerHomeScreen.reserveNavIndex));
        return;
      case HomeNotificationDestination.messages:
        unawaited(_selectTab(FarmerHomeScreen.messageNavIndex));
        return;
      case HomeNotificationDestination.products:
        unawaited(_selectTab(FarmerHomeScreen.productNavIndex));
        return;
      case HomeNotificationDestination.account:
        unawaited(_selectTab(FarmerHomeScreen.profileNavIndex));
        return;
      case HomeNotificationDestination.none:
        break;
    }
  }
}
