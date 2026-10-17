import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';

import 'package:agresell_app/features/auth/presentation/styles/forgot_password_styles.dart';
import 'package:agresell_app/features/auth/presentation/widgets/auth_button.dart';
import 'package:agresell_app/features/auth/presentation/widgets/auth_password_requirements.dart';
import 'package:agresell_app/features/auth/presentation/widgets/auth_text_field.dart';

class ForgotPasswordResetStep extends StatelessWidget {
  const ForgotPasswordResetStep({
    required this.passwordController,
    required this.confirmationController,
    required this.confirmationError,
    required this.loading,
    required this.onPasswordChanged,
    required this.onConfirmationChanged,
    required this.onUpdatePassword,
    required this.onBackToLogin,
    super.key,
  });

  final TextEditingController passwordController;
  final TextEditingController confirmationController;
  final ValueListenable<String?> confirmationError;
  final bool loading;
  final ValueChanged<String> onPasswordChanged;
  final ValueChanged<String> onConfirmationChanged;
  final VoidCallback onUpdatePassword;
  final VoidCallback onBackToLogin;

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.stretch,
    children: [
      const SizedBox(
        width: double.infinity,
        child: Text(
          'Your email is verified. Choose a new password for your account.',
          textAlign: TextAlign.center,
          style: ForgotPasswordStyles.promptTextStyle,
        ),
      ),
      const SizedBox(height: 24),
      AuthTextField(
        controller: passwordController,
        hintText: 'New password',
        leadingIcon: Icons.lock_outline,
        showPasswordToggle: true,
        autofillHints: const [AutofillHints.newPassword],
        onChanged: onPasswordChanged,
      ),
      AuthPasswordRequirements(
        controller: passwordController,
        alwaysShow: true,
      ),
      const SizedBox(height: 14),
      AuthTextField(
        controller: confirmationController,
        hintText: 'Confirm new password',
        leadingIcon: Icons.lock_outline,
        showPasswordToggle: true,
        autofillHints: const [AutofillHints.newPassword],
        onChanged: onConfirmationChanged,
      ),
      ValueListenableBuilder<String?>(
        valueListenable: confirmationError,
        builder: (context, error, _) => Padding(
          padding: const EdgeInsets.only(top: 6, left: 12),
          child: Text(error ?? ' ', style: ForgotPasswordStyles.errorTextStyle),
        ),
      ),
      const SizedBox(height: 20),
      AuthPrimaryButton(
        label: 'Update password',
        isLoading: loading,
        borderRadius: 14,
        hasShadow: true,
        fontSize: 15,
        onPressed: loading ? null : onUpdatePassword,
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
