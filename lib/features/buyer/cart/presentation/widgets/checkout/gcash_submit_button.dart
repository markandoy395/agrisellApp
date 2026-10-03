part of 'package:agresell_app/features/buyer/cart/presentation/screens/checkout_screen.dart';

class _GcashSubmitButton extends StatelessWidget {
  const _GcashSubmitButton({required this.onPressed});

  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: GcashPaymentSheetStyles.submitButtonHeight,
      child: FilledButton.icon(
        key: const ValueKey('use-gcash-button'),
        onPressed: onPressed,
        style: GcashPaymentSheetStyles.submitButtonStyle,
        icon: const Icon(
          Icons.verified_user_outlined,
          size: GcashPaymentSheetStyles.submitIconSize,
        ),
        label: const Text(
          'Submit reference for verification',
          style: GcashPaymentSheetStyles.submitButtonTextStyle,
        ),
      ),
    );
  }
}
