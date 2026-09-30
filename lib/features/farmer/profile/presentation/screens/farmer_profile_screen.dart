import 'dart:async';

import 'package:flutter/material.dart';
import 'package:agresell_app/core/widgets/app_snack_bar.dart';

import 'package:agresell_app/features/farmer/profile/presentation/widgets/farmer_profile_style.dart';
import 'package:agresell_app/features/auth/data/auth_session_service.dart';
import 'package:agresell_app/features/auth/presentation/account_session_navigation.dart';
import 'package:agresell_app/features/shared/profile/data/user_profile_data.dart';
import 'package:agresell_app/core/models/user_profile.dart';
import 'package:agresell_app/features/farmer/profile/presentation/widgets/farmer_history_card.dart';
import 'package:agresell_app/features/farmer/profile/presentation/widgets/farmer_profile_edit_card.dart';
import 'package:agresell_app/features/farmer/profile/presentation/widgets/farmer_farm_edit_card.dart';
import 'package:agresell_app/features/farmer/profile/presentation/widgets/farmer_profile_header.dart';
import 'package:agresell_app/features/farmer/profile/presentation/widgets/farmer_profile_info_card.dart';
import 'package:agresell_app/features/farmer/profile/presentation/widgets/farmer_settings_panel.dart';
import 'package:agresell_app/features/farmer/profile/presentation/widgets/farmer_stats_card.dart';
import 'package:agresell_app/core/utils/agrisell_page_route.dart';
import 'package:agresell_app/features/shared/profile/data/user_profile_service.dart';
import 'package:agresell_app/features/shared/profile/data/profile_follow_counts_repository.dart';
import 'package:agresell_app/features/shared/profile/domain/profile_follow_counts.dart';
import 'package:agresell_app/features/shared/safety/presentation/screens/incident_tracking_screen.dart';
import 'package:agresell_app/features/shared/safety/presentation/widgets/app_safety_sheet.dart';
import 'package:agresell_app/features/farmer/verification/data/farmer_verification_repository.dart';
import 'package:agresell_app/features/farmer/verification/domain/farmer_verification_details.dart';
import 'package:agresell_app/features/farmer/verification/presentation/screens/farmer_information_request_screen.dart';
import 'package:agresell_app/features/farmer/verification/presentation/widgets/farmer_information_request_banner.dart';
import 'package:agresell_app/features/farmer/reviews/presentation/screens/farmer_reviews_screen.dart';
import 'package:agresell_app/features/shared/support/presentation/screens/support_center_screen.dart';
import 'package:agresell_app/features/farmer/profile/presentation/widgets/farmer_gcash_settings_sheet.dart';

class FarmerProfileScreen extends StatefulWidget {
  const FarmerProfileScreen({
    this.verificationRepository = const FarmerVerificationRepository(),
    this.showSettingsIcon = false,
    super.key,
  });

  final FarmerVerificationRepository verificationRepository;
  final bool showSettingsIcon;

  @override
  State<FarmerProfileScreen> createState() => _FarmerProfileScreenState();
}

enum _FarmerProfileMode { overview, edit, editFarm, settings }

enum _FarmerSettingsAction {
  editProfile,
  editFarm,
  reviews,
  safety,
  incidentHistory,
  support,
  switchAccount,
  logout,
}

class _FarmerProfileScreenState extends State<FarmerProfileScreen> {
  late UserProfile _profile;
  var _mode = _FarmerProfileMode.overview;
  var _returnModeAfterEdit = _FarmerProfileMode.overview;
  var _followCounts = const ProfileFollowCounts();
  FarmerVerificationDetails? _verificationDetails;

  @override
  void initState() {
    super.initState();
    _profile = currentAuthenticatedUserProfile();
    unawaited(_loadFollowCounts());
    unawaited(_loadVerificationDetails());
  }

  Future<void> _loadVerificationDetails() async {
    final details =
        await widget.verificationRepository.loadVerificationDetails();
    if (mounted && details != null) {
      setState(() => _verificationDetails = details);
    }
  }

