import 'dart:async';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import 'package:agresell_app/core/constants/agrisell_routes.dart';
import 'package:agresell_app/core/models/user_profile.dart';
import 'package:agresell_app/core/utils/profile_edit_validator.dart';
import 'package:agresell_app/core/widgets/app_snack_bar.dart';
import 'package:agresell_app/features/auth/data/auth_session_service.dart';
import 'package:agresell_app/features/auth/domain/buyer_shipping_address.dart';
import 'package:agresell_app/features/auth/presentation/account_session_navigation.dart';
import 'package:agresell_app/features/buyer/home/presentation/controllers/farmer_follow_controller.dart';
import 'package:agresell_app/features/buyer/profile/data/buyer_shipping_address_saver.dart';
import 'package:agresell_app/features/buyer/profile/presentation/styles/profile_screen_styles.dart';
import 'package:agresell_app/features/buyer/profile/presentation/widgets/buyer_profile_navigation.dart';
import 'package:agresell_app/features/buyer/profile/presentation/widgets/buyer_profile_overview_sections.dart';
import 'package:agresell_app/features/buyer/profile/presentation/widgets/buyer_profile_style.dart';
import 'package:agresell_app/features/buyer/profile/presentation/widgets/buyer_settings_sheet.dart';
import 'package:agresell_app/features/buyer/profile/presentation/widgets/profile_edit_card.dart';
import 'package:agresell_app/features/buyer/profile/presentation/widgets/profile_header.dart';
import 'package:agresell_app/features/shared/profile/data/profile_follow_counts_repository.dart';
import 'package:agresell_app/features/shared/profile/data/user_profile_data.dart';
import 'package:agresell_app/features/shared/profile/data/user_profile_service.dart';
import 'package:agresell_app/features/shared/profile/domain/profile_follow_counts.dart';

part 'profile_screen_actions.dart';
part 'profile_screen_follow_counts.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({
    this.showSettingsIcon = false,
    super.key,
  });

  final bool showSettingsIcon;

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

enum _BuyerProfileMode { overview, edit }

class _ProfileScreenState extends State<ProfileScreen> {
  final _imagePicker = ImagePicker();
  late UserProfile _profile;
  var _mode = _BuyerProfileMode.overview;
  Uint8List? _avatarImageBytes;
  var _followCounts = const ProfileFollowCounts();
  bool _returnToSettings = false;

  void _updateUi(VoidCallback update) => setState(update);

  @override
  void initState() {
    super.initState();
    _profile = currentAuthenticatedUserProfile();
    FarmerFollowController.instance.successfulChanges.addListener(
      _refreshFollowCounts,
    );
    unawaited(_loadFollowCounts());
  }

  @override
  void dispose() {
    FarmerFollowController.instance.successfulChanges.removeListener(
      _refreshFollowCounts,
    );
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;
    final horizontalPadding = ProfileScreenStyles.horizontalPadding(width);
    final navClearance = ProfileScreenStyles.navClearance(context);

    return ColoredBox(
      color: BuyerProfileStyle.background,
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
                  ProfileHeader(
                    title: _mode == _BuyerProfileMode.edit
                        ? 'Edit Profile'
                        : 'Account',
                    onBack: _mode == _BuyerProfileMode.edit
                        ? _cancelEditProfile
                        : null,
                    profile: _profile,
                    followingCount: _followCounts.followingCount,
                    followerCount: _followCounts.followerCount,
                    isVerified:
                        AuthSessionService.instance.currentAccount?.isActive ??
                        false,
                    showSettingsIcon: widget.showSettingsIcon,
                    onSettingsTap:
                        widget.showSettingsIcon ? _openSettings : null,
                    showAvatarEditBadge: _mode == _BuyerProfileMode.edit,
                    avatarImageBytes: _avatarImageBytes,
                    onAvatarEdit: _pickAvatarImage,
                    onBasketTap: () =>
                        Navigator.of(context).pushNamed(AgrisellRoutes.basket),
                  ),
                  const SizedBox(height: ProfileScreenStyles.headerSpacing),
                  if (_mode == _BuyerProfileMode.edit)
                    ProfileEditCard(
                      profile: _profile,
                      onCancel: _cancelEditProfile,
                      onSave: _saveProfile,
                    )
                  else
                    ...BuyerProfileOverviewSections.build(
                      profile: _profile,
                      onOpenEditProfile: _openEditProfile,
                      onSaveShippingAddress: _saveShippingAddress,
                      onOpenSafety: _openSafety,
                      onOpenIncidentHistory: _openIncidentHistory,
                      onOpenSupport: _openSupport,
                      onOpenSwitchAccount: () =>
                          unawaited(_openSwitchAccount()),
                      onOpenLogin: () => unawaited(_openLogin()),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
