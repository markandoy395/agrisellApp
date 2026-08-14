import 'dart:async';

import 'package:flutter/material.dart';
import 'package:agresell_app/core/widgets/app_snack_bar.dart';

import 'package:agresell_app/core/theme/agrisell_colors.dart';
import 'package:agresell_app/core/services/agrisell_supabase.dart';
import 'package:agresell_app/core/services/push_notification_service.dart';
import 'package:agresell_app/core/utils/agrisell_page_route.dart';
import 'package:agresell_app/features/rider/chat/presentation/screens/rider_messages_screen.dart';
import 'package:agresell_app/features/rider/chat/presentation/controllers/rider_messages_controller.dart';
import 'package:agresell_app/features/rider/chat/presentation/screens/rider_notifications_screen.dart';
import 'package:agresell_app/features/rider/chat/domain/rider_conversation_access.dart';
import 'package:agresell_app/features/rider/chat/domain/rider_notification.dart';
import 'package:agresell_app/features/rider/chat/domain/rider_communication_models.dart';
import 'package:agresell_app/features/rider/chat/presentation/widgets/rider_chat_panel.dart';
import 'package:agresell_app/features/rider/dashboard/data/rider_bottom_nav_items.dart';
import 'package:agresell_app/features/rider/dashboard/data/rider_delivery_analytics_repository.dart';
import 'package:agresell_app/features/rider/dashboard/data/supabase_rider_analytics_repository.dart';
import 'package:agresell_app/features/rider/dashboard/presentation/controllers/rider_analytics_controller.dart';
import 'package:agresell_app/features/rider/dashboard/presentation/controllers/rider_availability_controller.dart';
import 'package:agresell_app/features/rider/dashboard/presentation/controllers/rider_dashboard_controller.dart';
import 'package:agresell_app/features/rider/dashboard/domain/rider_dashboard_state.dart';
import 'package:agresell_app/features/rider/dashboard/presentation/screens/rider_dashboard_screen.dart';
import 'package:agresell_app/features/rider/dashboard/presentation/screens/rider_earnings_screen.dart';
import 'package:agresell_app/features/rider/dashboard/presentation/widgets/rider_keep_alive_tab.dart';
import 'package:agresell_app/features/rider/deliveries/data/shared_preferences_rider_delivery_state_store.dart';
import 'package:agresell_app/features/rider/deliveries/data/delivery_proof_storage.dart';
import 'package:agresell_app/features/rider/deliveries/domain/delivery_completion.dart';
import 'package:agresell_app/features/rider/deliveries/presentation/controllers/rider_delivery_controller.dart';
import 'package:agresell_app/features/rider/deliveries/presentation/controllers/rider_location_controller.dart';
import 'package:agresell_app/features/rider/deliveries/domain/rider_delivery_search.dart';
import 'package:agresell_app/features/rider/deliveries/domain/rider_live_location_policy.dart';
import 'package:agresell_app/features/rider/deliveries/domain/delivery_stage.dart';
import 'package:agresell_app/features/rider/deliveries/presentation/screens/rider_deliveries_screen.dart';
import 'package:agresell_app/features/rider/deliveries/presentation/screens/rider_delivery_details_screen.dart';
import 'package:agresell_app/features/rider/deliveries/presentation/screens/rider_map_screen.dart';
import 'package:agresell_app/features/rider/profile/data/rider_registration_service.dart';
import 'package:agresell_app/features/rider/profile/domain/rider_profile.dart';
import 'package:agresell_app/features/rider/profile/presentation/screens/rider_profile_screen.dart';
import 'package:agresell_app/features/rider/safety/domain/rider_safety_action.dart';
import 'package:agresell_app/features/rider/safety/presentation/controllers/rider_safety_controller.dart';
import 'package:agresell_app/features/rider/safety/presentation/widgets/rider_safety_sheet.dart';
import 'package:agresell_app/features/shared/widgets/navigation/custom_bottom_nav_bar.dart';

part 'rider_home_tabs.dart';
part 'rider_home_lifecycle.dart';
part 'rider_home_navigation.dart';
part 'rider_home_profile_lifecycle.dart';