  Future<void> _openResubmitInformation() async {
    final details = _verificationDetails;
    if (details == null) return;

    final resubmitted = await Navigator.of(context).push<bool>(
      agrisellPageRoute<bool>(
        builder: (_) => FarmerInformationRequestScreen(
          details: details,
          repository: widget.verificationRepository,
        ),
      ),
    );
    if (resubmitted == true && mounted) {
      _loadVerificationDetails();
    }
  }

  Future<void> _loadFollowCounts() async {
    try {
      final counts = await const ProfileFollowCountsRepository().load();
      if (mounted) setState(() => _followCounts = counts);
    } on ProfileFollowCountsException {
      // Keep zero-value placeholders when profile statistics are unavailable.
    }
  }

  void _setMode(_FarmerProfileMode mode) {
    setState(() => _mode = mode);
  }

  void _openEditProfile({
    _FarmerProfileMode returnMode = _FarmerProfileMode.overview,
  }) {
    setState(() {
      _returnModeAfterEdit = returnMode;
      _mode = _FarmerProfileMode.edit;
    });
  }

  void _cancelEditProfile() {
    _setMode(_FarmerProfileMode.overview);
    if (_returnModeAfterEdit == _FarmerProfileMode.settings) {
      unawaited(_openSettings());
    }
  }

  void _openEditFarm() {
    setState(() {
      _returnModeAfterEdit = _FarmerProfileMode.settings;
      _mode = _FarmerProfileMode.editFarm;
    });
  }

