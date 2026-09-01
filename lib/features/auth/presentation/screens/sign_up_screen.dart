import 'package:flutter/material.dart';

import 'package:agresell_app/core/utils/agrisell_page_route.dart';
import 'package:agresell_app/core/utils/philippine_phone_number.dart';
import 'package:agresell_app/core/widgets/app_snack_bar.dart';
import 'package:agresell_app/features/auth/data/auth_registration_service.dart';
import 'package:agresell_app/features/auth/data/auth_session_service.dart';
import 'package:agresell_app/features/auth/domain/sign_up_account_data.dart';
import 'package:agresell_app/features/auth/domain/sign_up_validator.dart';
import 'package:agresell_app/features/auth/presentation/auth_dashboard_router.dart';
import 'package:agresell_app/features/auth/presentation/screens/login_screen.dart';
import 'package:agresell_app/features/auth/presentation/widgets/auth_bottom_link.dart';
import 'package:agresell_app/features/auth/presentation/widgets/auth_button.dart';
import 'package:agresell_app/features/auth/presentation/widgets/auth_checkbox.dart';
import 'package:agresell_app/features/auth/presentation/widgets/auth_divider.dart';
import 'package:agresell_app/features/auth/presentation/widgets/auth_password_requirements.dart';
import 'package:agresell_app/features/auth/presentation/widgets/auth_scaffold.dart';
import 'package:agresell_app/features/auth/presentation/widgets/auth_text_field.dart';
import 'package:agresell_app/features/auth/presentation/widgets/otp_verification_screen.dart';
import 'package:agresell_app/features/auth/presentation/widgets/sign_up_identity_fields.dart';
import 'package:agresell_app/features/auth/presentation/widgets/social_sign_in_button.dart';

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
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _extensionNameController = TextEditingController();
  final _contactNumberController = TextEditingController();
  final _dateOfBirthController = TextEditingController();
  final _genderController = TextEditingController();
  final _shippingAddressController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  bool _agreesToPolicy = false;
  bool _isSubmitting = false;
  int _step = 0;
  String? _otpStartedFor;
  String? _verifiedEmail;

  @override
  void initState() {
    super.initState();
    final initialEmail = widget.initialVerifiedEmail?.trim().toLowerCase();
    if (initialEmail != null && initialEmail.isNotEmpty) {
      _emailController.text = initialEmail;
      _verifiedEmail = initialEmail;
      _step = 1;
    }
  }

  @override
  void dispose() {
    for (final controller in [
      _firstNameController,
      _lastNameController,
      _extensionNameController,
      _contactNumberController,
      _dateOfBirthController,
      _genderController,
      _shippingAddressController,
      _emailController,
      _passwordController,
      _confirmPasswordController,
    ]) {
      controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => AuthScaffold(
    key: ValueKey(_step),
    title: 'Sign Up',
    child: Column(
      children: [
        _progress(),
        const SizedBox(height: 16),
        if (_step == 0) _credentialsStep() else _personalInformationStep(),
        const SizedBox(height: 20),
        AuthBottomLink(
          label: 'Already have an account?',
          action: 'Log in',
          onTap: _isSubmitting ? () {} : _goToLogin,
        ),
      ],
    ),
  );

  Widget _progress() => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(
        'Step ${_step + 1} of 2',
        style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
      ),
      const SizedBox(height: 6),
      LinearProgressIndicator(value: (_step + 1) / 2, minHeight: 5),
    ],
  );

  Widget _credentialsStep() {
    final credentialsLocked = _otpStartedFor != null || _verifiedEmail != null;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Account credentials',
          style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700),
        ),
        const SizedBox(height: 6),
        const Text(
          'Verify your email before entering your personal information.',
          style: TextStyle(fontSize: 12),
        ),
        const SizedBox(height: 12),
        AuthTextField(
          controller: _emailController,
          hintText: 'Email',
          keyboardType: TextInputType.emailAddress,
          textInputAction: TextInputAction.next,
          autofillHints: const [AutofillHints.email],
          readOnly: credentialsLocked,
        ),
        const SizedBox(height: 14),
        AuthTextField(
          controller: _passwordController,
          hintText: 'Password',
          showPasswordToggle: true,
          textInputAction: TextInputAction.next,
          autofillHints: const [AutofillHints.newPassword],
          readOnly: credentialsLocked,
        ),
        if (_verifiedEmail == null)
          AuthPasswordRequirements(controller: _passwordController),
        const SizedBox(height: 14),
        AuthTextField(
          controller: _confirmPasswordController,
          hintText: 'Confirm Password',
          showPasswordToggle: true,
          textInputAction: TextInputAction.done,
          autofillHints: const [AutofillHints.newPassword],
          readOnly: credentialsLocked,
        ),
        if (credentialsLocked) ...[
          const SizedBox(height: 8),
          Text(
            _verifiedEmail != null
                ? 'Email verified. These credentials are locked for this registration.'
                : 'OTP sent. Use Change email on the verification screen to edit these credentials.',
            style: const TextStyle(fontSize: 12),
          ),
        ],
        const SizedBox(height: 20),
        AuthPrimaryButton(
          label: 'Continue',
          isLoading: _isSubmitting,
          onPressed: _isSubmitting ? null : _continueFromCredentials,
        ),
        const SizedBox(height: 20),
        const AuthDivider(text: 'Or Sign up with'),
        const SizedBox(height: 16),
        const SocialSignInButton(
          brand: SocialBrand.facebook,
          label: 'Sign up with Facebook',
        ),
        const SizedBox(height: 12),
        const SocialSignInButton(
          brand: SocialBrand.google,
          label: 'Sign up with Google',
        ),
      ],
    );
  }

  Widget _personalInformationStep() => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      const Text(
        'Personal information',
        style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700),
      ),
      const SizedBox(height: 6),
      Text(
        'Verified email: ${_emailController.text.trim().toLowerCase()}',
        style: const TextStyle(fontSize: 12),
      ),
      const SizedBox(height: 12),
      SignUpIdentityFields(
        firstNameController: _firstNameController,
        lastNameController: _lastNameController,
        extensionNameController: _extensionNameController,
        contactNumberController: _contactNumberController,
        dateOfBirthController: _dateOfBirthController,
        genderController: _genderController,
        shippingAddressController: _shippingAddressController,
        emailController: _emailController,
        showEmail: false,
      ),
      const SizedBox(height: 18),
      AuthPolicyCheckbox(
        value: _agreesToPolicy,
        onChanged: (value) => setState(() => _agreesToPolicy = value),
      ),
      const SizedBox(height: 20),
      AuthPrimaryButton(
        label: 'Sign up',
        isLoading: _isSubmitting,
        onPressed: _isSubmitting ? null : _completeSignUp,
      ),
      const SizedBox(height: 10),
      AuthOutlinedButton(
        label: 'Back to credentials',
        onPressed: _isSubmitting ? null : () => setState(() => _step = 0),
      ),
    ],
  );

  Future<void> _continueFromCredentials() async {
    if (_isSubmitting) return;
    final email = _emailController.text.trim().toLowerCase();
    if (_verifiedEmail == email) {
      setState(() => _step = 1);
      return;
    }
    final validation = SignUpValidator.validateCredentials(
      email: email,
      password: _passwordController.text,
      confirmPassword: _confirmPasswordController.text,
    );
    if (validation != null) {
      _showMessage(validation);
      return;
    }
    setState(() => _isSubmitting = true);
    try {
      if (_otpStartedFor != email) {
        final requiresOtp = await AuthRegistrationService.instance
            .startEmailVerification(
              email: email,
              password: _passwordController.text,
              role: widget.role,
            );
        if (!mounted) return;
        if (!requiresOtp) {
          setState(() {
            _verifiedEmail = email;
            _step = 1;
          });
          return;
        }
        setState(() => _otpStartedFor = email);
      }
      final verified = await _verifySignupEmail(email);
      if (!verified || !mounted) return;
      setState(() {
        _verifiedEmail = email;
        _otpStartedFor = null;
        _step = 1;
      });
    } on AuthRegistrationException catch (error) {
      _showMessage(error.message);
    } catch (_) {
      _showMessage('We could not verify your email. Please try again.');
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  Future<bool> _verifySignupEmail(String email) async {
    final verified = await Navigator.of(context).push<bool>(
      agrisellPageRoute<bool>(
        builder: (_) => OtpVerificationScreen(
          destination: email,
          title: 'Verify your Buyer email',
          changeDestinationLabel: 'Change email',
          onChangeDestination: () {
            if (mounted) setState(() => _otpStartedFor = null);
          },
          onVerify: (otp) => AuthRegistrationService.instance.verifyEmailOtp(
            email: email,
            otp: otp,
          ),
          onResend: () =>
              AuthRegistrationService.instance.resendSignupEmailOtp(email),
        ),
      ),
    );
    return verified == true;
  }

  Future<void> _completeSignUp() async {
    if (_isSubmitting) return;
    final validation = SignUpValidator.validateBuyerProfile(
      firstName: _firstNameController.text.trim(),
      lastName: _lastNameController.text.trim(),
      contactNumber: _contactNumberController.text.trim(),
      dateOfBirth: _dateOfBirthController.text.trim(),
      gender: _genderController.text.trim(),
      shippingAddress: _shippingAddressController.text.trim(),
      agreesToPolicy: _agreesToPolicy,
    );
    if (validation != null) {
      _showMessage(validation);
      return;
    }

    final data = SignUpAccountData(
      firstName: _firstNameController.text.trim(),
      lastName: _lastNameController.text.trim(),
      extensionName: _extensionNameController.text.trim(),
      phoneNumber: PhilippinePhoneNumber.normalize(
        _contactNumberController.text,
      ),
      dateOfBirth: _dateOfBirthController.text.trim(),
      gender: _genderController.text.trim(),
      shippingAddress: _shippingAddressController.text.trim(),
      email: _emailController.text.trim().toLowerCase(),
      password: _passwordController.text,
    );
    setState(() => _isSubmitting = true);
    try {
      final service = AuthRegistrationService.instance;
      final account = service.usesSupabase
          ? await service.completeVerifiedBuyerRegistration(data)
          : await service.register(data, widget.role);
      await _finishSignUp(account);
    } on AuthRegistrationException catch (error) {
      _showMessage(error.message);
    } catch (_) {
      _showMessage('Account creation failed. Please try again.');
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  Future<void> _finishSignUp(RegisteredAccount account) async {
    await AuthSessionService.instance.start(account, rememberMe: false);
    if (!mounted) return;
    Navigator.of(context).pushAndRemoveUntil(
      agrisellPageRoute<void>(
        builder: (_) => AuthDashboardRouter.destinationFor(
          account,
          initialMessage:
              'Your ${widget.role.label} account was created successfully.',
        ),
      ),
      (route) => false,
    );
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
