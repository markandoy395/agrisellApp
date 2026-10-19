import 'package:agresell_app/core/theme/shared_presentation_styles.dart';
import 'package:agresell_app/features/farmer/registration/presentation/styles/farmer_registration_submitted_screen_styles.dart';
import 'package:flutter/material.dart';

import 'package:agresell_app/core/theme/agrisell_colors.dart';
import 'package:agresell_app/core/utils/agrisell_page_route.dart';
import 'package:agresell_app/features/auth/data/auth_session_service.dart';
import 'package:agresell_app/features/auth/presentation/screens/login_screen.dart';

class FarmerRegistrationSubmittedScreen extends StatelessWidget {
  const FarmerRegistrationSubmittedScreen({required this.reference, super.key});

  final String reference;

  @override
  Widget build(BuildContext context) => Scaffold(
    backgroundColor: AgrisellColors.homeBackground,
    body: SafeArea(
      child: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 520),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(
                  Icons.check_circle_rounded,
                  size: 68,
                  color: AgrisellColors.statusGreenText,
                ),
                const SizedBox(height: 14),
                const Text(
                  'Farmer registration submitted',
                  textAlign: TextAlign.center,
                  style: SharedPresentationStyles.headingTitleExtraBold,
                ),
                const SizedBox(height: 8),
                Text(
                  'Reference: $reference',
                  style: SharedPresentationStyles.caption,
                ),
                const SizedBox(height: 8),
                const Text(
                  'Your farm and identity details were submitted. Please wait for admin confirmation before selling products.',
                  textAlign: TextAlign.center,
                  style: FarmerRegistrationSubmittedScreenStyles.textStyle,
                ),
                const SizedBox(height: 22),
                SizedBox(
                  width: double.infinity,
                  height: 40,
                  child: FilledButton(
                    onPressed: () => _returnToLogin(context),
                    child: const Text('Return to login'),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    ),
  );

  Future<void> _returnToLogin(BuildContext context) async {
    await AuthSessionService.instance.clear();
    if (!context.mounted) return;
    Navigator.of(context).pushAndRemoveUntil(
      agrisellPageRoute<void>(builder: (_) => const LoginScreen()),
      (route) => false,
    );
  }
}
