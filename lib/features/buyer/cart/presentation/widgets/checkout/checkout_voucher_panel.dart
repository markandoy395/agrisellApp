part of 'package:agresell_app/features/buyer/cart/presentation/screens/checkout_screen.dart';

class _CheckoutVoucherPanel extends StatelessWidget {
  const _CheckoutVoucherPanel({
    required this.controller,
    required this.appliedVoucher,
    required this.isValidating,
    required this.errorMessage,
    required this.onApply,
    required this.onRemove,
    this.onBrowseVouchers,
  });

  final TextEditingController controller;
  final AppliedVoucher? appliedVoucher;
  final bool isValidating;
  final String? errorMessage;
  final VoidCallback onApply;
  final VoidCallback onRemove;
  final VoidCallback? onBrowseVouchers;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: CheckoutVoucherStyles.panelDecoration,
      child: Padding(
        padding: CheckoutVoucherStyles.panelPadding,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: CheckoutVoucherStyles.iconContainerPadding,
                  decoration: CheckoutVoucherStyles.iconContainerDecoration,
                  child: const Icon(
                    Icons.confirmation_number_outlined,
                    color: AgrisellColors.authGreen,
                    size: 18,
                  ),
                ),
                const SizedBox(width: 8),
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Voucher / Promo Code',
                        style: CheckoutVoucherStyles.titleTextStyle,
                      ),
                      Text(
                        'Apply a promo code to receive a discount',
                        style: CheckoutVoucherStyles.subtitleTextStyle,
                      ),
                    ],
                  ),
                ),
                if (onBrowseVouchers != null && appliedVoucher == null)
                  TextButton.icon(
                    onPressed: onBrowseVouchers,
                    style: CheckoutVoucherStyles.browseButtonStyle,
                    icon: const Icon(Icons.wallet_giftcard_rounded, size: 16),
                    label: const Text(
                      'Browse',
                      style: CheckoutVoucherStyles.browseButtonTextStyle,
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 10),
            if (appliedVoucher != null)
              _AppliedVoucherView(
                voucher: appliedVoucher!,
                onRemove: onRemove,
              )
            else
              _VoucherInputView(
                controller: controller,
                isValidating: isValidating,
                errorMessage: errorMessage,
                onApply: onApply,
              ),
          ],
        ),
      ),
    );
  }
}
