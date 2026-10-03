import 'package:flutter/material.dart';

abstract final class SignUpScreenStyles {
  // Gaps & Dimensions
  static const double progressBarHeight = 5.0;
  static const double stepLabelGap = 6.0;
  static const double stepGap = 16.0;
  static const double fieldGap = 14.0;
  static const double sectionHeaderGap = 6.0;
  static const double headerToFieldsGap = 12.0;
  static const double lockedNoticeGap = 8.0;
  static const double sectionActionsGap = 20.0;
  static const double socialDividerGap = 20.0;
  static const double socialButtonsGap = 12.0;
  static const double policyCheckboxGap = 18.0;
  static const double backButtonGap = 10.0;
  static const double bottomLinkGap = 20.0;

  // Text Styles
  static const TextStyle stepProgressText = TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.w600,
  );

  static const TextStyle sectionTitle = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w700,
  );

  static const TextStyle sectionSubtitle = TextStyle(
    fontSize: 12,
  );

  static const TextStyle lockedNoticeText = TextStyle(
    fontSize: 12,
  );

  // Content Strings
  static const String credentialsTitle = 'Account credentials';
  static const String credentialsSubtitle =
      'Verify your email before entering your personal information.';
  static const String personalInfoTitle = 'Personal information';
  static const String lockedCredentialsVerifiedNotice =
      'Email verified. These credentials are locked for this registration.';
  static const String lockedCredentialsOtpNotice =
      'OTP sent. Use Change email on the verification screen to edit these credentials.';
  static const String emailVerificationFailedNotice =
      'We could not verify your email. Please try again.';
  static const String accountCreationFailedNotice =
      'Account creation failed. Please try again.';

  // Component Builders
  static SnackBar snackBar(String message) => SnackBar(content: Text(message));
}
