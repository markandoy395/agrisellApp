import 'dart:async';
import 'package:flutter/material.dart';
import 'package:agresell_app/core/widgets/app_snack_bar.dart';
import 'package:agresell_app/core/utils/agrisell_page_route.dart';
import 'package:agresell_app/core/services/push_notification_service.dart';
import 'package:agresell_app/features/auth/data/auth_session_service.dart';
import 'package:agresell_app/features/auth/domain/sign_up_account_data.dart';
import 'package:agresell_app/core/theme/agrisell_colors.dart';
import 'package:agresell_app/features/shared/chat/data/marketplace_messaging_repository.dart';
import 'package:agresell_app/features/shared/chat/data/marketplace_messaging_repository_factory.dart';
import 'package:agresell_app/features/shared/products/data/home_product_repository.dart';
import 'package:agresell_app/features/shared/products/domain/home_product.dart';
import 'package:agresell_app/features/shared/products/presentation/controllers/home_product_catalog_controller.dart';
import 'package:agresell_app/features/buyer/home/data/home_bottom_nav_items.dart';
import 'package:agresell_app/features/buyer/home/presentation/widgets/common/buyer_responsive_text.dart';
import 'package:agresell_app/features/buyer/home/presentation/controllers/home_product_browse_controller.dart';
import 'package:agresell_app/features/buyer/home/presentation/widgets/home/home_dashboard_content.dart';
import 'package:agresell_app/features/shared/widgets/navigation/custom_bottom_nav_bar.dart';
import 'package:agresell_app/features/buyer/chat/presentation/screens/buyer_message_screen.dart';
import 'package:agresell_app/features/buyer/home/presentation/screens/farmer_screen.dart';
import 'package:agresell_app/features/buyer/home/presentation/screens/product_detail_screen.dart';
import 'package:agresell_app/features/shared/orders/presentation/screens/notification_screen.dart';
import 'package:agresell_app/features/shared/orders/data/home_notification_badge_loader.dart';
import 'package:agresell_app/features/shared/orders/domain/home_notification.dart';
import 'package:agresell_app/features/buyer/orders/presentation/screens/order_tracking_screen.dart';
import 'package:agresell_app/features/buyer/profile/presentation/screens/profile_screen.dart';
part 'home_screen_messaging.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({
    this.initialNavIndex = homeNavIndex,
    this.initialMessage,
    this.messagingRepository,
    this.productRepository = const HomeProductRepository(),
    super.key,
  });

  static const homeNavIndex = 0;
  static const messageNavIndex = 1;
  static const farmerNavIndex = 2;
  static const notificationNavIndex = 3;
  static const profileNavIndex = 4;

  final int initialNavIndex;
  final String? initialMessage;
  final MarketplaceMessagingRepository? messagingRepository;
  final HomeProductRepository productRepository;

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late final PageController _navigationController;
  late final HomeProductCatalogController _productCatalogController;
  late final Map<int, int> _badgeCounts;
  late int _activeNavIndex;
  StreamSubscription<PushNotificationAction>? _pushSubscription;

  void _updateUi(VoidCallback update) => setState(update);

  @override
  void initState() {
    super.initState();
    _activeNavIndex = widget.initialNavIndex
        .clamp(0, homeBottomNavItems.length - 1)
        .toInt();
    _navigationController = PageController(initialPage: _activeNavIndex);
    _productCatalogController = HomeProductCatalogController(
      repository: widget.productRepository,
    );
    _badgeCounts = <int, int>{};
    _pushSubscription = PushNotificationService.instance.actions.listen(
      _openPushAction,
    );
    _consumePendingPushAction();
    unawaited(_productCatalogController.load());
    unawaited(_loadMessageUnreadCount());
    unawaited(_loadNotificationUnreadCount());
    final initialMessage = widget.initialMessage;
    if (initialMessage != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        ScaffoldMessenger.of(context)
          ..clearSnackBars()
          ..showAppSnackBar(SnackBar(content: Text(initialMessage)));
      });
    }
  }

  @override
  void dispose() {
    _pushSubscription?.cancel();
    _navigationController.dispose();
    _productCatalogController.dispose();
    super.dispose();
  }

  Future<void> _selectTab(int index) async {
    if (index == _activeNavIndex) return;

    setState(() {
      _activeNavIndex = index;
    });
    _navigationController.jumpToPage(index);
  }

  void _handlePageChanged(int index) {
    if (index == _activeNavIndex) return;
    setState(() {
      _activeNavIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return BuyerResponsiveText(
      child: Scaffold(
        extendBody: true,
        backgroundColor: AgrisellColors.homeBackground,
        bottomNavigationBar: CustomBottomNavBar(
          selectedIndex: _activeNavIndex,
          items: homeBottomNavItems,
          badgeCounts: _badgeCounts,
          background: AgrisellColors.surface,
          activeBackground: AgrisellColors.authGreen,
          activeIconColor: AgrisellColors.surface,
          inactiveIconColor: AgrisellColors.brandBlack,
          inactiveLabelColor: AgrisellColors.brandBlack,
          shadowColor: AgrisellColors.brandBlack.withValues(alpha: 0.16),
          onItemSelected: _selectTab,
        ),
        body: PageView.builder(
          controller: _navigationController,
          onPageChanged: _handlePageChanged,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: homeBottomNavItems.length,
          itemBuilder: _buildTab,
        ),
      ),
    );
  }

  Widget _buildTab(BuildContext context, int index) {
    return switch (index) {
      HomeScreen.homeNavIndex => _KeepAliveTab(
        child: HomeDashboardContent(
          catalogController: _productCatalogController,
          onProductTap: _openProduct,
        ),
      ),
      HomeScreen.messageNavIndex => _KeepAliveTab(
        child: BuyerMessageScreen(
          isActive: _activeNavIndex == HomeScreen.messageNavIndex,
          repository: widget.messagingRepository,
          onUnreadCountChanged: _setMessageUnreadCount,
          chatBottomPadding: MediaQuery.paddingOf(context).bottom + 8,
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
      HomeScreen.profileNavIndex =>
          const _KeepAliveTab(child: ProfileScreen(showSettingsIcon: true)),
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
      MaterialPageRoute<void>(
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
