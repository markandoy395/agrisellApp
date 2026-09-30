import 'package:flutter/material.dart';

import 'package:agresell_app/core/theme/agrisell_colors.dart';
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
    final rememberCheckbox = AuthCheckbox(
      label: 'Remember me',
      value: rememberMe,
      compact: true,
      onChanged: onRememberChanged,
    );
    final forgotButton = TextButton(
      onPressed: onForgotPassword,
      style: TextButton.styleFrom(
        foregroundColor: AgrisellColors.authGreen,
        minimumSize: const Size(0, 40),
        padding: EdgeInsets.zero,
        textStyle: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
      ),
      child: const Text('Forgot password?'),
    );
    return AutofillGroup(
      onDisposeAction: AutofillContextAction.cancel,
      child: Column(
        children: [
          AuthTextField(
            hintText: 'Email or phone number',
            leadingIcon: Icons.person_outline,
            controller: identifierController,
            keyboardType: TextInputType.emailAddress,
            autofillHints: const [AutofillHints.username],
          ),
          const SizedBox(height: 14),
          AuthTextField(
            hintText: 'Password',
            leadingIcon: Icons.lock_outline,
            controller: passwordController,
            showPasswordToggle: true,
            autofillHints: const [AutofillHints.password],
          ),
          const SizedBox(height: 12),
          LayoutBuilder(
            builder: (context, constraints) => constraints.maxWidth < 300
                ? Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      rememberCheckbox,
                      Align(
                        alignment: Alignment.centerRight,
                        child: forgotButton,
                      ),
                    ],
                  )
                : Row(
                    children: [
                      Flexible(child: rememberCheckbox),
                      const SizedBox(width: 8),
                      forgotButton,
                    ],
                  ),
          ),
          const SizedBox(height: 14),
          AuthPrimaryButton(
            label: 'Log In',
            loginStyle: true,
            onPressed: onLogIn,
            isLoading: isLoggingIn,
          ),
          const SizedBox(height: 22),
          const Row(
            children: [
              Expanded(child: Divider(color: AgrisellColors.borderLine)),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 12),
                child: Text(
                  'OR',
                  style: TextStyle(
                    color: AgrisellColors.mutedText,
                    fontSize: 12,
                  ),
                ),
              ),
              Expanded(child: Divider(color: AgrisellColors.borderLine)),
            ],
          ),
          const SizedBox(height: 12),
          Center(
            child: Wrap(
              crossAxisAlignment: WrapCrossAlignment.center,
              alignment: WrapAlignment.center,
              spacing: 5,
              children: [
                const Text(
                  "Don't have an account?",
                  style: TextStyle(fontSize: 13),
                ),
                TextButton(
                  onPressed: onCreateAccount,
                  style: TextButton.styleFrom(
                    foregroundColor: AgrisellColors.authGreen,
                    padding: EdgeInsets.zero,
                    minimumSize: const Size(0, 40),
                    textStyle: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  child: const Text('Create account'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
