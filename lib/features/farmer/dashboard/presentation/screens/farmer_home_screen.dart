import 'dart:async';

import 'package:flutter/material.dart';

import 'package:agresell_app/features/auth/data/auth_registration_service.dart';
import 'package:agresell_app/features/auth/data/auth_session_service.dart';
import 'package:agresell_app/features/auth/domain/sign_up_account_data.dart';
import 'package:agresell_app/core/theme/agrisell_colors.dart';
import 'package:agresell_app/core/services/push_notification_service.dart';
import 'package:agresell_app/features/farmer/dashboard/data/farmer_bottom_nav_items.dart';
import 'package:agresell_app/features/shared/chat/data/marketplace_messaging_repository.dart';
import 'package:agresell_app/features/shared/chat/data/marketplace_messaging_repository_factory.dart';
import 'package:agresell_app/features/shared/widgets/navigation/custom_bottom_nav_bar.dart';
import 'package:agresell_app/features/farmer/dashboard/presentation/screens/farmer_dashboard_screen.dart';
import 'package:agresell_app/features/farmer/dashboard/presentation/widgets/farmer_quick_menu.dart';
import 'package:agresell_app/features/farmer/profile/presentation/screens/farmer_profile_screen.dart';
import 'package:agresell_app/features/farmer/chat/presentation/screens/farmer_message_screen.dart';
import 'package:agresell_app/features/farmer/reservations/presentation/screens/farmer_reserve_screen.dart';
import 'package:agresell_app/features/shared/orders/presentation/screens/notification_screen.dart';
import 'package:agresell_app/features/shared/orders/data/home_notification_badge_loader.dart';
import 'package:agresell_app/features/shared/orders/domain/home_notification.dart';
import 'package:agresell_app/features/shared/orders/presentation/controllers/order_controller.dart';
import 'package:agresell_app/core/utils/agrisell_page_route.dart';
import 'package:agresell_app/features/farmer/payouts/presentation/screens/farmer_payout_history_screen.dart';
import 'package:agresell_app/features/farmer/discounts/presentation/screens/farmer_discounts_screen.dart';
import 'package:agresell_app/features/farmer/reviews/presentation/screens/farmer_reviews_screen.dart';
import 'package:agresell_app/features/shared/orders/presentation/widgets/notification/notification_approval_alert.dart';

part 'farmer_home_screen_messaging.dart';

class FarmerHomeScreen extends StatefulWidget {
  const FarmerHomeScreen({
    this.initialNavIndex = productNavIndex,
    this.messagingRepository,
    super.key,
  });

  static const productNavIndex = 0;
  static const messageNavIndex = 1;
  static const reserveNavIndex = 2;
  static const notificationNavIndex = 3;
  static const profileNavIndex = 4;

  final int initialNavIndex;
  final MarketplaceMessagingRepository? messagingRepository;

  @override
  State<FarmerHomeScreen> createState() => _FarmerHomeScreenState();
}

class _FarmerHomeScreenState extends State<FarmerHomeScreen> {
  late final PageController _navigationController;
  late final Map<int, int> _badgeCounts;
  late int _activeNavIndex;
  StreamSubscription<PushNotificationAction>? _pushSubscription;

  void _updateUi(VoidCallback update) => setState(update);

  @override
  void initState() {
    super.initState();
    _activeNavIndex = widget.initialNavIndex
        .clamp(0, farmerBottomNavItems.length - 1)
        .toInt();
    _navigationController = PageController(initialPage: _activeNavIndex);
    final reservationCount =
        OrderController.instance.activeFarmerReservationCount;
    _badgeCounts = <int, int>{
      if (reservationCount > 0)
        FarmerHomeScreen.reserveNavIndex: reservationCount,
    };
    OrderController.instance.addListener(_syncReserveBadge);
    _pushSubscription = PushNotificationService.instance.actions.listen(
      _openPushAction,
    );
    _consumePendingPushAction();
    unawaited(_loadMessageUnreadCount());
    unawaited(_loadNotificationUnreadCount());
    unawaited(
      showFarmerApprovalAlertForUser(
        context,
        AuthSessionService.instance.currentAccount?.id,
      ),
    );
  }

  @override
  void dispose() {
    OrderController.instance.removeListener(_syncReserveBadge);
    _pushSubscription?.cancel();
    _navigationController.dispose();
    super.dispose();
  }

  Future<void> _selectTab(int index) async {
    if (index == _activeNavIndex) return;

    setState(() {
      _activeNavIndex = index;
    });
    _navigationController.jumpToPage(index);
    unawaited(_refreshSelectedTab(index));
  }

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
        agrisellPageRoute<void>(
          builder: (_) => const FarmerDiscountsScreen(),
        ),
      );
      return;
    }
    if (destination == FarmerQuickDestination.reviews) {
      Navigator.of(context).push(
        agrisellPageRoute<void>(
          builder: (_) => const FarmerReviewsScreen(),
        ),
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBody: true,
      backgroundColor: AgrisellColors.homeBackground,
      bottomNavigationBar: CustomBottomNavBar(
        selectedIndex: _activeNavIndex,
        items: farmerBottomNavItems,
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
        itemCount: farmerBottomNavItems.length,
        itemBuilder: _buildTab,
      ),
    );
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
        child: FarmerProfileScreen(showSettingsIcon: true),
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
