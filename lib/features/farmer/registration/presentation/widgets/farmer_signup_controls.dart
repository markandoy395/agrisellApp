import 'package:flutter/material.dart';

import 'package:agresell_app/core/theme/agrisell_colors.dart';
import 'package:agresell_app/features/auth/presentation/widgets/auth_button.dart';
import 'package:agresell_app/features/farmer/registration/presentation/styles/farmer_sign_up_styles.dart';

class FarmerSignupControls extends StatelessWidget {
  const FarmerSignupControls({
    required this.step,
    required this.isSubmitting,
    required this.onPrevious,
    required this.onNext,
    required this.onLogin,
    super.key,
  });

  final int step;
  final bool isSubmitting;
  final VoidCallback onPrevious;
  final VoidCallback onNext;
  final VoidCallback onLogin;

  @override
  Widget build(BuildContext context) => Column(
    children: [
      Row(
        children: [
          if (step > 0)
            Expanded(
              flex: step == 1 ? 3 : 1,
              child: OutlinedButton.icon(
                onPressed: isSubmitting ? null : onPrevious,
                style: FarmerSignUpStyles.backButtonStyle(step),
                icon: const Icon(Icons.arrow_back_rounded),
                label: const Text('Back'),
              ),
            ),
          if (step > 0) const SizedBox(width: 10),
          Expanded(
            flex: step == 1
                ? 5
                : step > 0
                ? 2
                : 1,
            child: AuthPrimaryButton(
              label: step == 2 ? 'Submit registration' : 'Continue',
              loginStyle: step < 2,
              isLoading: isSubmitting,
              borderRadius: 14,
              hasShadow: true,
              fontSize: 15,
              onPressed: isSubmitting ? null : onNext,
            ),
          ),
        ],
      ),
      const SizedBox(height: 16),
      const Row(
        children: [
          Expanded(child: Divider(color: AgrisellColors.borderLine)),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 14),
            child: Text('OR', style: FarmerSignUpStyles.orDividerTextStyle),
          ),
          Expanded(child: Divider(color: AgrisellColors.borderLine)),
        ],
      ),
      const SizedBox(height: 4),
      Wrap(
        crossAxisAlignment: WrapCrossAlignment.center,
        alignment: WrapAlignment.center,
        spacing: 5,
        children: [
          const Text(
            'Already have an account?',
            style: FarmerSignUpStyles.alreadyAccountStyle,
          ),
          TextButton(
            onPressed: isSubmitting ? null : onLogin,
            style: FarmerSignUpStyles.loginButtonStyle,
            child: const Text('Log in'),
          ),
        ],
      ),
    ],
  );
}
