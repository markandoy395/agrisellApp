import 'package:flutter/material.dart';
import 'package:agresell_app/core/widgets/app_snack_bar.dart';

import 'package:agresell_app/core/utils/agrisellPageRoute.dart';
import 'package:agresell_app/features/auth/data/authRegistrationService.dart';
import 'package:agresell_app/features/auth/data/auth_session_service.dart';
import 'package:agresell_app/features/auth/domain/auth_route_guard.dart';
import 'package:agresell_app/features/auth/domain/login_validator.dart';
import 'package:agresell_app/features/auth/presentation/auth_dashboard_router.dart';
import 'package:agresell_app/features/auth/presentation/widgets/authBottomLink.dart';
import 'package:agresell_app/features/auth/presentation/widgets/authButton.dart';
import 'package:agresell_app/features/auth/presentation/widgets/authCheckbox.dart';
import 'package:agresell_app/features/auth/presentation/widgets/authScaffold.dart';
import 'package:agresell_app/features/auth/presentation/widgets/authTextField.dart';
import 'package:agresell_app/features/auth/presentation/screens/roleSelectionScreen.dart';
import 'package:agresell_app/features/auth/presentation/screens/forgot_password_screen.dart';
import 'package:agresell_app/features/buyer/cart/presentation/controllers/basket_controller.dart';

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
      child: Column(
        children: [
          AuthTextField(
            hintText: 'Email or phone number',
            controller: _identifier,
            keyboardType: TextInputType.emailAddress,
            autofillHints: const [AutofillHints.username],
          ),
          const SizedBox(height: 14),
          AuthTextField(
            hintText: 'Password',
            controller: _password,
            showPasswordToggle: true,
            autofillHints: const [AutofillHints.password],
          ),
          const SizedBox(height: 10),
          AuthCheckbox(
            label: 'Remember me',
            value: _rememberMe,
            onChanged: (value) => setState(() => _rememberMe = value),
          ),
          Align(
            alignment: Alignment.centerRight,
            child: TextButton(
              onPressed: _showForgotPasswordMessage,
              style: TextButton.styleFrom(
                minimumSize: const Size(0, 36),
                padding: const EdgeInsets.symmetric(horizontal: 8),
              ),
              child: const Text('Forgot password?'),
            ),
          ),
          const SizedBox(height: 14),
          AuthPrimaryButton(
            label: 'Log In',
            onPressed: _isLoggingIn ? null : _logIn,
            isLoading: _isLoggingIn,
          ),
          const SizedBox(height: 24),
          const Spacer(),
          AuthBottomLink(
            label: "Don't have an account?",
            action: 'Create account',
            onTap: () {
              Navigator.of(context).pushReplacement(
                agrisellPageRoute<void>(
                  builder: (_) => const RoleSelectionScreen.signUp(),
                ),
              );
            },
          ),
          const SizedBox(height: 8),
        ],
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
      _navigateTo(AuthDashboardRouter.destinationFor(account));
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
