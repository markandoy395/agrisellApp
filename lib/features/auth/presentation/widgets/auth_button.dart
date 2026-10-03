import 'package:agresell_app/features/auth/presentation/styles/auth_button_styles.dart';
import 'package:flutter/material.dart';

import 'package:agresell_app/core/utils/responsive.dart';

class AuthPrimaryButton extends StatelessWidget {
  const AuthPrimaryButton({
    required this.label,
    required this.onPressed,
    this.isLoading = false,
    this.loginStyle = false,
    this.borderRadius,
    this.hasShadow = false,
    this.fontSize,
    super.key,
  });

  final String label;
  final VoidCallback? onPressed;
  final bool isLoading;
  final bool loginStyle;
  final double? borderRadius;
  final bool hasShadow;
  final double? fontSize;

  @override
  Widget build(BuildContext context) {
    final scale = authScale(MediaQuery.sizeOf(context).width);
    final effectiveRadius = borderRadius ?? (loginStyle ? 14.0 : 8.0);

    final button = SizedBox(
      width: double.infinity,
      height: 50,
      child: FilledButton(
        onPressed: isLoading ? null : onPressed,
        style: AuthButtonStyles.filledButtonStyle(
          effectiveRadius,
          fontSize,
          scale,
        ),
        child: isLoading
            ? const SizedBox(
                width: 18,
                height: 18,
                child: CircularProgressIndicator(strokeWidth: 2),
              )
            : loginStyle
            ? Row(
                mainAxisAlignment: MainAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(label),
                  const SizedBox(width: 12),
                  const Icon(Icons.arrow_forward, size: 20),
                ],
              )
            : Text(label),
      ),
    );

    if (hasShadow) {
      return Container(
        decoration: AuthButtonStyles.containerDecoration(effectiveRadius),
        child: button,
      );
    }

    return button;
  }
}

class AuthOutlinedButton extends StatelessWidget {
  const AuthOutlinedButton({
    required this.label,
    required this.onPressed,
    super.key,
  });

  final String label;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    final scale = authScale(MediaQuery.sizeOf(context).width);

    return SizedBox(
      width: double.infinity,
      height: 50,
      child: OutlinedButton(
        onPressed: onPressed,
        style: AuthButtonStyles.outlinedButtonStyle(scale),
        child: Text(label),
      ),
    );
  }
}
