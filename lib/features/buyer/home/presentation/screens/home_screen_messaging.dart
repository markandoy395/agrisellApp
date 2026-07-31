part of 'home_screen.dart';

extension _HomeScreenMessaging on _HomeScreenState {
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
        unawaited(
          Navigator.of(context).push(
            agrisellPageRoute<void>(
              builder: (_) => const OrderTrackingScreen(),
            ),
          ),
        );
        return;
      case 'messages':
        unawaited(_selectTab(HomeScreen.messageNavIndex));
        return;
      case 'products':
        unawaited(_selectTab(HomeScreen.homeNavIndex));
        return;
      case 'account':
        unawaited(_selectTab(HomeScreen.profileNavIndex));
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

  void _setMessageUnreadCount(int count) {
    _setBadgeCount(HomeScreen.messageNavIndex, count);
  }

  Future<void> _loadNotificationUnreadCount() async {
    final userId = AuthSessionService.instance.currentAccount?.id;
    final cachedCount = await loadCachedUnreadHomeNotificationCount(
      role: AuthRole.buyer,
      userId: userId,
    );
    if (mounted) _setNotificationUnreadCount(cachedCount);
    final count = await loadUnreadHomeNotificationCount(
      role: AuthRole.buyer,
      userId: userId,
    );
    if (mounted) _setNotificationUnreadCount(count);
  }

  void _setNotificationUnreadCount(int count) {
    _setBadgeCount(HomeScreen.notificationNavIndex, count);
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
}
