import 'package:flutter/material.dart';

import '../styles/otp_verification_styles.dart';

/// Common handle, heading, description, and content layout for OTP help.
class OtpHelpSheetLayout extends StatelessWidget {
  const OtpHelpSheetLayout({
    required this.title,
    required this.description,
    required this.children,
    super.key,
  });

  final String title;
  final String description;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) => SafeArea(
    child: Padding(
      padding: OtpVerificationStyles.sheetPadding,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Center(
            child: Container(
              width: 40,
              height: 4,
              decoration: OtpVerificationStyles.sheetHandleDecoration,
            ),
          ),
          const SizedBox(height: 18),
          Text(title, style: OtpVerificationStyles.sheetTitle),
          const SizedBox(height: 8),
          Text(description, style: OtpVerificationStyles.sheetBody),
          ...children,
        ],
      ),
    ),
  );
}
