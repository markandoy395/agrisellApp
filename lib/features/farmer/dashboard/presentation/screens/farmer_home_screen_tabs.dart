part of 'farmer_home_screen.dart';

extension _FarmerHomeScreenTabs on _FarmerHomeScreenState {
  Future<void> _refreshSelectedTab(int index) async {
    if (index == FarmerHomeScreen.productNavIndex) {
      await AuthRegistrationService.instance.loadCurrentAccount();
    } else if (index == FarmerHomeScreen.reserveNavIndex) {
      await OrderController.instance.reload();
    }
  }

  void _openQuickDestination(FarmerQuickDestination destination) {
    if (destination == FarmerQuickDestination.payouts) {
      Navigator.of(context).push(
        agrisellPageRoute<void>(
          builder: (_) => const FarmerPayoutHistoryScreen(),
        ),
      );
      return;
    }
    if (destination == FarmerQuickDestination.discounts) {
      Navigator.of(context).push(
        agrisellPageRoute<void>(builder: (_) => const FarmerDiscountsScreen()),
      );
      return;
    }
    if (destination == FarmerQuickDestination.reviews) {
      Navigator.of(context).push(
        agrisellPageRoute<void>(builder: (_) => const FarmerReviewsScreen()),
      );
      return;
    }
    final index = switch (destination) {
      FarmerQuickDestination.products => FarmerHomeScreen.productNavIndex,
      FarmerQuickDestination.messages => FarmerHomeScreen.messageNavIndex,
      FarmerQuickDestination.reservations => FarmerHomeScreen.reserveNavIndex,
      FarmerQuickDestination.account => FarmerHomeScreen.profileNavIndex,
      FarmerQuickDestination.discounts => FarmerHomeScreen.productNavIndex,
      FarmerQuickDestination.payouts => FarmerHomeScreen.productNavIndex,
      FarmerQuickDestination.reviews => FarmerHomeScreen.productNavIndex,
    };
    unawaited(_selectTab(index));
  }

  Widget _buildTab(BuildContext context, int index) {
    return switch (index) {
      FarmerHomeScreen.productNavIndex => _FarmerKeepAliveTab(
        child: FarmerDashboardScreen(onNavigate: _openQuickDestination),
      ),
      FarmerHomeScreen.messageNavIndex => _FarmerKeepAliveTab(
        child: FarmerMessageScreen(
          isActive: _activeNavIndex == FarmerHomeScreen.messageNavIndex,
          repository: widget.messagingRepository,
          onUnreadCountChanged: _setMessageUnreadCount,
        ),
      ),
      FarmerHomeScreen.reserveNavIndex => _FarmerKeepAliveTab(
        child: FarmerReserveScreen(onNavigate: _openQuickDestination),
      ),
      FarmerHomeScreen.notificationNavIndex => _FarmerKeepAliveTab(
        child: NotificationScreen(
          role: AuthRole.farmer,
          userId: AuthSessionService.instance.currentAccount?.id,
          onNotificationSelected: _openNotification,
          onUnreadCountChanged: _setNotificationUnreadCount,
        ),
      ),
      FarmerHomeScreen.profileNavIndex => const _FarmerKeepAliveTab(
        child: FarmerProfileScreen(),
      ),
      _ => const SizedBox.shrink(),
    };
  }
}

class _FarmerKeepAliveTab extends StatefulWidget {
  const _FarmerKeepAliveTab({required this.child});

  final Widget child;

  @override
  State<_FarmerKeepAliveTab> createState() => _FarmerKeepAliveTabState();
}

class _FarmerKeepAliveTabState extends State<_FarmerKeepAliveTab>
    with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return widget.child;
  }
}
