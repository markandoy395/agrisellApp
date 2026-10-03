import 'package:flutter/material.dart';

import 'package:agresell_app/core/theme/agrisell_colors.dart';
import 'package:agresell_app/core/utils/agrisell_page_route.dart';
import 'package:agresell_app/features/rider/profile/presentation/screens/rider_application_status_screen.dart';
import 'package:agresell_app/features/rider/profile/presentation/styles/rider_application_submitted_styles.dart';

export 'rider_application_status_screen.dart';

class RiderApplicationSubmittedScreen extends StatelessWidget {
  const RiderApplicationSubmittedScreen({required this.reference, super.key});
  final String reference;

  @override
  Widget build(BuildContext context) => Scaffold(
    backgroundColor: AgrisellColors.homeBackground,
    body: SafeArea(
      child: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
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
                'Rider application submitted',
                textAlign: TextAlign.center,
                style: RiderApplicationSubmittedStyles.headingStyle,
              ),
              const SizedBox(height: 8),
              Text(
                'Reference: $reference',
                style: RiderApplicationSubmittedStyles.referenceStyle,
              ),
              const SizedBox(height: 8),
              const _PendingMessage(),
              const SizedBox(height: 22),
              SizedBox.fromSize(
                size: RiderApplicationSubmittedStyles.buttonSize,
                child: FilledButton(
                  onPressed: () => Navigator.of(context).push(
                    agrisellPageRoute<void>(
                      builder: (_) =>
                          RiderApplicationStatusScreen(reference: reference),
                    ),
                  ),
                  child: const Text('View application status'),
                ),
              ),
              const SizedBox(height: 10),
              SizedBox.fromSize(
                size: RiderApplicationSubmittedStyles.buttonSize,
                child: OutlinedButton(
                  onPressed: () => returnToLoginAfterApplication(context),
                  child: const Text('Return to login'),
                ),
              ),
            ],
          ),
        ),
      ),
    ),
  );
}

class _PendingMessage extends StatelessWidget {
  const _PendingMessage();

  @override
  Widget build(BuildContext context) => const Text(
    'Your information and documents will be reviewed before your account is activated. We will notify you when its status changes.',
    textAlign: TextAlign.center,
    style: RiderApplicationSubmittedStyles.mutedBodyStyle,
  );
}
