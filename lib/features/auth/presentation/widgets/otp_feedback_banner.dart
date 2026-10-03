import 'package:flutter/material.dart';
import 'package:agresell_app/core/theme/agrisell_colors.dart';

import '../styles/otp_verification_styles.dart';

/// A shared layout with predefined success and error variants.
class OtpFeedbackBanner extends StatelessWidget {
  const OtpFeedbackBanner.error(this.message, {super.key}) : isError = true;
  const OtpFeedbackBanner.success(this.message, {super.key}) : isError = false;

  final String message;
  final bool isError;

  @override
  Widget build(BuildContext context) => Container(
    padding: OtpVerificationStyles.feedbackPadding,
    decoration: isError
        ? OtpVerificationStyles.errorDecoration
        : OtpVerificationStyles.successDecoration,
    child: Row(
      children: [
        Icon(
          isError
              ? Icons.error_outline_rounded
              : Icons.check_circle_outline_rounded,
          color: isError
              ? AgrisellColors.statusRedText
              : AgrisellColors.forestGreen,
          size: 16,
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            message,
            style: isError
                ? OtpVerificationStyles.errorText
                : OtpVerificationStyles.successText,
          ),
        ),
      ],
    ),
  );
}
