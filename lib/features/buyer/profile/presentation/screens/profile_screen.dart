import 'dart:async';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:agresell_app/core/widgets/app_snack_bar.dart';
import 'package:image_picker/image_picker.dart';

import 'package:agresell_app/core/theme/agrisellColors.dart';
import 'package:agresell_app/features/auth/presentation/account_session_navigation.dart';
import 'package:agresell_app/features/shared/profile/data/user_profile_data.dart';
import 'package:agresell_app/features/buyer/profile/data/buyer_shipping_address_saver.dart';
import 'package:agresell_app/features/auth/domain/buyer_shipping_address.dart';
import 'package:agresell_app/core/utils/profile_edit_validator.dart';
import 'package:agresell_app/core/models/user_profile.dart';
import 'package:agresell_app/features/buyer/profile/presentation/widgets/profile_header.dart';
import 'package:agresell_app/features/shared/profile/data/user_profile_service.dart';
import 'package:agresell_app/features/shared/profile/data/profile_follow_counts_repository.dart';
import 'package:agresell_app/features/shared/profile/domain/profile_follow_counts.dart';
import 'package:agresell_app/features/buyer/profile/presentation/widgets/buyer_settings_panel.dart';
import 'package:agresell_app/features/buyer/profile/presentation/widgets/buyer_profile_content.dart';
import 'package:agresell_app/features/buyer/home/presentation/controllers/farmer_follow_controller.dart';
part 'profile_screen_follow_counts.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

enum _BuyerProfileMode { overview, edit, settings }

class _ProfileScreenState extends State<ProfileScreen> {
  final _imagePicker = ImagePicker();
  late UserProfile _profile;
  var _mode = _BuyerProfileMode.overview;
  var _returnModeAfterEdit = _BuyerProfileMode.overview;
  Uint8List? _avatarImageBytes;
  var _followCounts = const ProfileFollowCounts();

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

  void _openEditProfile({
    _BuyerProfileMode returnMode = _BuyerProfileMode.overview,
  }) {
    setState(() {
      _returnModeAfterEdit = returnMode;
      _mode = _BuyerProfileMode.edit;
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

  void _closeEditProfile() {
    setState(() => _mode = _returnModeAfterEdit);
  }

  void _openSettings() {
    setState(() => _mode = _BuyerProfileMode.settings);
  }

  void _closeSettings() {
    setState(() => _mode = _BuyerProfileMode.overview);
  }

  Future<void> _saveShippingAddress(BuyerShippingAddress address) async {
    final saved = await BuyerShippingAddressSaver.save(_profile, address);
    if (!mounted) return;
    setState(() => _profile = saved);
    _showMessage('Shipping address saved.');
  }

  Future<void> _pickAvatarImage() async {
    try {
      final image = await _imagePicker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 900,
        maxHeight: 900,
        imageQuality: 85,
      );
      if (image == null) return;
      final bytes = await image.readAsBytes();
      if (!mounted) return;
      final error = ProfileEditValidator.validateProfileImage(
        fileName: _imageFileName(image),
        fileSizeBytes: bytes.length,
      );
      if (error != null) {
        _showMessage(error);
        return;
      }
      setState(() => _avatarImageBytes = bytes);
      _showMessage('Profile image updated.');
    } on Exception {
      if (mounted) _showMessage('Unable to choose profile image.');
    }
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context).showAppSnackBar(
      SnackBar(behavior: SnackBarBehavior.floating, content: Text(message)),
    );
  }

  String _imageFileName(XFile image) {
    if (image.name.trim().isNotEmpty) return image.name;
    return image.path.split(RegExp(r'[\\/]')).last;
  }

  Future<void> _openLogin() => AccountSessionNavigation.logout(context);

  Future<void> _openSwitchAccount() =>
      AccountSessionNavigation.openSwitcher(context);
  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;
    final horizontalPadding = width < 380 ? 12.0 : 16.0;
    return ColoredBox(
      color: AgrisellColors.homeBackground,
      child: CustomScrollView(
        physics: const ClampingScrollPhysics(),
        slivers: [
          SliverToBoxAdapter(
            child: ProfileHeader(
              profile: _profile,
              followingCount: _followCounts.followingCount,
              followerCount: _followCounts.followerCount,
              onSettingsTap: _openSettings,
              showAvatarEditBadge: _mode == _BuyerProfileMode.edit,
              avatarImageBytes: _avatarImageBytes,
              onAvatarEdit: _pickAvatarImage,
            ),
          ),
          SliverPadding(
            padding: EdgeInsets.fromLTRB(
              horizontalPadding,
              18,
              horizontalPadding,
              150,
            ),
            sliver: SliverList.list(children: [_contentForMode()]),
          ),
        ],
      ),
    );
  }

  Widget _contentForMode() {
    if (_mode == _BuyerProfileMode.settings) {
      return BuyerSettingsPanel(
        profile: _profile,
        onEditProfile: () =>
            _openEditProfile(returnMode: _BuyerProfileMode.settings),
        onSwitchAccount: _openSwitchAccount,
        onLogout: _openLogin,
        onBack: _closeSettings,
      );
    }
    final isEditing = _mode == _BuyerProfileMode.edit;
    return BuyerProfileContent(
      profile: _profile,
      isEditing: isEditing,
      onCancelEdit: _closeEditProfile,
      onSaveProfile: _saveProfile,
      onSaveShippingAddress: _saveShippingAddress,
    );
  }
}