class RiderHomeScreen extends StatefulWidget {
  const RiderHomeScreen({
    this.deliveryController,
    this.availabilityController,
    this.dashboardController,
    this.locationController,
    this.messagesController,
    super.key,
  });

  static const homeNavIndex = 0;
  static const deliveriesNavIndex = 1;
  static const mapNavIndex = 2;
  static const messagesNavIndex = 3;
  static const profileNavIndex = 4;

  final RiderDeliveryController? deliveryController;
  final RiderAvailabilityController? availabilityController;
  final RiderDashboardController? dashboardController;
  final RiderLocationController? locationController;
  final RiderMessagesController? messagesController;

  @override
  State<RiderHomeScreen> createState() => _RiderHomeScreenState();
}

class _RiderHomeScreenState extends State<RiderHomeScreen>
    with WidgetsBindingObserver {
  late final RiderDeliveryController _deliveryController;
  late final RiderAvailabilityController _availabilityController;
  late final RiderDashboardController _dashboardController;
  late final RiderLocationController _locationController;
  late final RiderMessagesController _messagesController;
  late final RiderSafetyController _safetyController;
  late final RiderAnalyticsController _analyticsController;
  final DeliveryProofStorage _communicationStorage = DeliveryProofStorage();
  late final PageController _pageController;
  String? _riderId;
  RiderProfile? _profile;
  bool _profileLoading = false;
  String? _profileError;
  late final bool _ownsDelivery;
  late final bool _ownsAvailability;
  late final bool _ownsDashboard;
  late final bool _ownsLocation;
  late final bool _ownsMessages;
  var _activeIndex = RiderHomeScreen.homeNavIndex;
  StreamSubscription<PushNotificationAction>? _pushSubscription;
  DateTime? _backgroundedAt;
  bool _isAppInForeground = true;
  RiderAvailability? _lastAvailability;
  bool? _lastTrackingRequested;
  int? _lastCompletedToday;

  @override
  void initState() {
    super.initState();
    _initializeControllers();
    _pushSubscription = PushNotificationService.instance.actions.listen(
      _openPushAction,
    );
    _consumePendingPushAction();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    _handleLifecycleState(state);
  }

  void _setActiveIndex(int index) {
    if (mounted) {
      setState(() => _activeIndex = index);
      _syncLiveLocationSharing();
    }
  }

  void _handlePageChanged(int index) {
    if (index == _activeIndex) return;
    _setActiveIndex(index);
  }

  void _updateState(VoidCallback change) => setState(change);

  @override
  void dispose() {
    _pushSubscription?.cancel();
    _disposeControllers();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final profile = _profile;
    if (_profileLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }
    final profileError = _profileError;
    if (profileError != null) {
      return Scaffold(
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(22),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(profileError, textAlign: TextAlign.center),
                const SizedBox(height: 12),
                OutlinedButton(
                  onPressed: () {
                    setState(() => _profileError = null);
                    unawaited(_initializeRiderState());
                  },
                  child: const Text('Retry'),
                ),
              ],
            ),
          ),
        ),
      );
    }
    return Scaffold(
      extendBody: true,
      backgroundColor: AgrisellColors.homeBackground,
      bottomNavigationBar: CustomBottomNavBar(
        selectedIndex: _activeIndex,
        items: riderBottomNavItems,
        background: AgrisellColors.surface,
        activeBackground: AgrisellColors.authGreen,
        activeIconColor: AgrisellColors.surface,
        inactiveIconColor: AgrisellColors.brandBlack,
        inactiveLabelColor: AgrisellColors.brandBlack,
        shadowColor: AgrisellColors.brandBlack.withValues(alpha: 0.16),
        onItemSelected: _selectTab,
      ),
      body: PageView.builder(
        controller: _pageController,
        onPageChanged: _handlePageChanged,
        physics: const ClampingScrollPhysics(),
        itemCount: riderBottomNavItems.length,
        itemBuilder: (context, index) => _buildTab(index, profile),
      ),
    );
  }
}
