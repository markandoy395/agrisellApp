import 'package:flutter/material.dart';

import 'package:agresell_app/core/theme/agrisell_colors.dart';
import 'package:agresell_app/features/auth/presentation/controllers/otp_verification_controller.dart';
import 'package:agresell_app/features/auth/presentation/styles/otp_verification_styles.dart';
import 'package:agresell_app/features/auth/presentation/widgets/otp_code_boxes.dart';
import 'package:agresell_app/features/auth/presentation/widgets/otp_feedback_banner.dart';
import 'package:agresell_app/features/auth/presentation/widgets/otp_resend_button.dart';
import 'package:agresell_app/features/auth/presentation/widgets/otp_verification_components.dart';

class OtpVerificationView extends StatelessWidget {
  const OtpVerificationView({
    required this.destination,
    required this.title,
    required this.codeLength,
    required this.maxIncorrectAttempts,
    required this.accentColor,
    required this.changeDestinationLabel,
    required this.onChangeDestination,
    required this.controller,
    required this.onVerify,
    required this.onResend,
    super.key,
  });

  final String destination;
  final String title;
  final int codeLength;
  final int maxIncorrectAttempts;
  final Color accentColor;
  final String? changeDestinationLabel;
  final VoidCallback? onChangeDestination;
  final OtpVerificationController controller;
  final VoidCallback onVerify;
  final VoidCallback? onResend;

  @override
  Widget build(BuildContext context) {
    final code = controller.code.text;

    return Scaffold(
      backgroundColor: AgrisellColors.authBackground,
      appBar: AppBar(
        backgroundColor: AgrisellColors.authBackground,
        elevation: 0,
        surfaceTintColor: AgrisellColors.authBackground,
        leading: Padding(
          padding: OtpVerificationStyles.backIconPadding,
          child: Center(
            child: Material(
              color: AgrisellColors.forestSoft,
              shape: const CircleBorder(),
              child: IconButton(
                tooltip: 'Back',
                color: AgrisellColors.forestGreen,
                onPressed: controller.isVerifying
                    ? null
                    : () => Navigator.of(context).pop(false),
                icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 17),
              ),
            ),
          ),
        ),
      ),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: OtpVerificationStyles.pagePadding,
            child: ConstrainedBox(
              constraints: OtpVerificationStyles.cardConstraints,
              child: Container(
                padding: OtpVerificationStyles.cardPadding,
                decoration: OtpVerificationStyles.cardDecoration,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    OtpDestinationHeader(
                      title: title,
                      destination: destination,
                    ),
                    const SizedBox(height: 24),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        const Expanded(
                          child: Text(
                            'Verification code',
                            style: OtpVerificationStyles.codeLabel,
                          ),
                        ),
                        const SizedBox(width: 8),
                        OtpResendButton(
                          isResending: controller.isResending,
                          cooldownSeconds: controller.secondsRemaining,
                          accentColor: accentColor,
                          onPressed: onResend,
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    OtpCodeBoxes(
                      code: code,
                      length: codeLength,
                      accentColor: accentColor,
                      hasError: controller.error != null,
                      focusNode: controller.focusNode,
                      controller: controller.code,
                      onChanged: (_) => controller.clearFeedback(),
                    ),
                    const SizedBox(height: 14),
                    OtpChangeDestinationAction(
                      destination: destination,
                      accentColor: accentColor,
                      isDisabled:
                          controller.isVerifying || controller.isResending,
                      changeDestinationLabel: changeDestinationLabel,
                      onChangeDestination: onChangeDestination,
                    ),
                    if (controller.error != null) ...[
                      const SizedBox(height: 14),
                      OtpFeedbackBanner.error(controller.error!),
                    ],
                    if (controller.status != null) ...[
                      const SizedBox(height: 14),
                      OtpFeedbackBanner.success(controller.status!),
                    ],
                    const SizedBox(height: 22),
                    const Divider(
                      color: AgrisellColors.borderLine,
                      height: 1,
                      thickness: 1,
                    ),
                    const SizedBox(height: 22),
                    SizedBox(
                      height: 48,
                      child: FilledButton(
                        style: OtpVerificationStyles.verifyButton(accentColor),
                        onPressed:
                            controller.isVerifying ||
                                    controller.attemptsExhausted(
                                      maxIncorrectAttempts,
                                    )
                                ? null
                                : onVerify,
                        child: controller.isVerifying
                            ? const SizedBox(
                                height: 20,
                                width: 20,
                                child: CircularProgressIndicator(
                                  color: Colors.white,
                                  strokeWidth: 2.2,
                                ),
                              )
                            : const Text(
                                'Verify',
                                style: OtpVerificationStyles.verifyText,
                              ),
                      ),
                    ),
                    const SizedBox(height: 18),
                    const OtpTroubleFooter(),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
