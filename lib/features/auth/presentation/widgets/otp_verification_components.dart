import 'package:flutter/material.dart';

import 'package:agresell_app/features/auth/presentation/styles/otp_verification_styles.dart';
import 'package:agresell_app/features/auth/presentation/widgets/otp_help_sheets.dart';

class OtpDestinationHeader extends StatelessWidget {
  const OtpDestinationHeader({
    required this.title,
    required this.destination,
    super.key,
  });

  final String title;
  final String destination;

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.stretch,
    children: [
      Text(title, style: OtpVerificationStyles.title),
      const SizedBox(height: 10),
      RichText(
        text: TextSpan(
          style: OtpVerificationStyles.description,
          children: [
            const TextSpan(
              text: 'Enter the verification code we sent to your email address: ',
            ),
            TextSpan(
              text: destination,
              style: OtpVerificationStyles.destination,
            ),
            const TextSpan(text: '.'),
          ],
        ),
      ),
    ],
  );
}

class OtpChangeDestinationAction extends StatelessWidget {
  const OtpChangeDestinationAction({
    required this.destination,
    required this.accentColor,
    required this.isDisabled,
    this.changeDestinationLabel,
    this.onChangeDestination,
    super.key,
  });

  final String destination;
  final Color accentColor;
  final bool isDisabled;
  final String? changeDestinationLabel;
  final VoidCallback? onChangeDestination;

  @override
  Widget build(BuildContext context) => Align(
    alignment: Alignment.centerLeft,
    child: GestureDetector(
      onTap: isDisabled
          ? null
          : () {
              if (onChangeDestination != null) {
                onChangeDestination!();
                Navigator.of(context).pop(false);
              } else {
                showOtpNoAccessSheet(
                  context,
                  destination: destination,
                  accentColor: accentColor,
                );
              }
            },
      child: Text(
        changeDestinationLabel ??
            'I no longer have access to this email address.',
        style: OtpVerificationStyles.changeDestination,
      ),
    ),
  );
}

class OtpTroubleFooter extends StatelessWidget {
  const OtpTroubleFooter({super.key});

  @override
  Widget build(BuildContext context) => Center(
    child: Wrap(
      alignment: WrapAlignment.center,
      crossAxisAlignment: WrapCrossAlignment.center,
      children: [
        const Text(
          'Having trouble signing in? ',
          style: OtpVerificationStyles.supportPrompt,
        ),
        GestureDetector(
          onTap: () => showOtpSupportSheet(context),
          child: const Text(
            'Contact support',
            style: OtpVerificationStyles.supportLink,
          ),
        ),
      ],
    ),
  );
}