  Future<void> _saveProfile(UserProfile profile) async {
    try {
      final saved = await UserProfileService.instance.save(profile);
      if (!mounted) return;
      setState(() {
        _profile = saved;
        _mode = _FarmerProfileMode.overview;
      });
      _showMessage('Profile saved.');
      if (_returnModeAfterEdit == _FarmerProfileMode.settings) {
        unawaited(_openSettings());
      }
    } on UserProfileSaveException catch (error) {
      if (mounted) _showMessage(error.message);
    }
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context).showAppSnackBar(
      SnackBar(behavior: SnackBarBehavior.floating, content: Text(message)),
    );
  }

  Future<void> _openSwitchAccount() =>
      AccountSessionNavigation.openSwitcher(context);

  Future<void> _openLogin() => AccountSessionNavigation.logout(context);

  void _openSafety() {
    showAppSafetySheet(
      context: context,
      role: 'farmer',
      userName: _profile.headerName,
      userContact: _profile.phoneNumber,
      userEmail: _profile.email,
    );
  }

  void _openIncidentHistory() {
    Navigator.of(context).push(
      agrisellPageRoute<void>(
        builder: (_) => IncidentTrackingScreen(
          role: 'farmer',
          userName: _profile.headerName,
          userContact: _profile.phoneNumber,
          userEmail: _profile.email,
        ),
      ),
    );
  }

  void _openReviews() {
    Navigator.of(context).push(
      agrisellPageRoute<void>(
        builder: (_) => const FarmerReviewsScreen(),
      ),
    );
  }

  void _openSupport() {
    Navigator.of(context).push(
      agrisellPageRoute<void>(
        builder: (_) => const SupportCenterScreen(),
      ),
    );
  }

  Future<void> _openSettings() async {
    final action = await showModalBottomSheet<_FarmerSettingsAction>(
      context: context,
      useRootNavigator: true,
      useSafeArea: true,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      barrierColor: const Color(0xFF164A38).withValues(alpha: 0.18),
      builder: (sheetContext) => DraggableScrollableSheet(
        initialChildSize: 0.79,
        minChildSize: 0.45,
        maxChildSize: 0.95,
        expand: false,
        builder: (context, scrollController) => FarmerSettingsPanel(
          profile: _profile,
          scrollController: scrollController,
          onBack: () => Navigator.of(sheetContext).pop(),
          onEditProfile: () =>
              Navigator.of(sheetContext).pop(_FarmerSettingsAction.editProfile),
          onEditFarm: () =>
              Navigator.of(sheetContext).pop(_FarmerSettingsAction.editFarm),
          onReviews: () =>
              Navigator.of(sheetContext).pop(_FarmerSettingsAction.reviews),
          onSafety: () =>
              Navigator.of(sheetContext).pop(_FarmerSettingsAction.safety),
          onIncidentHistory: () =>
              Navigator.of(sheetContext).pop(_FarmerSettingsAction.incidentHistory),
          onSupport: () =>
              Navigator.of(sheetContext).pop(_FarmerSettingsAction.support),
          onSwitchAccount: () => Navigator.of(
            sheetContext,
          ).pop(_FarmerSettingsAction.switchAccount),
          onLogout: () =>
              Navigator.of(sheetContext).pop(_FarmerSettingsAction.logout),
        ),
      ),
    );
    if (!mounted) return;
    switch (action) {
      case _FarmerSettingsAction.editProfile:
        _openEditProfile(returnMode: _FarmerProfileMode.settings);
      case _FarmerSettingsAction.editFarm:
        _openEditFarm();
      case _FarmerSettingsAction.reviews:
        _openReviews();
      case _FarmerSettingsAction.safety:
        _openSafety();
      case _FarmerSettingsAction.incidentHistory:
        _openIncidentHistory();
      case _FarmerSettingsAction.support:
        _openSupport();
      case _FarmerSettingsAction.switchAccount:
        await _openSwitchAccount();
      case _FarmerSettingsAction.logout:
        await _openLogin();
      case null:
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;
    final horizontalPadding = width < 380 ? 12.0 : 16.0;
    final navClearance = 154.0 + MediaQuery.paddingOf(context).bottom;

    return ColoredBox(
      color: FarmerProfileStyle.background,
      child: SafeArea(
        bottom: false,
        child: CustomScrollView(
          physics: const ClampingScrollPhysics(),
          keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
          slivers: [
            SliverPadding(
              padding: EdgeInsets.fromLTRB(
                horizontalPadding,
                16,
                horizontalPadding,
                navClearance,
              ),
              sliver: SliverList.list(
                children: [
                  FarmerProfileHeader(
                    title: _mode == _FarmerProfileMode.edit
                        ? 'Edit Profile'
                        : _mode == _FarmerProfileMode.editFarm
                            ? 'Edit Farm'
                            : 'Account',
                    onBack: _mode == _FarmerProfileMode.edit ||
                            _mode == _FarmerProfileMode.editFarm
                        ? _cancelEditProfile
                        : null,
                    profile: _profile,
                    followingCount: _followCounts.followingCount,
                    followerCount: _followCounts.followerCount,
                    isVerified:
                        AuthSessionService
                            .instance
                            .currentAccount
                            ?.isFarmerVerified ??
                        false,
                    onSettingsTap:
                        widget.showSettingsIcon ? _openSettings : null,
                  ),
                  const SizedBox(height: 14),
                  ...switch (_mode) {
                    _FarmerProfileMode.edit => _editChildren(),
                    _FarmerProfileMode.editFarm => _farmEditChildren(),
                    _FarmerProfileMode.settings => _profileChildren(),
                    _FarmerProfileMode.overview => _profileChildren(),
                  },
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  List<Widget> _editChildren() {
    return [
      FarmerProfileEditCard(
        profile: _profile,
        onCancel: _cancelEditProfile,
        onSave: _saveProfile,
      ),
    ];
  }

  List<Widget> _profileChildren() {
    return [
      if (_verificationDetails?.isNeedsInformation == true) ...[
        FarmerInformationRequestBanner(
          details: _verificationDetails!,
          onTap: _openResubmitInformation,
          margin: const EdgeInsets.only(bottom: 14),
        ),
      ],
      const FarmerStatsCard(),
      const SizedBox(height: 18),
      _sectionHeader('Account & Farm'),
      const SizedBox(height: 8),
      FarmerProfileInfoCard(
        profile: _profile,
        onEditProfile: _openEditProfile,
        initiallyExpanded: false,
      ),
      const SizedBox(height: 10),
      FarmerProfileCard(
        child: Column(
          children: [
            _accountTile(
              icon: Icons.agriculture_outlined,
              title: 'Edit Farm',
              onTap: _openEditFarm,
            ),
            const Divider(height: 1, color: Color(0xFFEEF3F0)),
            _accountTile(
              icon: Icons.account_balance_wallet_outlined,
              title: 'GCash Payment Details',
              onTap: () => showFarmerGcashSettingsSheet(context),
            ),
          ],
        ),
      ),
      const SizedBox(height: 18),
      _sectionHeader('Orders & Feedback'),
      const SizedBox(height: 8),
      const FarmerHistoryCard(),
      const SizedBox(height: 10),
      FarmerProfileCard(
        child: _accountTile(
          icon: Icons.star_outline_rounded,
          title: 'Customer Reviews & Ratings',
          onTap: _openReviews,
        ),
      ),
      const SizedBox(height: 18),
      _sectionHeader('Safety & Support'),
      const SizedBox(height: 8),
      FarmerProfileCard(
        child: Column(
          children: [
            _accountTile(
              icon: Icons.shield_outlined,
              title: 'Safety & Emergency SOS',
              onTap: _openSafety,
            ),
            const Divider(height: 1, color: Color(0xFFEEF3F0)),
            _accountTile(
              icon: Icons.history_rounded,
              title: 'Incident History & Status',
              onTap: _openIncidentHistory,
            ),
            const Divider(height: 1, color: Color(0xFFEEF3F0)),
            _accountTile(
              icon: Icons.support_agent_rounded,
              title: 'Customer Support Tickets',
              onTap: _openSupport,
            ),
          ],
        ),
      ),
      const SizedBox(height: 18),
      _sectionHeader('Display Preferences'),
      const SizedBox(height: 8),
      const FarmerProfileCard(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 16, vertical: 4),
          child: FarmerFontSizeControl(),
        ),
      ),
      const SizedBox(height: 18),
      _sectionHeader('Session'),
      const SizedBox(height: 8),
      FarmerProfileCard(
        child: Column(
          children: [
            _accountTile(
              icon: Icons.switch_account_outlined,
              title: 'Switch Account',
              onTap: _openSwitchAccount,
            ),
            const Divider(height: 1, color: Color(0xFFEFF3F4)),
            _accountTile(
              icon: Icons.logout_rounded,
              title: 'Log Out',
              onTap: _openLogin,
              destructive: true,
            ),
          ],
        ),
      ),
    ];
  }

  Widget _sectionHeader(String title) => Padding(
    padding: const EdgeInsets.only(left: 4),
    child: Text(
      title,
      style: FarmerProfileStyle.sectionLabel,
    ),
  );

  Widget _accountTile({
    required IconData icon,
    required String title,
    String? subtitle,
    required VoidCallback onTap,
    bool destructive = false,
  }) => InkWell(
    onTap: onTap,
    borderRadius: BorderRadius.circular(18),
    child: Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              gradient: destructive
                  ? const LinearGradient(
                      colors: [Color(0xFFFFF0F0), Color(0xFFFFE4E4)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    )
                  : const LinearGradient(
                      colors: [Color(0xFFE8F5EE), Color(0xFFD1EDDF)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: destructive
                    ? const Color(0xFFFFCCCC)
                    : FarmerProfileStyle.borderSubtle,
                width: 1,
              ),
            ),
            child: Icon(
              icon,
              color: destructive
                  ? const Color(0xFFD63031)
                  : FarmerProfileStyle.green,
              size: 22,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: subtitle != null && subtitle.isNotEmpty
                ? Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        title,
                        style: FarmerProfileStyle.tileTitle.copyWith(
                          color: destructive
                              ? const Color(0xFFD63031)
                              : FarmerProfileStyle.ink,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(subtitle, style: FarmerProfileStyle.tileSubtitle),
                    ],
                  )
                : Text(
                    title,
                    style: FarmerProfileStyle.tileTitle.copyWith(
                      color: destructive
                          ? const Color(0xFFD63031)
                          : FarmerProfileStyle.ink,
                    ),
                  ),
          ),
          const SizedBox(width: 8),
          Icon(
            Icons.chevron_right_rounded,
            color: destructive
                ? const Color(0xFFD63031)
                : const Color(0xFFA0B8AF),
            size: 22,
          ),
        ],
      ),
    ),
  );

  List<Widget> _farmEditChildren() {
    return [FarmerFarmEditCard(onCancel: _cancelEditProfile)];
  }
}
