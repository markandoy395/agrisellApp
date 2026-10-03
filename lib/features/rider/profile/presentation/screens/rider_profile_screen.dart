import 'dart:async';

import 'package:flutter/material.dart';
import 'package:agresell_app/core/widgets/app_snack_bar.dart';

import 'package:agresell_app/core/utils/agrisell_page_route.dart';
import 'package:agresell_app/features/auth/data/auth_registration_service.dart';
import 'package:agresell_app/features/auth/presentation/account_session_navigation.dart';
import 'package:agresell_app/features/rider/profile/data/rider_registration_service.dart';
import 'package:agresell_app/features/rider/profile/domain/rider_account_exit_policy.dart';
import 'package:agresell_app/features/rider/profile/domain/rider_profile.dart';
import 'package:agresell_app/features/rider/profile/presentation/styles/rider_profile_screen_styles.dart';
import 'package:agresell_app/features/rider/dashboard/presentation/controllers/rider_analytics_controller.dart';
import 'package:agresell_app/features/rider/safety/presentation/controllers/rider_safety_controller.dart';
import 'package:agresell_app/features/rider/presentation/widgets/rider_page_widgets.dart';
import 'package:agresell_app/features/rider/presentation/widgets/rider_state_cards.dart';
import 'package:agresell_app/features/rider/profile/presentation/widgets/rider_password_dialog.dart';
import 'package:agresell_app/features/rider/profile/presentation/widgets/rider_profile_edit_dialog.dart';
import 'package:agresell_app/features/rider/profile/presentation/widgets/rider_profile_overview.dart';
import 'package:agresell_app/features/rider/profile/presentation/widgets/rider_settings_panel.dart';
import 'package:agresell_app/features/rider/profile/presentation/screens/rider_documents_screen.dart';
import 'package:agresell_app/features/rider/profile/presentation/screens/rider_vehicle_screen.dart';
import 'package:agresell_app/features/shared/safety/presentation/screens/incident_tracking_screen.dart';
import 'package:agresell_app/features/shared/safety/presentation/widgets/app_safety_sheet.dart';
import 'package:agresell_app/features/shared/support/presentation/screens/support_center_screen.dart';
import 'package:agresell_app/features/rider/dashboard/presentation/screens/rider_earnings_screen.dart';
import 'package:agresell_app/features/rider/dashboard/presentation/screens/rider_history_screen.dart';
import 'package:agresell_app/features/rider/dashboard/presentation/screens/rider_ratings_screen.dart';
import 'package:agresell_app/features/rider/deliveries/presentation/controllers/rider_delivery_controller.dart';

part 'rider_profile_logout.dart';

enum _RiderProfileMode { overview, settings }

class RiderProfileScreen extends StatefulWidget {
  const RiderProfileScreen({
    required this.profile,
    this.analyticsController,
    this.safetyController,
    this.prepareForLogout,
    this.deliveryController,
    super.key,
  });

  final RiderProfile? profile;
  final RiderAnalyticsController? analyticsController;
  final RiderSafetyController? safetyController;
  final Future<bool> Function()? prepareForLogout;
  final RiderDeliveryController? deliveryController;

  @override
  State<RiderProfileScreen> createState() => _RiderProfileScreenState();
}

class _RiderProfileScreenState extends State<RiderProfileScreen> {
  late final RiderAnalyticsController _analytics;
  late final RiderSafetyController _safety;
  late final bool _ownsAnalytics;
  late final bool _ownsSafety;
  late RiderProfile? _profile;
  var _mode = _RiderProfileMode.overview;

  void _updateUi(VoidCallback update) => setState(update);

  void _syncProfile() {
    final profile = RiderRegistrationService.instance.currentProfile;
    if (mounted && profile != _profile) setState(() => _profile = profile);
  }

  @override
  void initState() {
    super.initState();
    _profile = widget.profile;
    _ownsAnalytics = widget.analyticsController == null;
    _ownsSafety = widget.safetyController == null;
    _analytics = widget.analyticsController ?? RiderAnalyticsController();
    _safety = widget.safetyController ?? RiderSafetyController();
    final profile = _profile;
    if (profile != null) {
      unawaited(_analytics.loadRatings(riderId: profile.id));
    }
    RiderRegistrationService.instance.addListener(_syncProfile);
  }

  @override
  void didUpdateWidget(covariant RiderProfileScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.profile != widget.profile) _profile = widget.profile;
  }

  @override
  void dispose() {
    if (_ownsAnalytics) _analytics.dispose();
    if (_ownsSafety) _safety.dispose();
    RiderRegistrationService.instance.removeListener(_syncProfile);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final profile = _profile;
    return ColoredBox(
      color: RiderProfileScreenStyles.backgroundColor,
      child: Column(
        children: [
          RiderPageHeader(
            title: 'Rider profile',
            subtitle: 'Account, vehicle, documents, and safety',
            action: IconButton(
              tooltip: 'Settings',
              constraints: RiderProfileScreenStyles.settingsConstraints,
              padding: RiderProfileScreenStyles.settingsIconPadding,
              color: RiderProfileScreenStyles.settingsIconColor,
              iconSize: RiderProfileScreenStyles.settingsIconSize,
              onPressed: () => _setMode(_RiderProfileMode.settings),
              icon: const Icon(Icons.settings_rounded),
            ),
          ),
          Expanded(
            child: profile == null
                ? const Center(
                    child: Padding(
                      padding: RiderProfileScreenStyles.emptyStatePadding,
                      child: RiderEmptyStateCard(
                        title: 'No rider profile',
                        message:
                            'Complete rider registration to view account and vehicle details.',
                        icon: Icons.person_outline_rounded,
                      ),
                    ),
                  )
                : AnimatedBuilder(
                    animation: Listenable.merge([_analytics, _safety]),
                    builder: (context, _) {
                      if (_mode == _RiderProfileMode.settings) {
                        return RiderSettingsPanel(
                          profile: profile,
                          onEditProfile: _editProfile,
                          onVehicle: () => _open(const RiderVehicleScreen()),
                          onDocuments: () =>
                              _open(const RiderDocumentsScreen()),
                          onChangePassword: _changePassword,
                          onSafety: _openSafety,
                          onIncidentHistory: _openIncidentHistory,
                          onSupport: () => _open(const SupportCenterScreen()),
                          onSwitchAccount: _switchAccount,
                          onLogout: _logout,
                          onBack: () => _setMode(_RiderProfileMode.overview),
                        );
                      }
                      return RiderProfileOverview(
                        profile: profile,
                        performance: _analytics.ratings.summary,
                        onEarnings: () => _open(
                          RiderEarningsScreen(
                            riderId: profile.id,
                            controller: _analytics,
                          ),
                        ),
                        onHistory: () => _open(
                          RiderHistoryScreen(
                            riderId: profile.id,
                            controller: _analytics,
                            deliveryController: widget.deliveryController,
                          ),
                        ),
                        onRatings: () => _open(
                          RiderRatingsScreen(
                            riderId: profile.id,
                            controller: _analytics,
                          ),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }

  void _setMode(_RiderProfileMode mode) {
    if (_mode == mode) return;
    setState(() => _mode = mode);
  }
}
