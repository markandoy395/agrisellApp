part of 'home_screen.dart';

extension _HomeScreenTabs on _HomeScreenState {
  Widget _buildTab(BuildContext context, int index) {
    return switch (index) {
      HomeScreen.homeNavIndex => _KeepAliveTab(
        child: HomeDashboardContent(
          catalogController: _productCatalogController,
          onSelectTab: _selectTab,
          badgeCounts: _badgeCounts,
          onProductTap: _openProduct,
        ),
      ),
      HomeScreen.messageNavIndex => _KeepAliveTab(
        child: BuyerMessageScreen(
          isActive: _activeNavIndex == HomeScreen.messageNavIndex,
          repository: widget.messagingRepository,
          onUnreadCountChanged: _setMessageUnreadCount,
          chatBottomPadding: HomeScreenStyles.chatBottomPadding(
            MediaQuery.paddingOf(context).bottom,
          ),
        ),
      ),
      HomeScreen.farmerNavIndex => const _KeepAliveTab(child: FarmerScreen()),
      HomeScreen.notificationNavIndex => _KeepAliveTab(
        child: NotificationScreen(
          role: AuthRole.buyer,
          userId: AuthSessionService.instance.currentAccount?.id,
          onNotificationSelected: _openNotification,
          onUnreadCountChanged: _setNotificationUnreadCount,
        ),
      ),
      HomeScreen.profileNavIndex => const _KeepAliveTab(
        child: ProfileScreen(showSettingsIcon: true),
      ),
      _ => const SizedBox.shrink(),
    };
  }

  void _openNotification(HomeNotification notification) {
    switch (notification.destination) {
      case HomeNotificationDestination.orders ||
          HomeNotificationDestination.deliveries:
        unawaited(
          Navigator.of(context).push(
            agrisellPageRoute<void>(
              builder: (_) => const OrderTrackingScreen(),
            ),
          ),
        );
        return;
      case HomeNotificationDestination.messages:
        unawaited(_selectTab(HomeScreen.messageNavIndex));
        return;
      case HomeNotificationDestination.products:
        unawaited(_selectTab(HomeScreen.homeNavIndex));
        return;
      case HomeNotificationDestination.account:
        unawaited(_selectTab(HomeScreen.profileNavIndex));
        return;
      case HomeNotificationDestination.none:
        break;
    }
  }

  void _openProduct(
    HomeProduct product,
    HomeProductBrowseController browseController,
  ) {
    Navigator.of(context).push(
      agrisellMaterialPageRoute<void>(
        builder: (_) => ProductDetailScreen(
          product: product,
          catalogController: _productCatalogController,
          isSaved: browseController.isSaved,
          onSavedToggle: browseController.toggleSaved,
        ),
      ),
    );
  }
}

class _KeepAliveTab extends StatefulWidget {
  const _KeepAliveTab({required this.child});

  final Widget child;

  @override
  State<_KeepAliveTab> createState() => _KeepAliveTabState();
}

class _KeepAliveTabState extends State<_KeepAliveTab>
    with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return widget.child;
  }
}
