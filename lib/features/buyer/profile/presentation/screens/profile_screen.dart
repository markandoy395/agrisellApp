import 'dart:async';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:agresell_app/core/widgets/app_snack_bar.dart';
import 'package:image_picker/image_picker.dart';

import 'package:agresell_app/core/constants/agrisell_routes.dart';
import 'package:agresell_app/core/models/user_profile.dart';
import 'package:agresell_app/core/utils/profile_edit_validator.dart';
import 'package:agresell_app/features/auth/data/auth_session_service.dart';
import 'package:agresell_app/features/auth/domain/buyer_shipping_address.dart';
import 'package:agresell_app/features/auth/presentation/account_session_navigation.dart';
import 'package:agresell_app/features/buyer/home/presentation/controllers/farmer_follow_controller.dart';
import 'package:agresell_app/features/buyer/profile/data/buyer_shipping_address_saver.dart';
import 'package:agresell_app/features/buyer/profile/presentation/widgets/buyer_deals_card.dart';
import 'package:agresell_app/features/buyer/profile/presentation/widgets/buyer_profile_style.dart';
import 'package:agresell_app/features/buyer/profile/presentation/widgets/buyer_settings_panel.dart';
import 'package:agresell_app/features/buyer/profile/presentation/widgets/orders_card.dart';
import 'package:agresell_app/features/buyer/profile/presentation/widgets/profile_edit_card.dart';
import 'package:agresell_app/features/buyer/profile/presentation/widgets/profile_header.dart';
import 'package:agresell_app/features/buyer/profile/presentation/widgets/shipping_address_card.dart';
import 'package:agresell_app/features/shared/widgets/profile/account_font_size_control.dart';
import 'package:agresell_app/features/shared/profile/data/profile_follow_counts_repository.dart';
import 'package:agresell_app/features/shared/profile/data/user_profile_data.dart';
import 'package:agresell_app/features/shared/profile/data/user_profile_service.dart';
import 'package:agresell_app/features/shared/profile/domain/profile_follow_counts.dart';
import 'package:agresell_app/features/shared/safety/presentation/screens/incident_tracking_screen.dart';
import 'package:agresell_app/features/shared/safety/presentation/widgets/app_safety_sheet.dart';
import 'package:agresell_app/features/shared/support/presentation/screens/support_center_screen.dart';
import 'package:agresell_app/core/utils/agrisell_page_route.dart';

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

  void _openEditProfile() {
    setState(() => _mode = _BuyerProfileMode.edit);
  }

  void _cancelEditProfile() {
    setState(() => _mode = _BuyerProfileMode.overview);
  }

  Future<void> _saveProfile(UserProfile profile) async {
    try {
      final saved = await UserProfileService.instance.save(profile);
      if (!mounted) return;
      setState(() {
        _profile = saved;
        _mode = _BuyerProfileMode.overview;
      });
      _showMessage('Profile saved.');
    } on UserProfileSaveException catch (error) {
      if (mounted) _showMessage(error.message);
    }
  }

  Future<void> _saveShippingAddress(BuyerShippingAddress address) async {
    final saved = await BuyerShippingAddressSaver.save(_profile, address);
    if (!mounted) return;
    setState(() => _profile = saved);
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

  void _openSafety() {
    showAppSafetySheet(
      context: context,
      role: 'buyer',
      userName: _profile.headerName,
      userContact: _profile.phoneNumber,
      userEmail: _profile.email,
    );
  }

  void _openIncidentHistory() {
    Navigator.of(context).push(
      agrisellPageRoute<void>(
        builder: (_) => IncidentTrackingScreen(
          role: 'buyer',
          userName: _profile.headerName,
          userContact: _profile.phoneNumber,
          userEmail: _profile.email,
        ),
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
    await showModalBottomSheet<void>(
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
        builder: (context, scrollController) => BuyerSettingsPanel(
          profile: _profile,
          scrollController: scrollController,
          onBack: () => Navigator.of(sheetContext).pop(),
          onEditProfile: () {
            Navigator.of(sheetContext).pop();
            _openEditProfile();
          },
          onSafety: () {
            Navigator.of(sheetContext).pop();
            _openSafety();
          },
          onIncidentHistory: () {
            Navigator.of(sheetContext).pop();
            _openIncidentHistory();
          },
          onSupport: () {
            Navigator.of(sheetContext).pop();
            _openSupport();
          },
          onSwitchAccount: () {
            Navigator.of(sheetContext).pop();
            unawaited(_openSwitchAccount());
          },
          onLogout: () {
            Navigator.of(sheetContext).pop();
            unawaited(_openLogin());
          },
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;
    final horizontalPadding = width < 380 ? 12.0 : 16.0;
    final navClearance = 154.0 + MediaQuery.paddingOf(context).bottom;

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
                  const SizedBox(height: 14),
                  ...switch (_mode) {
                    _BuyerProfileMode.edit => _editChildren(),
                    _BuyerProfileMode.overview => _profileChildren(),
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
      ProfileEditCard(
        profile: _profile,
        onCancel: _cancelEditProfile,
        onSave: _saveProfile,
      ),
    ];
  }

  List<Widget> _profileChildren() {
    return [
      const BuyerDealsCard(),
      const SizedBox(height: 18),
      _sectionHeader('Orders & Activity'),
      const SizedBox(height: 8),
      const OrdersCard(),
      const SizedBox(height: 18),
      _sectionHeader('Account & Delivery'),
      const SizedBox(height: 8),
      BuyerPersonalInfoCard(
        profile: _profile,
        onEditProfile: _openEditProfile,
        initiallyExpanded: false,
      ),
      const SizedBox(height: 10),
      ShippingAddressCard(
        address: _profile.address,
        latitude: _profile.shippingLatitude,
        longitude: _profile.shippingLongitude,
        fullName: _profile.headerName,
        phoneNumber: _profile.phoneNumber,
        onSave: _saveShippingAddress,
      ),
      const SizedBox(height: 18),
      _sectionHeader('Safety & Support'),
      const SizedBox(height: 8),
      BuyerProfileCard(
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
      const BuyerProfileCard(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 16, vertical: 4),
          child: AccountFontSizeControl(),
        ),
      ),
      const SizedBox(height: 18),
      _sectionHeader('Session'),
      const SizedBox(height: 8),
      BuyerProfileCard(
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
      style: BuyerProfileStyle.sectionLabel,
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
                    : BuyerProfileStyle.borderSubtle,
                width: 1,
              ),
            ),
            child: Icon(
              icon,
              color: destructive
                  ? const Color(0xFFD63031)
                  : BuyerProfileStyle.green,
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
                        style: BuyerProfileStyle.tileTitle.copyWith(
                          color: destructive
                              ? const Color(0xFFD63031)
                              : BuyerProfileStyle.ink,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(subtitle, style: BuyerProfileStyle.tileSubtitle),
                    ],
                  )
                : Text(
                    title,
                    style: BuyerProfileStyle.tileTitle.copyWith(
                      color: destructive
                          ? const Color(0xFFD63031)
                          : BuyerProfileStyle.ink,
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
}
