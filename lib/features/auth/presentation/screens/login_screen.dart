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
import 'package:agresell_app/features/auth/presentation/widgets/login_page_layout.dart';
import 'package:agresell_app/features/auth/presentation/widgets/login_form.dart';
import 'package:agresell_app/features/auth/presentation/widgets/otp_verification_screen.dart';
import 'package:agresell_app/features/auth/presentation/screens/role_selection_screen.dart';
import 'package:agresell_app/features/auth/presentation/screens/sign_up_screen.dart';
import 'package:agresell_app/features/auth/presentation/screens/forgot_password_screen.dart';
import 'package:agresell_app/features/buyer/cart/presentation/controllers/basket_controller.dart';
import 'package:agresell_app/features/farmer/registration/presentation/screens/farmer_sign_up_screen.dart';
import 'package:agresell_app/features/rider/profile/presentation/screens/rider_sign_up_screen.dart';

part 'login_screen_actions.dart';

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

  void _updateUi(VoidCallback update) => setState(update);

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
    return LoginPageLayout(
      title: widget.title == 'Log In' ? 'Welcome Back' : widget.title,
      cardHeightFactor: .60,
      minimumCardHeight: 500,
      maximumCardHeight: 560,
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
}
