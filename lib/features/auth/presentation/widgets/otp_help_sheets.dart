import 'package:flutter/material.dart';
import 'package:agresell_app/core/theme/agrisell_colors.dart';
import '../styles/otp_verification_styles.dart';
import 'otp_help_sheet_layout.dart';

void showOtpSupportSheet(BuildContext context) {
  showModalBottomSheet<void>(
    context: context,
    backgroundColor: Colors.white,
    shape: OtpVerificationStyles.sheetShape,
    builder: (ctx) => OtpHelpSheetLayout(
      title: 'Need Help Signing In?',
      description:
          'If you are having trouble receiving or entering your verification code, our support team is here to assist.',
      children: [
        const SizedBox(height: 18),
        _supportTile(
          icon: Icons.email_outlined,
          title: 'Email Support',
          detail: 'support@agrisell.com',
        ),
        const SizedBox(height: 10),
        _supportTile(
          icon: Icons.phone_outlined,
          title: 'Support Hotline',
          detail: '+63 900 123 4567 (Mon-Fri 8AM-5PM)',
        ),
        const SizedBox(height: 20),
        SizedBox(
          height: 44,
          child: FilledButton(
            style: OtpVerificationStyles.closeButton,
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text(
              'Close',
              style: OtpVerificationStyles.boldButtonText,
            ),
          ),
        ),
      ],
    ),
  );
}

void showOtpNoAccessSheet(
  BuildContext context, {
  required String destination,
  required Color accentColor,
}) {
  showModalBottomSheet<void>(
    context: context,
    backgroundColor: Colors.white,
    shape: OtpVerificationStyles.sheetShape,
    builder: (ctx) => OtpHelpSheetLayout(
      title: 'Lost Access to Your Email?',
      description:
          'If you can no longer access $destination, please contact Agrisell support or go back to register with another email.',
      children: [
        const SizedBox(height: 20),
        Row(
          children: [
            Expanded(
              child: SizedBox(
                height: 44,
                child: OutlinedButton(
                  style: OtpVerificationStyles.backButton,
                  onPressed: () {
                    Navigator.of(ctx).pop();
                    Navigator.of(context).pop(false);
                  },
                  child: const Text(
                    'Go back',
                    style: OtpVerificationStyles.backButtonText,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: SizedBox(
                height: 44,
                child: FilledButton(
                  style: OtpVerificationStyles.supportButton(accentColor),
                  onPressed: () {
                    Navigator.of(ctx).pop();
                    showOtpSupportSheet(context);
                  },
                  child: const Text(
                    'Contact support',
                    style: OtpVerificationStyles.boldButtonText,
                  ),
                ),
              ),
            ),
          ],
        ),
      ],
    ),
  );
}

Widget _supportTile({
  required IconData icon,
  required String title,
  required String detail,
}) {
  return Container(
    padding: OtpVerificationStyles.supportTilePadding,
    decoration: OtpVerificationStyles.supportTileDecoration,
    child: Row(
      children: [
        Icon(icon, color: AgrisellColors.forestGreen, size: 20),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: OtpVerificationStyles.supportTileTitle),
              const SizedBox(height: 2),
              Text(detail, style: OtpVerificationStyles.supportTileDetail),
            ],
          ),
        ),
      ],
    ),
  );
}
