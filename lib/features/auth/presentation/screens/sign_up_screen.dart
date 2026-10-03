import 'package:flutter/material.dart';

import 'package:agresell_app/core/utils/agrisell_page_route.dart';
import 'package:agresell_app/core/widgets/app_snack_bar.dart';
import 'package:agresell_app/features/auth/data/auth_registration_service.dart';
import 'package:agresell_app/features/auth/domain/sign_up_account_data.dart';
import 'package:agresell_app/features/auth/domain/sign_up_validator.dart';
import 'package:agresell_app/features/auth/presentation/controllers/sign_up_flow_coordinator.dart';
import 'package:agresell_app/features/auth/presentation/controllers/sign_up_form_controllers.dart';
import 'package:agresell_app/features/auth/presentation/screens/login_screen.dart';
import 'package:agresell_app/features/auth/presentation/styles/sign_up_screen_styles.dart';
import 'package:agresell_app/features/auth/presentation/widgets/auth_bottom_link.dart';
import 'package:agresell_app/features/auth/presentation/widgets/auth_scaffold.dart';
import 'package:agresell_app/features/auth/presentation/widgets/sign_up_credentials_step.dart';
import 'package:agresell_app/features/auth/presentation/widgets/sign_up_personal_info_step.dart';
import 'package:agresell_app/features/auth/presentation/widgets/sign_up_progress_bar.dart';

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({
    required this.role,
    this.initialVerifiedEmail,
    super.key,
  });

  final AuthRole role;
  final String? initialVerifiedEmail;

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  final _form = SignUpFormControllers();
  late final SignUpFlowCoordinator _coordinator;

  bool _agreesToPolicy = false;
  bool _isSubmitting = false;
  int _step = 0;
  String? _otpStartedFor;
  String? _verifiedEmail;

  bool get _isCredentialsLocked =>
      _otpStartedFor != null || _verifiedEmail != null;

  @override
  void initState() {
    super.initState();
    _coordinator = SignUpFlowCoordinator(role: widget.role);
    final initialEmail = widget.initialVerifiedEmail?.trim().toLowerCase();
    if (initialEmail != null && initialEmail.isNotEmpty) {
      _form.email.text = initialEmail;
      _verifiedEmail = initialEmail;
      _step = 1;
    }
  }

  @override
  void dispose() {
    _form.dispose();
    super.dispose();
  }

  Future<void> _continueFromCredentials() async {
    if (_isSubmitting) return;
    final email = _form.email.text.trim().toLowerCase();
    if (_verifiedEmail == email) {
      setState(() => _step = 1);
      return;
    }
    final validation = SignUpValidator.validateCredentials(
      email: email,
      password: _form.password.text,
      confirmPassword: _form.confirmPassword.text,
    );
    if (validation != null) {
      _showMessage(validation);
      return;
    }

    setState(() => _isSubmitting = true);
    try {
      await _coordinator.executeCredentialsVerification(
        context,
        email: email,
        password: _form.password.text,
        isOtpStarted: _otpStartedFor == email,
        onOtpStarted: (e) => setState(() => _otpStartedFor = e),
        onResetOtpStarted: () {
          if (mounted) setState(() => _otpStartedFor = null);
        },
        onVerified: (e) => setState(() {
          _verifiedEmail = e;
          _otpStartedFor = null;
          _step = 1;
        }),
        onError: _showMessage,
      );
    } on AuthRegistrationException catch (error) {
      _showMessage(error.message);
    } catch (_) {
      _showMessage(SignUpScreenStyles.emailVerificationFailedNotice);
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  Future<void> _completeSignUp() async {
    if (_isSubmitting) return;
    final validation = SignUpValidator.validateBuyerProfile(
      firstName: _form.firstName.text.trim(),
      lastName: _form.lastName.text.trim(),
      contactNumber: _form.contactNumber.text.trim(),
      dateOfBirth: _form.dateOfBirth.text.trim(),
      gender: _form.gender.text.trim(),
      shippingAddress: _form.shippingAddress.text.trim(),
      agreesToPolicy: _agreesToPolicy,
    );
    if (validation != null) {
      _showMessage(validation);
      return;
    }

    setState(() => _isSubmitting = true);
    try {
      final account = await _coordinator.registerBuyer(
        data: _form.toAccountData(),
      );
      if (!mounted) return;
      await _coordinator.finishSignUp(context, account: account);
    } on AuthRegistrationException catch (error) {
      _showMessage(error.message);
    } catch (_) {
      _showMessage(SignUpScreenStyles.accountCreationFailedNotice);
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  void _goToLogin() => Navigator.of(context).pushReplacement(
    agrisellPageRoute<void>(builder: (_) => const LoginScreen()),
  );

  void _showMessage(String message) {
    final messenger = ScaffoldMessenger.of(context);
    messenger.clearSnackBars();
    messenger.showAppSnackBar(SignUpScreenStyles.snackBar(message));
  }

  @override
  Widget build(BuildContext context) => AuthScaffold(
    key: ValueKey(_step),
    title: 'Sign Up',
    fillRemaining: false,
    child: Column(
      children: [
        SignUpProgressBar(step: _step),
        const SizedBox(height: SignUpScreenStyles.stepGap),
        if (_step == 0)
          SignUpCredentialsStep(
            form: _form,
            isSubmitting: _isSubmitting,
            isCredentialsLocked: _isCredentialsLocked,
            isEmailVerified: _verifiedEmail != null,
            onContinue: _continueFromCredentials,
          )
        else
          SignUpPersonalInfoStep(
            form: _form,
            agreesToPolicy: _agreesToPolicy,
            onAgreesToPolicyChanged: (value) =>
                setState(() => _agreesToPolicy = value),
            isSubmitting: _isSubmitting,
            onCompleteSignUp: _completeSignUp,
            onBackToCredentials: () => setState(() => _step = 0),
          ),
        const SizedBox(height: SignUpScreenStyles.bottomLinkGap),
        AuthBottomLink(
          label: 'Already have an account?',
          action: 'Log in',
          onTap: _isSubmitting ? () {} : _goToLogin,
        ),
      ],
    ),
  );
}
