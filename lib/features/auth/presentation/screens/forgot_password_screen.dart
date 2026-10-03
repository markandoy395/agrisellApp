import 'package:flutter/material.dart';

import 'package:agresell_app/core/theme/agrisell_colors.dart';
import 'package:agresell_app/core/utils/agrisell_page_route.dart';
import 'package:agresell_app/core/utils/password_policy.dart';
import 'package:agresell_app/core/widgets/app_snack_bar.dart';
import 'package:agresell_app/features/auth/data/auth_registration_service.dart';
import 'package:agresell_app/features/auth/presentation/screens/login_screen.dart';
import 'package:agresell_app/features/auth/presentation/widgets/forgot_password_request_step.dart';
import 'package:agresell_app/features/auth/presentation/widgets/forgot_password_reset_step.dart';
import 'package:agresell_app/features/auth/presentation/widgets/login_page_layout.dart';
import 'package:agresell_app/features/auth/presentation/widgets/otp_verification_screen.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final _email = TextEditingController();
  final _password = TextEditingController();
  final _confirmation = TextEditingController();
  var _step = _PasswordRecoveryStep.requestOtp;
  var _loading = false;
  var _confirmationTouched = false;

  String? get _confirmationError {
    if (!_confirmationTouched) return null;
    if (_confirmation.text.isEmpty) return 'Confirm your new password.';
    if (_password.text != _confirmation.text) return 'Passwords do not match.';
    return null;
  }

  @override
  void dispose() {
    _email.dispose();
    _password.dispose();
    _confirmation.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final height = MediaQuery.sizeOf(context).height;
    final isRequestStep = _step == _PasswordRecoveryStep.requestOtp;
    final cardHeight = (height * (isRequestStep ? .495 : .68))
        .clamp(isRequestStep ? 390.0 : 500.0, isRequestStep ? 480.0 : 640.0)
        .toDouble();

    return LoginPageLayout(
      title: isRequestStep ? 'Forgot Password' : 'Set New Password',
      titleColor: AgrisellColors.authGreen,
      subtitle: null,
      cardHeight: cardHeight,
      cardTopPadding: 44,
      child: isRequestStep
          ? ForgotPasswordRequestStep(
              emailController: _email,
              loading: _loading,
              onSendCode: _sendCode,
              onBackToLogin: () => Navigator.of(context).pop(),
            )
          : ForgotPasswordResetStep(
              passwordController: _password,
              confirmationController: _confirmation,
              confirmationError: _confirmationError,
              loading: _loading,
              onPasswordChanged: (_) {
                if (_confirmationTouched) setState(() {});
              },
              onConfirmationChanged: (_) =>
                  setState(() => _confirmationTouched = true),
              onUpdatePassword: _updatePassword,
              onBackToLogin: () => Navigator.of(context).pop(),
            ),
    );
  }

  Future<void> _sendCode() async {
    final email = _email.text.trim();
    if (!_isEmail(email)) {
      _showMessage('Enter a valid email address.');
      return;
    }
    setState(() => _loading = true);
    try {
      await AuthRegistrationService.instance.requestPasswordReset(email);
      if (!mounted) return;
      final verified = await Navigator.of(context).push<bool>(
        agrisellPageRoute<bool>(
          builder: (_) => OtpVerificationScreen(
            destination: email,
            title: 'Verify your login',
            onVerify: (otp) => AuthRegistrationService.instance
                .verifyPasswordRecoveryOtp(email: email, otp: otp),
            onResend: () => AuthRegistrationService.instance
                .resendPasswordRecoveryOtp(email),
          ),
        ),
      );
      if (verified == true && mounted) {
        setState(() => _step = _PasswordRecoveryStep.newPassword);
      }
    } on AuthRegistrationException catch (error) {
      _showMessage(error.message);
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _updatePassword() async {
    final password = _password.text;
    if (!PasswordPolicy.isStrong(password)) {
      _showMessage('Use a stronger password.');
      return;
    }
    if (password != _confirmation.text) {
      setState(() => _confirmationTouched = true);
      return;
    }
    setState(() => _loading = true);
    try {
      await AuthRegistrationService.instance.completePasswordRecovery(password);
      if (!mounted) return;
      Navigator.of(context).pushAndRemoveUntil(
        agrisellPageRoute<void>(
          builder: (_) => const LoginScreen(
            initialMessage: 'Password updated. You can now log in.',
          ),
        ),
        (route) => false,
      );
    } on AuthRegistrationException catch (error) {
      _showMessage(error.message);
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  bool _isEmail(String value) =>
      RegExp(r'^[^\s@]+@[^\s@]+\.[^\s@]+$').hasMatch(value);

  void _showMessage(String message) {
    final messenger = ScaffoldMessenger.of(context);
    messenger.clearSnackBars();
    messenger.showAppSnackBar(SnackBar(content: Text(message)));
  }
}

enum _PasswordRecoveryStep { requestOtp, newPassword }
