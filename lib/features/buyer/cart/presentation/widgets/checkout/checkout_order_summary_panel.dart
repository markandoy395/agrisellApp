part of 'package:agresell_app/features/buyer/cart/presentation/screens/checkout_screen.dart';

class _CheckoutOrderSummaryPanel extends StatelessWidget {
  const _CheckoutOrderSummaryPanel({
    required this.subtotal,
    required this.productSaleDiscount,
    required this.voucherDiscount,
    required this.finalTotal,
    this.appliedVoucherCode,
  });

  final double subtotal;
  final double productSaleDiscount;
  final double voucherDiscount;
  final double finalTotal;
  final String? appliedVoucherCode;

  double get totalSavings => productSaleDiscount + voucherDiscount;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: AgrisellColors.surface,
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(
            color: AgrisellColors.brandBlack.withValues(alpha: 0.08),
            blurRadius: 12,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: AgrisellColors.forestSoft,
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: const Icon(
                    Icons.receipt_long_outlined,
                    color: AgrisellColors.authGreen,
                    size: 18,
                  ),
                ),
                const SizedBox(width: 8),
                const Text(
                  'Order Summary & Discounts',
                  style: TextStyle(
                    color: AgrisellColors.brandBlack,
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            _SummaryRow(
              label: 'Items Subtotal',
              value: formatBasketPeso(subtotal),
            ),
            if (productSaleDiscount > 0) ...[
              const SizedBox(height: 6),
              _SummaryRow(
                label: 'Product Sale Discount',
                value: '-${formatBasketPeso(productSaleDiscount)}',
                valueColor: AgrisellColors.authGreen,
              ),
            ],
            if (voucherDiscount > 0) ...[
              const SizedBox(height: 6),
              _SummaryRow(
                label: appliedVoucherCode != null
                    ? 'Voucher ($appliedVoucherCode)'
                    : 'Voucher Discount',
                value: '-${formatBasketPeso(voucherDiscount)}',
                valueColor: AgrisellColors.authGreen,
              ),
            ],
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 8),
              child: Divider(
                height: 1,
                thickness: 1,
                color: AgrisellColors.borderLine,
              ),
            ),
            _SummaryRow(
              label: 'Total Payment',
              value: formatBasketPeso(finalTotal),
              isTotal: true,
            ),
            if (totalSavings > 0) ...[
              const SizedBox(height: 10),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: AgrisellColors.forestSoft,
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(
                    color: AgrisellColors.authGreen.withValues(alpha: 0.2),
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(
                      Icons.savings_outlined,
                      color: AgrisellColors.authGreen,
                      size: 16,
                    ),
                    const SizedBox(width: 6),
                    Flexible(
                      child: Text(
                        'You save ${formatBasketPeso(totalSavings)} on this order!',
                        style: const TextStyle(
                          color: AgrisellColors.authGreen,
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _SummaryRow extends StatelessWidget {
  const _SummaryRow({
    required this.label,
    required this.value,
    this.valueColor,
    this.isTotal = false,
  });

  final String label;
  final String value;
  final Color? valueColor;
  final bool isTotal;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            color: isTotal
                ? AgrisellColors.brandBlack
                : AgrisellColors.mutedText,
            fontSize: isTotal ? 13 : 12,
            fontWeight: isTotal ? FontWeight.w800 : FontWeight.w500,
          ),
        ),
        Text(
          value,
          style: TextStyle(
            color: valueColor ??
                (isTotal ? AgrisellColors.authGreen : AgrisellColors.brandBlack),
            fontSize: isTotal ? 16 : 12,
            fontWeight: isTotal ? FontWeight.w800 : FontWeight.w600,
          ),
        ),
      ],
    );
  }
}
