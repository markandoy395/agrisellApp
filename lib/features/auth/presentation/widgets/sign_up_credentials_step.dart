import 'package:flutter/material.dart';

import 'package:agresell_app/features/auth/presentation/controllers/sign_up_form_controllers.dart';
import 'package:agresell_app/features/auth/presentation/styles/sign_up_screen_styles.dart';
import 'package:agresell_app/features/auth/presentation/widgets/auth_button.dart';
import 'package:agresell_app/features/auth/presentation/widgets/auth_password_requirements.dart';
import 'package:agresell_app/features/auth/presentation/widgets/auth_text_field.dart';

class SignUpCredentialsStep extends StatelessWidget {
  const SignUpCredentialsStep({
    required this.form,
    required this.isSubmitting,
    required this.isCredentialsLocked,
    required this.isEmailVerified,
    required this.onContinue,
    super.key,
  });

  final SignUpFormControllers form;
  final bool isSubmitting;
  final bool isCredentialsLocked;
  final bool isEmailVerified;
  final VoidCallback onContinue;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          SignUpScreenStyles.credentialsTitle,
          style: SignUpScreenStyles.sectionTitle,
        ),
        const SizedBox(height: SignUpScreenStyles.sectionHeaderGap),
        const Text(
          SignUpScreenStyles.credentialsSubtitle,
          style: SignUpScreenStyles.sectionSubtitle,
        ),
        const SizedBox(height: SignUpScreenStyles.headerToFieldsGap),
        AuthTextField(
          controller: form.email,
          hintText: 'Email',
          keyboardType: TextInputType.emailAddress,
          textInputAction: TextInputAction.next,
          autofillHints: const [AutofillHints.email],
          readOnly: isCredentialsLocked,
        ),
        const SizedBox(height: SignUpScreenStyles.fieldGap),
        AuthTextField(
          controller: form.password,
          hintText: 'Password',
          showPasswordToggle: true,
          textInputAction: TextInputAction.next,
          autofillHints: const [AutofillHints.newPassword],
          readOnly: isCredentialsLocked,
        ),
        if (!isEmailVerified)
          AuthPasswordRequirements(controller: form.password),
        const SizedBox(height: SignUpScreenStyles.fieldGap),
        AuthTextField(
          controller: form.confirmPassword,
          hintText: 'Confirm Password',
          showPasswordToggle: true,
          textInputAction: TextInputAction.done,
          autofillHints: const [AutofillHints.newPassword],
          readOnly: isCredentialsLocked,
        ),
        if (isCredentialsLocked) ...[
          const SizedBox(height: SignUpScreenStyles.lockedNoticeGap),
          Text(
            isEmailVerified
                ? SignUpScreenStyles.lockedCredentialsVerifiedNotice
                : SignUpScreenStyles.lockedCredentialsOtpNotice,
            style: SignUpScreenStyles.lockedNoticeText,
          ),
        ],
        const SizedBox(height: SignUpScreenStyles.sectionActionsGap),
        AuthPrimaryButton(
          label: 'Continue',
          isLoading: isSubmitting,
          onPressed: isSubmitting ? null : onContinue,
        ),
      ],
    );
  }
}
