part of 'profile_screen.dart';

extension _ProfileScreenActions on _ProfileScreenState {
  void _openEditProfile({bool returnToSettings = false}) {
    _updateUi(() {
      _returnToSettings = returnToSettings;
      _mode = _BuyerProfileMode.edit;
    });
  }

  void _cancelEditProfile() {
    _updateUi(() => _mode = _BuyerProfileMode.overview);
    if (_returnToSettings) {
      unawaited(_openSettings());
    }
  }

  Future<void> _saveProfile(UserProfile profile) async {
    try {
      final saved = await UserProfileService.instance.save(profile);
      if (!mounted) return;
      _updateUi(() {
        _profile = saved;
        _mode = _BuyerProfileMode.overview;
      });
      _showMessage('Profile saved.');
      if (_returnToSettings) {
        unawaited(_openSettings());
      }
    } on UserProfileSaveException catch (error) {
      if (mounted) _showMessage(error.message);
    }
  }

  Future<void> _saveShippingAddress(BuyerShippingAddress address) async {
    final saved = await BuyerShippingAddressSaver.save(_profile, address);
    if (!mounted) return;
    _updateUi(() => _profile = saved);
  }

  Future<void> _pickAvatarImage() async {
    if (_mode != _BuyerProfileMode.edit || _avatarSaving) return;
    _avatarSaving = true;
    try {
      if (!AgrisellSupabase.isInitialized) {
        throw Exception('Sign in before changing your photo.');
      }
      final owner = AgrisellSupabase.client.auth.currentUser?.id;
      final image = await _imagePicker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 900,
        maxHeight: 900,
        imageQuality: 85,
      );
      if (image == null) return;
      final bytes = await image.readAsBytes();
      if (!mounted || _mode != _BuyerProfileMode.edit) return;
      final error = ProfileEditValidator.validateProfileImage(
        fileName: _imageFileName(image),
        fileSizeBytes: bytes.length,
      );
      if (error != null) {
        _showMessage(error);
        return;
      }
      if (owner != AgrisellSupabase.client.auth.currentUser?.id) return;
      final url = await BuyerAvatarRepository(
        AgrisellSupabase.client,
      ).save(bytes);
      await AuthRegistrationService.instance.loadCurrentAccount();
      if (!mounted || owner != AgrisellSupabase.client.auth.currentUser?.id)
        return;
      _updateUi(() {
        _avatarImageBytes = bytes;
        _profile = _profile.copyWith(avatarUrl: url);
      });
      _showMessage('Profile image updated.');
    } on FunctionException catch (error) {
      if (mounted) {
        _showMessage(
          error.status == 429
              ? 'Too many photo updates. Please wait and try again.'
              : 'Photo saving is unavailable. Please try again later.',
        );
      }
    } on AuthException {
      if (mounted) _showMessage('Sign in again before updating your photo.');
    } on Exception {
      if (mounted)
        _showMessage('Your profile image could not be saved. Please retry.');
    } finally {
      _avatarSaving = false;
    }
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context).showAppSnackBar(
      SnackBar(behavior: SnackBarBehavior.floating, content: Text(message)),
    );
  }

  String _imageFileName(XFile image) {
    final name = image.name.trim();
    return name.isNotEmpty ? name : image.path.split(RegExp(r'[\\/]')).last;
  }

  Future<void> _openLogin() => AccountSessionNavigation.logout(context);

  Future<void> _openSwitchAccount() =>
      AccountSessionNavigation.openSwitcher(context);

  void _openSafety() => BuyerProfileNavigation.openSafety(context, _profile);

  void _openIncidentHistory() =>
      BuyerProfileNavigation.openIncidentHistory(context, _profile);

  void _openSupport() => BuyerProfileNavigation.openSupport(context);

  Future<void> _openSettings() => showBuyerSettingsSheet(
    context: context,
    profile: _profile,
    onEditProfile: () => _openEditProfile(returnToSettings: true),
    onSafety: _openSafety,
    onIncidentHistory: _openIncidentHistory,
    onSupport: _openSupport,
    onSwitchAccount: () => unawaited(_openSwitchAccount()),
    onLogout: () => unawaited(_openLogin()),
  );
}
