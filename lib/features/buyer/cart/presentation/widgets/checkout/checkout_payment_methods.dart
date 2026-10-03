part of 'package:agresell_app/features/buyer/cart/presentation/screens/checkout_screen.dart';

class _PaymentMethodsPanel extends StatelessWidget {
  const _PaymentMethodsPanel({required this.payment, required this.onSelect});

  final OrderPayment payment;
  final ValueChanged<OrderPaymentMethod> onSelect;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: CheckoutPaymentMethodsStyles.decoratedBoxDecoration,
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Payment Methods',
              style: SharedPresentationStyles.headingSubtitleExtraBold,
            ),
            const SizedBox(height: 4),
            const Text(
              'Choose how you want to settle this order.',
              style: SharedPresentationStyles.mutedCaptionCompact,
            ),
            const SizedBox(height: 10),
            _PaymentChoiceTile(
              method: OrderPaymentMethod.cashOnDelivery,
              icon: Icons.payments_outlined,
              subtitle: 'Pay the rider when your produce arrives.',
              selected: payment.method == OrderPaymentMethod.cashOnDelivery,
              onTap: onSelect,
            ),
            const SizedBox(height: 8),
            _PaymentChoiceTile(
              method: OrderPaymentMethod.gcash,
              icon: Icons.account_balance_wallet_outlined,
              subtitle: payment.method == OrderPaymentMethod.gcash
                  ? 'Reference ${payment.transactionReference}'
                  : 'Transfer manually using the farmer’s GCash details.',
              selected: payment.method == OrderPaymentMethod.gcash,
              onTap: onSelect,
            ),
          ],
        ),
      ),
    );
  }
}

class _PaymentChoiceTile extends StatelessWidget {
  const _PaymentChoiceTile({
    required this.method,
    required this.icon,
    required this.subtitle,
    required this.selected,
    required this.onTap,
  });

  final OrderPaymentMethod method;
  final IconData icon;
  final String subtitle;
  final bool selected;
  final ValueChanged<OrderPaymentMethod> onTap;

  @override
  Widget build(BuildContext context) {
    final borderColor = selected
        ? AgrisellColors.authGreen
        : AgrisellColors.borderLine;
    return Semantics(
      selected: selected,
      button: true,
      label: '${method.label}. $subtitle',
      child: Material(
        color: selected ? AgrisellColors.forestSoft : AgrisellColors.surface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
          side: BorderSide(color: borderColor),
        ),
        child: InkWell(
          onTap: () => onTap(method),
          borderRadius: BorderRadius.circular(10),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 10),
            child: Row(
              children: [
                Container(
                  width: 34,
                  height: 34,
                  decoration: CheckoutPaymentMethodsStyles.containerDecoration(
                    selected,
                  ),
                  child: Icon(
                    icon,
                    size: 18,
                    color: selected
                        ? AgrisellColors.surface
                        : AgrisellColors.headingGreen,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        method.label,
                        style: SharedPresentationStyles.inkBodyExtraBold,
                      ),
                      const SizedBox(height: 2),
                      Text(
                        subtitle,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: CheckoutPaymentMethodsStyles.subtitleText,
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                Icon(
                  selected
                      ? Icons.radio_button_checked
                      : Icons.radio_button_off,
                  color: selected
                      ? AgrisellColors.authGreen
                      : AgrisellColors.dividerLine,
                  size: 20,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
