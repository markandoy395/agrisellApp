import 'dart:async';

import 'package:flutter/material.dart';
import 'package:agresell_app/core/models/user_profile.dart';
import 'package:agresell_app/core/widgets/app_snack_bar.dart';
import 'package:agresell_app/features/shared/profile/data/user_profile_service.dart';
import 'package:agresell_app/features/farmer/verification/data/farmer_verification_repository.dart';

import '../controllers/farmer_profile_controller.dart';
import '../utils/farmer_profile_navigation.dart';
import '../widgets/farmer_profile_settings_sheet.dart';
import '../widgets/farmer_profile_view.dart';

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

class _FarmerProfileScreenState extends State<FarmerProfileScreen> {
  late final FarmerProfileController _controller;
  FarmerProfileNavigation get _navigation =>
      FarmerProfileNavigation(context, _controller.profile);

  @override
  void initState() {
    super.initState();
    _controller = FarmerProfileController(
      verificationRepository: widget.verificationRepository,
    );
    unawaited(_controller.loadFollowCounts());
    unawaited(_controller.loadVerificationDetails());
  }

  @override
  void didUpdateWidget(covariant FarmerProfileScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    _controller.verificationRepository = widget.verificationRepository;
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _openResubmitInformation() async {
    final details = _controller.verificationDetails;
    if (details == null) return;
    final resubmitted = await _navigation.resubmitInformation(
      details,
      widget.verificationRepository,
    );
    if (resubmitted == true && mounted)
      unawaited(_controller.loadVerificationDetails());
  }

  void _cancelEditProfile() {
    _controller.showOverview();
    if (_controller.returnModeAfterEdit == FarmerProfileMode.settings)
      unawaited(_openSettings());
  }

  Future<void> _saveProfile(UserProfile profile) async {
    try {
      if (!await _controller.saveProfile(profile) || !mounted) return;
      _showMessage('Profile saved.');
      if (_controller.returnModeAfterEdit == FarmerProfileMode.settings)
        unawaited(_openSettings());
    } on UserProfileSaveException catch (error) {
      if (mounted) _showMessage(error.message);
    }
  }

  void _showMessage(String message) =>
      ScaffoldMessenger.of(context).showAppSnackBar(
        SnackBar(behavior: SnackBarBehavior.floating, content: Text(message)),
      );

  Future<void> _openSettings() async {
    final action = await showFarmerProfileSettingsSheet(
      context,
      _controller.profile,
    );
    if (!mounted) return;
    switch (action) {
      case FarmerSettingsAction.editProfile:
        _controller.openEditProfile(returnMode: FarmerProfileMode.settings);
      case FarmerSettingsAction.editFarm:
        _controller.openEditFarm();
      case FarmerSettingsAction.reviews:
        _navigation.openReviews();
      case FarmerSettingsAction.safety:
        _navigation.openSafety();
      case FarmerSettingsAction.incidentHistory:
        _navigation.openIncidentHistory();
      case FarmerSettingsAction.support:
        _navigation.openSupport();
      case FarmerSettingsAction.switchAccount:
        await _navigation.openSwitchAccount();
      case FarmerSettingsAction.logout:
        await _navigation.openLogin();
      case null:
        break;
    }
  }

  @override
  Widget build(BuildContext context) => ListenableBuilder(
    listenable: _controller,
    builder: (context, _) => FarmerProfileView(
      controller: _controller,
      showSettingsIcon: widget.showSettingsIcon,
      onSave: _saveProfile,
      onCancelEdit: _cancelEditProfile,
      onSettings: _openSettings,
      onResubmitInformation: _openResubmitInformation,
      onEditProfile: () => _controller.openEditProfile(),
      onEditFarm: _controller.openEditFarm,
      onReviews: _navigation.openReviews,
      onSafety: _navigation.openSafety,
      onIncidentHistory: _navigation.openIncidentHistory,
      onSupport: _navigation.openSupport,
      onSwitchAccount: _navigation.openSwitchAccount,
      onLogout: _navigation.openLogin,
    ),
  );
}
