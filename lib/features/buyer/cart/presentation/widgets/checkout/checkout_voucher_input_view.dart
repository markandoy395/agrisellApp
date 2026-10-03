part of 'package:agresell_app/features/buyer/cart/presentation/screens/checkout_screen.dart';

class _VoucherInputView extends StatelessWidget {
  const _VoucherInputView({
    required this.controller,
    required this.isValidating,
    required this.errorMessage,
    required this.onApply,
  });

  final TextEditingController controller;
  final bool isValidating;
  final String? errorMessage;
  final VoidCallback onApply;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: SizedBox(
                height: CheckoutVoucherStyles.inputRowHeight,
                child: TextField(
                  controller: controller,
                  textCapitalization: TextCapitalization.characters,
                  style: CheckoutVoucherStyles.inputTextStyle,
                  decoration: CheckoutVoucherStyles.inputDecoration(
                    hintText: 'Enter code (e.g. HARVEST20)',
                  ),
                  onSubmitted: (_) => onApply(),
                ),
              ),
            ),
            const SizedBox(width: 8),
            SizedBox(
              height: CheckoutVoucherStyles.inputRowHeight,
              child: ElevatedButton(
                onPressed: isValidating ? null : onApply,
                style: CheckoutVoucherStyles.applyButtonStyle,
                child: isValidating
                    ? const SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : const Text(
                        'Apply',
                        style: CheckoutVoucherStyles.applyButtonTextStyle,
                      ),
              ),
            ),
          ],
        ),
        if (errorMessage != null && errorMessage!.isNotEmpty) ...[
          const SizedBox(height: 6),
          Row(
            children: [
              const Icon(
                Icons.error_outline_rounded,
                size: 14,
                color: AgrisellColors.statusRedText,
              ),
              const SizedBox(width: 4),
              Expanded(
                child: Text(
                  errorMessage!,
                  style: CheckoutVoucherStyles.errorTextStyle,
                ),
              ),
            ],
          ),
        ],
      ],
    );
  }
}
