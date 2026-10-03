import 'package:flutter/material.dart';

import 'package:agresell_app/features/auth/presentation/controllers/sign_up_form_controllers.dart';
import 'package:agresell_app/features/auth/presentation/styles/sign_up_screen_styles.dart';
import 'package:agresell_app/features/auth/presentation/widgets/auth_button.dart';
import 'package:agresell_app/features/auth/presentation/widgets/auth_checkbox.dart';
import 'package:agresell_app/features/auth/presentation/widgets/sign_up_identity_fields.dart';

class SignUpPersonalInfoStep extends StatelessWidget {
  const SignUpPersonalInfoStep({
    required this.form,
    required this.agreesToPolicy,
    required this.onAgreesToPolicyChanged,
    required this.isSubmitting,
    required this.onCompleteSignUp,
    required this.onBackToCredentials,
    super.key,
  });

  final SignUpFormControllers form;
  final bool agreesToPolicy;
  final ValueChanged<bool> onAgreesToPolicyChanged;
  final bool isSubmitting;
  final VoidCallback onCompleteSignUp;
  final VoidCallback onBackToCredentials;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          SignUpScreenStyles.personalInfoTitle,
          style: SignUpScreenStyles.sectionTitle,
        ),
        const SizedBox(height: SignUpScreenStyles.sectionHeaderGap),
        Text(
          'Verified email: ${form.email.text.trim().toLowerCase()}',
          style: SignUpScreenStyles.sectionSubtitle,
        ),
        const SizedBox(height: SignUpScreenStyles.headerToFieldsGap),
        SignUpIdentityFields(
          firstNameController: form.firstName,
          lastNameController: form.lastName,
          extensionNameController: form.extensionName,
          contactNumberController: form.contactNumber,
          dateOfBirthController: form.dateOfBirth,
          genderController: form.gender,
          shippingAddressController: form.shippingAddress,
          emailController: form.email,
          showEmail: false,
        ),
        const SizedBox(height: SignUpScreenStyles.policyCheckboxGap),
        AuthPolicyCheckbox(
          value: agreesToPolicy,
          onChanged: onAgreesToPolicyChanged,
        ),
        const SizedBox(height: SignUpScreenStyles.sectionActionsGap),
        AuthPrimaryButton(
          label: 'Sign up',
          isLoading: isSubmitting,
          onPressed: isSubmitting ? null : onCompleteSignUp,
        ),
        const SizedBox(height: SignUpScreenStyles.backButtonGap),
        AuthOutlinedButton(
          label: 'Back to credentials',
          onPressed: isSubmitting ? null : onBackToCredentials,
        ),
      ],
    );
  }
}
