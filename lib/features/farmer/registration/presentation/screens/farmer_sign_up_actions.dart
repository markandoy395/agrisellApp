part of 'farmer_sign_up_screen.dart';

extension _FarmerSignUpActions on _FarmerSignUpScreenState {
  Future<void> _pickDate() async {
    final selected = await showDatePicker(
      context: context,
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
      initialDate:
          DateTime.tryParse(_controllers.dateOfBirth.text) ?? DateTime(2000),
    );
    if (selected == null || !mounted) return;
    _refresh(() {
      _controllers.dateOfBirth.text = selected.toIso8601String().substring(
        0,
        10,
      );
      _validateCurrent(showEmpty: false);
    });
  }

  Future<void> _pickLocation() async {
    final selected = await showLocationSelector(
      context,
      role: LocationOwnerRole.farmer,
      initialAddress: _controllers.farmAddress.text,
      initialLatitude: double.tryParse(_controllers.latitude.text),
      initialLongitude: double.tryParse(_controllers.longitude.text),
      showAddressFields: false,
    );
    if (selected == null || !mounted) return;
    _refresh(() {
      _controllers.setFarmCoordinates(
        latitudeValue: selected.latitude,
        longitudeValue: selected.longitude,
      );
      _validateCurrent(showEmpty: false);
    });
  }

  Future<void> _pickImage({required bool profile}) async {
    final image = await ImagePicker().pickImage(
      source: ImageSource.gallery,
      imageQuality: 85,
    );
    if (image == null || !mounted) return;
    final bytes = await image.readAsBytes();
    if (!mounted) return;
    _refresh(() {
      if (profile) {
        _controllers.profileImage = bytes;
      } else {
        _controllers.farmImage = bytes;
      }
    });
  }

  Future<void> _submit() async {
    _refresh(() => _isSubmitting = true);
    try {
      final account = await AuthRegistrationService.instance.registerFarmer(
        _controllers.data(),
      );
      await AuthSessionService.instance.start(account, rememberMe: false);
      if (!mounted) return;
      Navigator.of(context).pushReplacement(
        agrisellPageRoute<void>(
          builder: (_) => AuthDashboardRouter.destinationFor(account),
        ),
      );
    } on AuthEmailConfirmationRequired catch (error) {
      if (!mounted) return;
      Navigator.of(context).pushAndRemoveUntil(
        agrisellPageRoute<void>(
          builder: (_) => LoginScreen(initialMessage: error.message),
        ),
        (route) => false,
      );
    } on AuthRegistrationException catch (error) {
      _showMessage(error.message);
    } catch (_) {
      _showMessage(
        'Farmer registration could not be completed. Please try again.',
      );
    } finally {
      if (mounted) _refresh(() => _isSubmitting = false);
    }
  }

  Future<void> _confirmDiscard() async {
    final discard = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Discard registration?'),
        content: const Text(
          'Your entered Farmer registration details will be lost.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Keep editing'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Discard'),
          ),
        ],
      ),
    );
    if (discard == true && mounted) Navigator.of(context).pop();
  }

  void _goToLogin() => Navigator.of(context).pushReplacement(
    agrisellPageRoute<void>(builder: (_) => const LoginScreen()),
  );

  void _showMessage(String message) {
    final messenger = ScaffoldMessenger.of(context);
    messenger.clearSnackBars();
    messenger.showAppSnackBar(SnackBar(content: Text(message)));
  }
}
