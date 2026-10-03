import 'package:flutter/material.dart';

import '../data/auth_session_service.dart';
import 'screens/forgot_password_screen.dart';
import 'screens/login_screen.dart';
import 'screens/role_selection_screen.dart';
import 'screens/sign_up_screen.dart';
import 'screens/splash_screen.dart';
import 'widgets/otp_verification_screen.dart';
import '../../farmer/registration/presentation/screens/farmer_sign_up_screen.dart';
import '../../farmer/registration/presentation/screens/farmer_registration_submitted_screen.dart';
import '../../rider/profile/presentation/screens/rider_sign_up_screen.dart';
import '../../rider/profile/presentation/screens/rider_application_submitted_screen.dart';

/// Only the authentication flow is public. New destinations default to private.
class AuthPageGate extends StatelessWidget {
  const AuthPageGate({required this.child, super.key});

  final Widget child;

  static bool isPublic(Widget page) =>
      page is LoginScreen ||
      page is SplashScreen ||
      page is ForgotPasswordScreen ||
      page is RoleSelectionScreen ||
      page is SignUpScreen ||
      page is FarmerSignUpScreen ||
      page is RiderSignUpScreen ||
      page is OtpVerificationScreen ||
      page is FarmerRegistrationSubmittedScreen ||
      page is RiderApplicationSubmittedScreen;

  @override
  Widget build(BuildContext context) => ListenableBuilder(
    listenable: AuthSessionService.instance,
    builder: (context, _) {
      if (isPublic(child) || AuthSessionService.instance.isAuthenticated) {
        return child;
      }
      return const SignedOutRedirect();
    },
  );
}

class SignedOutRedirect extends StatefulWidget {
  const SignedOutRedirect({super.key});

  @override
  State<SignedOutRedirect> createState() => _SignedOutRedirectState();
}

class _SignedOutRedirectState extends State<SignedOutRedirect> {
  bool _scheduled = false;

  @override
  Widget build(BuildContext context) {
    final isCurrent = ModalRoute.isCurrentOf(context) ?? true;
    if (isCurrent && !_scheduled) {
      _scheduled = true;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted || ModalRoute.of(context)?.isCurrent == false) return;
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute<void>(builder: (_) => const LoginScreen()),
          (_) => false,
        );
      });
    }
    return const SizedBox.shrink();
  }
}
