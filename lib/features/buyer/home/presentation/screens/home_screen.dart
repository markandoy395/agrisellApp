import 'dart:async';
import 'package:flutter/material.dart';
import 'package:agresell_app/core/widgets/app_snack_bar.dart';
import 'package:agresell_app/core/utils/agrisell_page_route.dart';
import 'package:agresell_app/core/services/push_notification_service.dart';
import 'package:agresell_app/features/auth/data/auth_session_service.dart';
import 'package:agresell_app/features/auth/domain/sign_up_account_data.dart';
import 'package:agresell_app/features/buyer/profile/presentation/screens/profile_screen.dart';
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
import 'package:agresell_app/features/buyer/home/presentation/styles/home_screen_styles.dart';

part 'home_screen_messaging.dart';
part 'home_screen_tabs.dart';

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
        backgroundColor: HomeScreenStyles.scaffoldBackground,
        bottomNavigationBar: CustomBottomNavBar(
          selectedIndex: _activeNavIndex,
          items: homeBottomNavItems,
          badgeCounts: _badgeCounts,
          background: HomeScreenStyles.navBarBackground,
          activeBackground: HomeScreenStyles.navBarActiveBackground,
          activeIconColor: HomeScreenStyles.navBarActiveIconColor,
          inactiveIconColor: HomeScreenStyles.navBarInactiveIconColor,
          inactiveLabelColor: HomeScreenStyles.navBarInactiveLabelColor,
          shadowColor: HomeScreenStyles.navBarShadowColor,
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
}
