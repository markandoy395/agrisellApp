import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:agresell_app/core/widgets/app_snack_bar.dart';

import 'package:agresell_app/core/utils/agrisell_page_route.dart';
import 'package:agresell_app/features/auth/data/auth_registration_service.dart';
import 'package:agresell_app/features/auth/data/auth_session_service.dart';
import 'package:agresell_app/features/auth/domain/auth_route_guard.dart';
import 'package:agresell_app/features/auth/domain/login_validator.dart';
import 'package:agresell_app/features/auth/domain/sign_up_account_data.dart';
import 'package:agresell_app/features/auth/presentation/auth_dashboard_router.dart';
import 'package:agresell_app/features/auth/presentation/widgets/auth_scaffold.dart';
import 'package:agresell_app/features/auth/presentation/widgets/login_form.dart';
import 'package:agresell_app/features/auth/presentation/widgets/otp_verification_screen.dart';
import 'package:agresell_app/features/auth/presentation/screens/role_selection_screen.dart';
import 'package:agresell_app/features/auth/presentation/screens/sign_up_screen.dart';
import 'package:agresell_app/features/auth/presentation/screens/forgot_password_screen.dart';
import 'package:agresell_app/features/buyer/cart/presentation/controllers/basket_controller.dart';
import 'package:agresell_app/features/farmer/registration/presentation/screens/farmer_sign_up_screen.dart';
import 'package:agresell_app/features/rider/profile/presentation/screens/rider_sign_up_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({
    this.initialMessage,
    this.initialIdentifier,
    this.rememberMeInitially = false,
    this.title = 'Log In',
    super.key,
  });

  final String? initialMessage;
  final String? initialIdentifier;
  final bool rememberMeInitially;
  final String title;

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  late final TextEditingController _identifier;
  final _password = TextEditingController();
  late bool _rememberMe;
  var _isLoggingIn = false;

  @override
  void initState() {
    super.initState();
    _identifier = TextEditingController(text: widget.initialIdentifier);
    _rememberMe = widget.rememberMeInitially;
    if (widget.initialIdentifier == null) {
      unawaited(_loadRememberedIdentifier());
    }
    final initialMessage = widget.initialMessage;
    if (initialMessage == null) return;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) _showMessage(initialMessage);
    });
  }

  @override
  void dispose() {
    _identifier.dispose();
    _password.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AuthScaffold(
      title: widget.title,
      largeTitle: true,
      compactCard: true,
      child: LoginForm(
        identifierController: _identifier,
        passwordController: _password,
        rememberMe: _rememberMe,
        isLoggingIn: _isLoggingIn,
        onRememberChanged: (value) => setState(() => _rememberMe = value),
        onLogIn: _isLoggingIn ? null : _logIn,
        onForgotPassword: _showForgotPasswordMessage,
        onCreateAccount: () {
          Navigator.of(context).pushReplacement(
            agrisellPageRoute<void>(
              builder: (_) => const RoleSelectionScreen.signUp(),
            ),
          );
        },
      ),
    );
  }

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

    setState(() => _isLoggingIn = true);
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
        setState(() => _isLoggingIn = false);
        _showMessage('Email or password is incorrect.');
        return;
      }

      await _finishLogin(account);
    } on AuthEmailNotVerified {
      if (!mounted) return;
      setState(() => _isLoggingIn = false);
      await _resumeUnverifiedSignup();
    } on AuthRegistrationException catch (error) {
      if (!mounted) return;
      setState(() => _isLoggingIn = false);
      _showMessage(error.message);
    } catch (_) {
      if (!mounted) return;
      setState(() => _isLoggingIn = false);
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
      setState(() => _isLoggingIn = true);
      await _finishLogin(account!);
    } on AuthRegistrationException catch (error) {
      if (!mounted) return;
      setState(() => _isLoggingIn = false);
      _showMessage(error.message);
    }
  }

  Future<void> _finishLogin(RegisteredAccount account) async {
    if (account.profilePending) {
      setState(() => _isLoggingIn = false);
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
      setState(() => _isLoggingIn = false);
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
    setState(() => _rememberMe = true);
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
