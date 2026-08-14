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

  Future<void> _captureFarmLocation() async {
    return _captureFarmLocationRequest ??= _captureFarmLocationOnce()
        .whenComplete(() => _captureFarmLocationRequest = null);
  }

  Future<void> _captureFarmLocationOnce() async {
    if (_isCapturingLocation) return;
    _refresh(() => _isCapturingLocation = true);
    try {
      if (!await _gpsGateway.isServiceEnabled()) {
        await _gpsGateway.openLocationSettings();
        _validateFarmLocationSilently();
        return;
      }

      var permission = await _gpsGateway.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await _gpsGateway.requestPermission();
      }
      if (permission == LocationPermission.denied) {
        _validateFarmLocationSilently();
        return;
      }
      if (permission == LocationPermission.deniedForever) {
        await _gpsGateway.openAppSettings();
        _validateFarmLocationSilently();
        return;
      }
      if (await _gpsGateway.getAccuracyStatus() ==
          LocationAccuracyStatus.reduced) {
        await _gpsGateway.openAppSettings();
        _validateFarmLocationSilently();
        return;
      }

      final position = await _gpsGateway.currentPosition(
        settings: const LocationSettings(
          accuracy: LocationAccuracy.bestForNavigation,
          timeLimit: Duration(seconds: 15),
        ),
      );
      if (!mounted) return;
      _refresh(() {
        _controllers.setFarmCoordinates(
          latitudeValue: position.latitude,
          longitudeValue: position.longitude,
        );
        _validateCurrent(showEmpty: false);
      });
    } on TimeoutException {
      _validateFarmLocationSilently();
    } catch (_) {
      _validateFarmLocationSilently();
    } finally {
      if (mounted) _refresh(() => _isCapturingLocation = false);
    }
  }

  void _validateFarmLocationSilently() {
    if (!mounted) return;
    _refresh(() => _validateCurrent(showEmpty: false));
  }

  Future<void> _pickImage({required bool profile}) async {
    final image = await ImagePicker().pickImage(
      source: ImageSource.gallery,
      maxWidth: 1600,
      maxHeight: 1600,
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
    final data = _controllers.data();
    try {
      final account = await AuthRegistrationService.instance.registerFarmer(
        data,
      );
      await _finishRegistration(account);
    } on AuthEmailConfirmationRequired {
      await _verifyAndCompleteRegistration(data);
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

  Future<void> _verifyAndCompleteRegistration(FarmerSignupData data) async {
    final email = data.email.trim().toLowerCase();
    final verified = await Navigator.of(context).push<bool>(
      agrisellPageRoute<bool>(
        builder: (_) => OtpVerificationScreen(
          destination: email,
          title: 'Verify your Farmer email',
          changeDestinationLabel: 'Change email',
          onVerify: (otp) => AuthRegistrationService.instance.verifyEmailOtp(
            email: email,
            otp: otp,
          ),
          onResend: () =>
              AuthRegistrationService.instance.resendSignupEmailOtp(email),
        ),
      ),
    );
    if (verified != true || !mounted) return;
    try {
      final account = await AuthRegistrationService.instance
          .completeVerifiedFarmerRegistration(data);
      await _finishRegistration(account);
    } on AuthRegistrationException catch (error) {
      _showMessage(error.message);
    } catch (_) {
      _showMessage(
        'Your email was verified, but the Farmer registration could not be completed.',
      );
    }
  }

  Future<void> _finishRegistration(RegisteredAccount account) async {
    await AuthSessionService.instance.start(account, rememberMe: false);
    if (!mounted) return;
    Navigator.of(context).pushAndRemoveUntil(
      agrisellPageRoute<void>(
        builder: (_) =>
            FarmerRegistrationSubmittedScreen(reference: account.id),
      ),
      (route) => false,
    );
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
