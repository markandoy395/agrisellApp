part of 'package:agresell_app/features/buyer/cart/presentation/screens/checkout_screen.dart';

class _AppliedVoucherView extends StatelessWidget {
  const _AppliedVoucherView({
    required this.voucher,
    required this.onRemove,
  });

  final AppliedVoucher voucher;
  final VoidCallback onRemove;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: CheckoutVoucherStyles.appliedVoucherPadding,
      decoration: CheckoutVoucherStyles.appliedVoucherDecoration,
      child: Row(
        children: [
          const Icon(
            Icons.check_circle_rounded,
            color: AgrisellColors.authGreen,
            size: 18,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      voucher.code,
                      style: CheckoutVoucherStyles.appliedCodeTextStyle,
                    ),
                    const SizedBox(width: 6),
                    Container(
                      padding: CheckoutVoucherStyles.discountBadgePadding,
                      decoration: CheckoutVoucherStyles.discountBadgeDecoration,
                      child: Text(
                        voucher.discountLabel,
                        style: CheckoutVoucherStyles.discountBadgeTextStyle,
                      ),
                    ),
                  ],
                ),
                Text(
                  '-${formatBasketPeso(voucher.discountAmount)} off applied (${voucher.name})',
                  style: CheckoutVoucherStyles.discountSummaryTextStyle,
                ),
              ],
            ),
          ),
          IconButton(
            onPressed: onRemove,
            icon: const Icon(
              Icons.close_rounded,
              size: 18,
              color: AgrisellColors.mutedText,
            ),
            tooltip: 'Remove voucher',
            constraints: CheckoutVoucherStyles.removeButtonConstraints,
            padding: EdgeInsets.zero,
          ),
        ],
      ),
    );
  }
}
