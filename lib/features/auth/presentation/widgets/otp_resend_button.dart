import 'package:flutter/material.dart';
import 'package:agresell_app/core/theme/agrisell_colors.dart';
import '../styles/otp_verification_styles.dart';

class OtpResendButton extends StatelessWidget {
  const OtpResendButton({
    required this.isResending,
    required this.cooldownSeconds,
    required this.accentColor,
    required this.onPressed,
  });

  final bool isResending;
  final int cooldownSeconds;
  final Color accentColor;
  final VoidCallback? onPressed;

  String _clockText(int seconds) =>
      '${(seconds ~/ 60).toString().padLeft(2, '0')}:${(seconds % 60).toString().padLeft(2, '0')}';

  @override
  Widget build(BuildContext context) {
    final isEnabled = onPressed != null && !isResending;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onPressed,
        borderRadius: OtpVerificationStyles.resendRadius,
        child: Container(
          padding: OtpVerificationStyles.resendPadding,
          decoration: OtpVerificationStyles.resendDecoration(
            accentColor,
            isEnabled,
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (isResending)
                SizedBox(
                  width: 13,
                  height: 13,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: accentColor,
                  ),
                )
              else
                Icon(
                  Icons.sync_rounded,
                  size: 14,
                  color: isEnabled ? accentColor : AgrisellColors.mutedText,
                ),
              const SizedBox(width: 5),
              Text(
                cooldownSeconds == 0
                    ? 'Resend code'
                    : 'Resend in ${_clockText(cooldownSeconds)}',
                style: OtpVerificationStyles.resendText(accentColor, isEnabled),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
