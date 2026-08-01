import 'package:flutter/material.dart';
import 'package:agresell_app/core/widgets/app_snack_bar.dart';

import 'package:agresell_app/core/utils/agrisell_page_route.dart';
import 'package:agresell_app/core/utils/password_policy.dart';
import 'package:agresell_app/features/auth/data/auth_registration_service.dart';
import 'package:agresell_app/features/auth/presentation/screens/loginScreen.dart';
import 'package:agresell_app/features/auth/presentation/widgets/authButton.dart';
import 'package:agresell_app/features/auth/presentation/widgets/auth_password_requirements.dart';
import 'package:agresell_app/features/auth/presentation/widgets/authScaffold.dart';
import 'package:agresell_app/features/auth/presentation/widgets/authTextField.dart';
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
  Widget build(BuildContext context) => AuthScaffold(
    title: _step == _PasswordRecoveryStep.requestOtp
        ? 'Forgot Password'
        : 'Set New Password',
    largeTitle: true,
    compactCard: true,
    child: _step == _PasswordRecoveryStep.requestOtp
        ? _requestCodeContent()
        : _newPasswordContent(),
  );

  Widget _requestCodeContent() => Column(
    crossAxisAlignment: CrossAxisAlignment.stretch,
    children: [
      const Text(
        'Enter your email address and we will send a password-reset code.',
        textAlign: TextAlign.center,
      ),
      const SizedBox(height: 24),
      AuthTextField(
        controller: _email,
        hintText: 'Email address',
        keyboardType: TextInputType.emailAddress,
        autofillHints: const [AutofillHints.email],
      ),
      const SizedBox(height: 18),
      AuthPrimaryButton(
        label: 'Send code',
        isLoading: _loading,
        onPressed: _loading ? null : _sendCode,
      ),
      TextButton(
        onPressed: () => Navigator.of(context).pop(),
        child: const Text('Back to login'),
      ),
    ],
  );

  Widget _newPasswordContent() => Column(
    crossAxisAlignment: CrossAxisAlignment.stretch,
    children: [
      const Text(
        'Your email is verified. Choose a new password for your account.',
        textAlign: TextAlign.center,
      ),
      const SizedBox(height: 24),
      AuthTextField(
        controller: _password,
        hintText: 'New password',
        showPasswordToggle: true,
        autofillHints: const [AutofillHints.newPassword],
        onChanged: (_) {
          if (_confirmationTouched) setState(() {});
        },
      ),
      AuthPasswordRequirements(controller: _password),
      const SizedBox(height: 14),
      AuthTextField(
        controller: _confirmation,
        hintText: 'Confirm new password',
        showPasswordToggle: true,
        autofillHints: const [AutofillHints.newPassword],
        onChanged: (_) => setState(() => _confirmationTouched = true),
      ),
      if (_confirmationError case final error?)
        Padding(
          padding: const EdgeInsets.only(top: 6, left: 12),
          child: Text(
            error,
            style: const TextStyle(
              color: Color(0xFFB3261E),
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      const SizedBox(height: 20),
      AuthPrimaryButton(
        label: 'Update password',
        isLoading: _loading,
        onPressed: _loading ? null : _updatePassword,
      ),
    ],
  );

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
            title: 'We just sent an email',
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
