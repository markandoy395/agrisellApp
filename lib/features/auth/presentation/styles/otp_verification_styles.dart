import 'package:flutter/material.dart';
import 'package:agresell_app/core/theme/app_typography.dart';

import 'package:agresell_app/core/theme/agrisell_colors.dart';
import 'package:agresell_app/features/auth/presentation/styles/otp_verification_code_styles.dart';
import 'package:agresell_app/features/auth/presentation/styles/otp_verification_sheet_styles.dart';

export 'package:agresell_app/features/auth/presentation/styles/otp_verification_code_styles.dart';
export 'package:agresell_app/features/auth/presentation/styles/otp_verification_sheet_styles.dart';

/// Visual definitions shared by the OTP prompt and its help sheets.
abstract final class OtpVerificationStyles {
  // Delegated Code Styles
  static const codeSeparatorPadding =
      OtpVerificationCodeStyles.codeSeparatorPadding;
  static const codeSeparatorText = OtpVerificationCodeStyles.codeSeparatorText;
  static const hiddenCodeInput = OtpVerificationCodeStyles.hiddenCodeInput;
  static BoxDecoration codeGroupDecoration(
    Color borderColor,
    bool hasCurrentInGroup,
  ) => OtpVerificationCodeStyles.codeGroupDecoration(
    borderColor,
    hasCurrentInGroup,
  );
  static BoxDecoration cursorDecoration(Color accentColor) =>
      OtpVerificationCodeStyles.cursorDecoration(accentColor);
  static const digitText = OtpVerificationCodeStyles.digitText;
  static BorderRadius get resendRadius =>
      OtpVerificationCodeStyles.resendRadius;
  static const resendPadding = OtpVerificationCodeStyles.resendPadding;
  static BoxDecoration resendDecoration(Color accentColor, bool isEnabled) =>
      OtpVerificationCodeStyles.resendDecoration(accentColor, isEnabled);
  static TextStyle resendText(Color accentColor, bool isEnabled) =>
      OtpVerificationCodeStyles.resendText(accentColor, isEnabled);

  // Delegated Sheet Styles
  static const sheetShape = OtpVerificationSheetStyles.sheetShape;
  static const sheetPadding = OtpVerificationSheetStyles.sheetPadding;
  static BoxDecoration get sheetHandleDecoration =>
      OtpVerificationSheetStyles.sheetHandleDecoration;
  static const sheetTitle = OtpVerificationSheetStyles.sheetTitle;
  static const sheetBody = OtpVerificationSheetStyles.sheetBody;
  static ButtonStyle get closeButton => OtpVerificationSheetStyles.closeButton;
  static const boldButtonText = OtpVerificationSheetStyles.boldButtonText;
  static ButtonStyle get backButton => OtpVerificationSheetStyles.backButton;
  static const backButtonText = OtpVerificationSheetStyles.backButtonText;
  static ButtonStyle supportButton(Color accentColor) =>
      OtpVerificationSheetStyles.supportButton(accentColor);
  static const supportTilePadding =
      OtpVerificationSheetStyles.supportTilePadding;
  static BoxDecoration get supportTileDecoration =>
      OtpVerificationSheetStyles.supportTileDecoration;
  static const supportTileTitle = OtpVerificationSheetStyles.supportTileTitle;
  static const supportTileDetail = OtpVerificationSheetStyles.supportTileDetail;

  static const backIconPadding = EdgeInsets.only(left: 12);
  static const pagePadding = EdgeInsets.symmetric(horizontal: 16, vertical: 16);
  static const cardConstraints = BoxConstraints(maxWidth: 420);
  static const cardPadding = EdgeInsets.fromLTRB(22, 28, 22, 24);

  static final cardDecoration = BoxDecoration(
    color: Colors.white,
    borderRadius: BorderRadius.circular(20),
    border: Border.all(color: AgrisellColors.borderLine, width: 1.2),
    boxShadow: [
      BoxShadow(
        color: Colors.black.withValues(alpha: 0.05),
        blurRadius: 20,
        offset: const Offset(0, 6),
      ),
    ],
  );

  static const title = TextStyle(
    color: AgrisellColors.headingGreen,
    fontSize: 15,
    fontWeight: FontWeight.w800,
    letterSpacing: -0.3,
  );

  static const description = TextStyle(
    fontFamily: AppTypography.fontFamily,
    color: AgrisellColors.mutedText,
    fontSize: 14,
    height: 1.45,
  );

  static const destination = TextStyle(
    fontFamily: AppTypography.fontFamily,
    color: AgrisellColors.headingGreen,
    fontWeight: FontWeight.w700,
  );

  static const codeLabel = TextStyle(
    color: AgrisellColors.headingGreen,
    fontSize: 14,
    fontWeight: FontWeight.w700,
  );

  static final changeDestination = TextStyle(
    color: AgrisellColors.mutedText.withValues(alpha: 0.9),
    fontSize: 13,
    decoration: TextDecoration.underline,
    decorationColor: AgrisellColors.mutedText.withValues(alpha: 0.9),
  );

  static const feedbackPadding = EdgeInsets.symmetric(
    horizontal: 12,
    vertical: 9,
  );

  static final errorDecoration = BoxDecoration(
    color: AgrisellColors.statusRedBackground,
    borderRadius: BorderRadius.circular(8),
    border: Border.all(
      color: AgrisellColors.statusRedText.withValues(alpha: 0.3),
    ),
  );

  static const errorText = TextStyle(
    color: AgrisellColors.statusRedText,
    fontSize: 12,
    fontWeight: FontWeight.w600,
  );

  static final successDecoration = BoxDecoration(
    color: AgrisellColors.statusGreenBackground,
    borderRadius: BorderRadius.circular(8),
    border: Border.all(color: AgrisellColors.authGreen.withValues(alpha: 0.3)),
  );

  static const successText = TextStyle(
    color: AgrisellColors.forestGreen,
    fontSize: 12,
    fontWeight: FontWeight.w600,
  );

  static ButtonStyle verifyButton(Color accentColor) => FilledButton.styleFrom(
    backgroundColor: accentColor,
    foregroundColor: Colors.white,
    disabledBackgroundColor: accentColor.withValues(alpha: 0.35),
    disabledForegroundColor: Colors.white70,
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
    elevation: 0,
  );

  static const verifyText = TextStyle(
    fontSize: 15,
    fontWeight: FontWeight.w700,
    letterSpacing: 0.2,
  );

  static const supportPrompt = TextStyle(
    color: AgrisellColors.mutedText,
    fontSize: 13,
  );

  static const supportLink = TextStyle(
    color: AgrisellColors.headingGreen,
    fontSize: 13,
    fontWeight: FontWeight.w700,
    decoration: TextDecoration.underline,
    decorationColor: AgrisellColors.headingGreen,
  );
}
