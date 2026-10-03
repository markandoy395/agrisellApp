import 'package:flutter/material.dart';

import 'package:agresell_app/features/auth/presentation/styles/forgot_password_styles.dart';
import 'package:agresell_app/features/auth/presentation/widgets/auth_button.dart';
import 'package:agresell_app/features/auth/presentation/widgets/auth_text_field.dart';

class ForgotPasswordRequestStep extends StatelessWidget {
  const ForgotPasswordRequestStep({
    required this.emailController,
    required this.loading,
    required this.onSendCode,
    required this.onBackToLogin,
    super.key,
  });

  final TextEditingController emailController;
  final bool loading;
  final VoidCallback onSendCode;
  final VoidCallback onBackToLogin;

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.stretch,
    children: [
      const SizedBox(
        width: double.infinity,
        child: Text(
          'Enter your email address and we will send a password-reset code.',
          textAlign: TextAlign.center,
          style: ForgotPasswordStyles.promptTextStyle,
        ),
      ),
      const SizedBox(height: 24),
      AuthTextField(
        controller: emailController,
        hintText: 'Email address',
        leadingIcon: Icons.mail_outline,
        keyboardType: TextInputType.emailAddress,
        autofillHints: const [AutofillHints.email],
      ),
      const SizedBox(height: 18),
      AuthPrimaryButton(
        label: 'Send code',
        isLoading: loading,
        borderRadius: 14,
        hasShadow: true,
        fontSize: 15,
        onPressed: loading ? null : onSendCode,
      ),
      const SizedBox(height: 14),
      Center(
        child: TextButton(
          onPressed: onBackToLogin,
          style: ForgotPasswordStyles.backToLoginButtonStyle,
          child: const Text('Back to login'),
        ),
      ),
    ],
  );
}
