import 'package:flutter/material.dart';

import 'package:agresell_app/features/auth/presentation/widgets/auth_bottom_link.dart';
import 'package:agresell_app/features/auth/presentation/widgets/auth_button.dart';
import 'package:agresell_app/features/auth/presentation/widgets/auth_checkbox.dart';
import 'package:agresell_app/features/auth/presentation/widgets/auth_text_field.dart';

class LoginForm extends StatelessWidget {
  const LoginForm({
    required this.identifierController,
    required this.passwordController,
    required this.rememberMe,
    required this.isLoggingIn,
    required this.onRememberChanged,
    required this.onLogIn,
    required this.onForgotPassword,
    required this.onCreateAccount,
    super.key,
  });

  final TextEditingController identifierController;
  final TextEditingController passwordController;
  final bool rememberMe;
  final bool isLoggingIn;
  final ValueChanged<bool> onRememberChanged;
  final VoidCallback? onLogIn;
  final VoidCallback onForgotPassword;
  final VoidCallback onCreateAccount;

  @override
  Widget build(BuildContext context) {
    return AutofillGroup(
      onDisposeAction: AutofillContextAction.cancel,
      child: Column(
        children: [
          AuthTextField(
            hintText: 'Email or phone number',
            controller: identifierController,
            keyboardType: TextInputType.emailAddress,
            autofillHints: const [AutofillHints.username],
          ),
          const SizedBox(height: 14),
          AuthTextField(
            hintText: 'Password',
            controller: passwordController,
            showPasswordToggle: true,
            autofillHints: const [AutofillHints.password],
          ),
          const SizedBox(height: 10),
          AuthCheckbox(
            label: 'Remember me',
            value: rememberMe,
            onChanged: onRememberChanged,
          ),
          Align(
            alignment: Alignment.centerRight,
            child: TextButton(
              onPressed: onForgotPassword,
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
            onPressed: onLogIn,
            isLoading: isLoggingIn,
          ),
          const SizedBox(height: 24),
          const Spacer(),
          AuthBottomLink(
            label: "Don't have an account?",
            action: 'Create account',
            onTap: onCreateAccount,
          ),
          const SizedBox(height: 8),
        ],
      ),
    );
  }
}
