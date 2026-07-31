import 'dart:async';

import 'package:flutter/material.dart';
import 'package:agresell_app/core/widgets/app_snack_bar.dart';

import 'package:agresell_app/core/theme/agrisellColors.dart';
import 'package:agresell_app/features/auth/data/auth_session_service.dart';
import 'package:agresell_app/features/auth/presentation/account_session_navigation.dart';
import 'package:agresell_app/features/buyer/profile/data/user_profile_data.dart';
import 'package:agresell_app/core/models/user_profile.dart';
import 'package:agresell_app/features/farmer/profile/presentation/widgets/farmer_history_card.dart';
import 'package:agresell_app/features/farmer/profile/presentation/widgets/farmer_profile_edit_card.dart';
import 'package:agresell_app/features/farmer/profile/presentation/widgets/farmer_farm_edit_card.dart';
import 'package:agresell_app/features/farmer/profile/presentation/widgets/farmer_profile_header.dart';
import 'package:agresell_app/features/farmer/profile/presentation/widgets/farmer_profile_info_card.dart';
import 'package:agresell_app/features/farmer/profile/presentation/widgets/farmer_settings_panel.dart';
import 'package:agresell_app/features/farmer/profile/presentation/widgets/farmer_stats_card.dart';
import 'package:agresell_app/features/shared/profile/data/user_profile_service.dart';
import 'package:agresell_app/features/shared/profile/data/profile_follow_counts_repository.dart';
import 'package:agresell_app/features/shared/profile/domain/profile_follow_counts.dart';

class FarmerProfileScreen extends StatefulWidget {
  const FarmerProfileScreen({super.key});

  @override
  State<FarmerProfileScreen> createState() => _FarmerProfileScreenState();
}

enum _FarmerProfileMode { overview, edit, editFarm, settings }

class _FarmerProfileScreenState extends State<FarmerProfileScreen> {
  late UserProfile _profile;
  var _mode = _FarmerProfileMode.overview;
  var _returnModeAfterEdit = _FarmerProfileMode.overview;
  var _followCounts = const ProfileFollowCounts();

  @override
  void initState() {
    super.initState();
    _profile = currentAuthenticatedUserProfile();
    unawaited(_loadFollowCounts());
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
    _setMode(_returnModeAfterEdit);
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
        _mode = _returnModeAfterEdit;
      });
      _showMessage('Profile saved.');
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

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;
    final horizontalPadding = width < 380 ? 12.0 : 16.0;
    final navClearance = 154.0 + MediaQuery.paddingOf(context).bottom;

    return ColoredBox(
      color: AgrisellColors.homeBackground,
      child: Column(
        children: [
          FarmerProfileHeader(
            profile: _profile,
            followingCount: _followCounts.followingCount,
            followerCount: _followCounts.followerCount,
            isVerified:
                AuthSessionService.instance.currentAccount?.isFarmerVerified ??
                false,
            onSettingsTap: () => _setMode(_FarmerProfileMode.settings),
          ),
          Expanded(
            child: CustomScrollView(
              physics: const ClampingScrollPhysics(),
              keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
              slivers: [
                SliverPadding(
                  padding: EdgeInsets.fromLTRB(
                    horizontalPadding,
                    14,
                    horizontalPadding,
                    navClearance,
                  ),
                  sliver: SliverList.list(
                    children: switch (_mode) {
                      _FarmerProfileMode.edit => _editChildren(),
                      _FarmerProfileMode.editFarm => _farmEditChildren(),
                      _FarmerProfileMode.settings => _settingsChildren(),
                      _FarmerProfileMode.overview => _profileChildren(),
                    },
                  ),
                ),
              ],
            ),
          ),
        ],
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
      const FarmerStatsCard(),
      const SizedBox(height: 14),
      const FarmerHistoryCard(),
      const SizedBox(height: 14),
      FarmerProfileInfoCard(profile: _profile),
    ];
  }

  List<Widget> _farmEditChildren() {
    return [FarmerFarmEditCard(onCancel: _cancelEditProfile)];
  }

  List<Widget> _settingsChildren() {
    return [
      FarmerSettingsPanel(
        profile: _profile,
        onEditProfile: () {
          _openEditProfile(returnMode: _FarmerProfileMode.settings);
        },
        onEditFarm: _openEditFarm,
        onSwitchAccount: _openSwitchAccount,
        onLogout: _openLogin,
        onBack: () => _setMode(_FarmerProfileMode.overview),
      ),
    ];
  }
}
