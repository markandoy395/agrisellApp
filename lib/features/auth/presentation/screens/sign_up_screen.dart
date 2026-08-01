import 'package:flutter/material.dart';
import 'package:agresell_app/core/widgets/app_snack_bar.dart';

import 'package:agresell_app/core/utils/agrisell_page_route.dart';
import 'package:agresell_app/core/utils/philippine_phone_number.dart';
import 'package:agresell_app/features/auth/data/auth_registration_service.dart';
import 'package:agresell_app/features/auth/data/auth_session_service.dart';
import 'package:agresell_app/features/auth/domain/sign_up_account_data.dart';
import 'package:agresell_app/features/auth/domain/sign_up_validator.dart';
import 'package:agresell_app/features/auth/presentation/auth_dashboard_router.dart';
import 'package:agresell_app/features/auth/presentation/widgets/auth_bottom_link.dart';
import 'package:agresell_app/features/auth/presentation/widgets/auth_button.dart';
import 'package:agresell_app/features/auth/presentation/widgets/auth_checkbox.dart';
import 'package:agresell_app/features/auth/presentation/widgets/auth_divider.dart';
import 'package:agresell_app/features/auth/presentation/widgets/auth_password_requirements.dart';
import 'package:agresell_app/features/auth/presentation/widgets/auth_scaffold.dart';
import 'package:agresell_app/features/auth/presentation/widgets/auth_text_field.dart';
import 'package:agresell_app/features/auth/presentation/widgets/sign_up_identity_fields.dart';
import 'package:agresell_app/features/auth/presentation/widgets/social_sign_in_button.dart';
import 'package:agresell_app/features/rider/profile/presentation/screens/rider_sign_up_screen.dart';
import 'package:agresell_app/features/auth/presentation/screens/login_screen.dart';

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({required this.role, super.key});

  final AuthRole role;
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
  Widget build(BuildContext context) {
    return AuthScaffold(
      title: 'Sign Up',
      child: Column(
        children: [
          const SizedBox(height: 10),
          SignUpIdentityFields(
            firstNameController: _firstNameController,
            lastNameController: _lastNameController,
            extensionNameController: _extensionNameController,
            contactNumberController: _contactNumberController,
            dateOfBirthController: _dateOfBirthController,
            genderController: _genderController,
            shippingAddressController: _shippingAddressController,
            emailController: _emailController,
          ),
          const SizedBox(height: 14),
          AuthTextField(
            controller: _passwordController,
            hintText: 'Password',
            showPasswordToggle: true,
            textInputAction: TextInputAction.next,
            autofillHints: const [AutofillHints.newPassword],
          ),
          AuthPasswordRequirements(controller: _passwordController),
          const SizedBox(height: 14),
          AuthTextField(
            controller: _confirmPasswordController,
            hintText: 'Confirm Password',
            showPasswordToggle: true,
            textInputAction: TextInputAction.done,
            autofillHints: const [AutofillHints.newPassword],
          ),
          const SizedBox(height: 18),
          AuthPolicyCheckbox(
            value: _agreesToPolicy,
            onChanged: (value) => setState(() => _agreesToPolicy = value),
          ),
          const SizedBox(height: 20),
          AuthPrimaryButton(label: 'Sign up', onPressed: _signUp),
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
          const Spacer(),
          AuthBottomLink(
            label: 'Already have an account?',
            action: 'Log in',
            onTap: () {
              Navigator.of(context).pushReplacement(
                agrisellPageRoute<void>(builder: (_) => const LoginScreen()),
              );
            },
          ),
        ],
      ),
    );
  }

  Future<void> _signUp() async {
    if (_isSubmitting) {
      return;
    }
    if (widget.role == AuthRole.rider) {
      Navigator.of(context).pushReplacement(
        agrisellPageRoute<void>(builder: (_) => const RiderSignUpScreen()),
      );
      return;
    }
    final validationMessage = SignUpValidator.validate(
      firstName: _firstNameController.text.trim(),
      lastName: _lastNameController.text.trim(),
      contactNumber: _contactNumberController.text.trim(),
      dateOfBirth: _dateOfBirthController.text.trim(),
      gender: _genderController.text.trim(),
      shippingAddress: _shippingAddressController.text.trim(),
      email: _emailController.text.trim(),
      password: _passwordController.text,
      confirmPassword: _confirmPasswordController.text,
      agreesToPolicy: _agreesToPolicy,
    );
    if (validationMessage != null) {
      _showMessage(validationMessage);
      return;
    }
    final signUpData = SignUpAccountData(
      firstName: _firstNameController.text.trim(),
      lastName: _lastNameController.text.trim(),
      extensionName: _extensionNameController.text.trim(),
      phoneNumber: PhilippinePhoneNumber.normalize(
        _contactNumberController.text,
      ),
      dateOfBirth: _dateOfBirthController.text.trim(),
      gender: _genderController.text.trim(),
      shippingAddress: _shippingAddressController.text.trim(),
      email: _emailController.text.trim(),
      password: _passwordController.text,
    );
    setState(() => _isSubmitting = true);

    try {
      final account = await AuthRegistrationService.instance.register(
        signUpData,
        widget.role,
      );
      await AuthSessionService.instance.start(account, rememberMe: false);
      if (!mounted) {
        return;
      }
      Navigator.of(context).pushReplacement(
        agrisellPageRoute<void>(
          builder: (_) => AuthDashboardRouter.destinationFor(account),
        ),
      );
    } on AuthRegistrationException catch (error) {
      _showMessage(error.message);
    } catch (_) {
      _showMessage('Account creation failed. Please try again.');
    } finally {
      if (mounted) {
        setState(() => _isSubmitting = false);
      }
    }
  }

  void _showMessage(String message) {
    final messenger = ScaffoldMessenger.of(context);
    messenger.clearSnackBars();
    messenger.showAppSnackBar(SnackBar(content: Text(message)));
  }
}
