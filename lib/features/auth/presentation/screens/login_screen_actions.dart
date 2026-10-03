part of 'login_screen.dart';

extension _LoginScreenActions on _LoginScreenState {
  Future<void> _logIn() async {
    final identifierError = LoginValidator.validateIdentifier(_identifier.text);
    if (identifierError != null) {
      _showMessage(identifierError);
      return;
    }
    final passwordError = LoginValidator.validatePassword(_password.text);
    if (passwordError != null) {
      _showMessage(passwordError);
      return;
    }

    _updateUi(() => _isLoggingIn = true);
    try {
      if (AuthSessionService.instance.currentAccount != null) {
        await BasketController.instance.flush();
      }
      final account = await AuthRegistrationService.instance.authenticate(
        _identifier.text,
        _password.text,
      );
      if (!mounted) return;
      if (account == null) {
        _updateUi(() => _isLoggingIn = false);
        _showMessage('Email or password is incorrect.');
        return;
      }

      await _finishLogin(account);
    } on AuthEmailNotVerified {
      if (!mounted) return;
      _updateUi(() => _isLoggingIn = false);
      await _resumeUnverifiedSignup();
    } on AuthRegistrationException catch (error) {
      if (!mounted) return;
      _updateUi(() => _isLoggingIn = false);
      _showMessage(error.message);
    } catch (_) {
      if (!mounted) return;
      _updateUi(() => _isLoggingIn = false);
      _showMessage(
        'We could not load your account information. Please try again.',
      );
    }
  }

  Future<void> _resumeUnverifiedSignup() async {
    final email = _identifier.text.trim().toLowerCase();
    RegisteredAccount? account;
    final verified = await Navigator.of(context).push<bool>(
      agrisellPageRoute<bool>(
        builder: (_) => OtpVerificationScreen(
          destination: email,
          title: 'Finish verifying your email',
          onVerify: (otp) async {
            account = await AuthRegistrationService.instance.verifyEmailOtp(
              email: email,
              otp: otp,
            );
          },
          onResend: () =>
              AuthRegistrationService.instance.resendSignupEmailOtp(email),
        ),
      ),
    );
    if (verified != true || account == null || !mounted) return;
    try {
      _updateUi(() => _isLoggingIn = true);
      await _finishLogin(account!);
    } on AuthRegistrationException catch (error) {
      if (!mounted) return;
      _updateUi(() => _isLoggingIn = false);
      _showMessage(error.message);
    }
  }

  Future<void> _finishLogin(RegisteredAccount account) async {
    if (account.profilePending) {
      _updateUi(() => _isLoggingIn = false);
      _navigateTo(switch (account.assignedRole) {
        AuthRole.buyer => SignUpScreen(
          role: AuthRole.buyer,
          initialVerifiedEmail: account.email,
        ),
        AuthRole.farmer => FarmerSignUpScreen(
          initialVerifiedEmail: account.email,
        ),
        AuthRole.rider => RiderSignUpScreen(
          initialVerifiedEmail: account.email,
        ),
        _ => const RoleSelectionScreen.signUp(),
      });
      return;
    }
    final resolution = AuthRouteGuard.resolve(account);
    if (account.assignedRole == null) {
      await AuthSessionService.instance.clear(forgetAccount: false);
      if (!mounted) return;
      _updateUi(() => _isLoggingIn = false);
      _showMessage(
        resolution.message ??
            'Your account role is invalid. Please contact support.',
      );
      return;
    }
    await AuthSessionService.instance.start(account, rememberMe: _rememberMe);
    if (!mounted) return;
    TextInput.finishAutofillContext(shouldSave: true);
    _navigateTo(AuthDashboardRouter.destinationFor(account));
  }

  Future<void> _loadRememberedIdentifier() async {
    final identifier = await AuthSessionService.instance
        .loadRememberedIdentifier();
    if (!mounted || identifier == null || _identifier.text.isNotEmpty) return;
    _identifier.text = identifier;
    _updateUi(() => _rememberMe = true);
  }

  void _navigateTo(Widget destination) {
    Navigator.of(context).pushAndRemoveUntil(
      agrisellPageRoute<void>(builder: (_) => destination),
      (route) => false,
    );
  }

  void _showForgotPasswordMessage() {
    Navigator.of(context).push(
      agrisellPageRoute<void>(builder: (_) => const ForgotPasswordScreen()),
    );
  }

  void _showMessage(String message) {
    final messenger = ScaffoldMessenger.of(context);
    messenger.clearSnackBars();
    messenger.showAppSnackBar(SnackBar(content: Text(message)));
  }
}
