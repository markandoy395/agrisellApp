part of 'package:agresell_app/features/buyer/cart/presentation/screens/checkout_screen.dart';

class _CheckoutPriceLine extends StatelessWidget {
  const _CheckoutPriceLine({required this.item});

  final BasketCartItem item;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 6,
      crossAxisAlignment: WrapCrossAlignment.center,
      children: [
        if (item.hasSale)
          Text(
            item.originalPriceLabel!,
            style: const TextStyle(
              color: Colors.red,
              fontSize: 12,
              decoration: TextDecoration.lineThrough,
              decorationColor: Colors.red,
              fontWeight: FontWeight.w600,
            ),
          ),
        if (item.hasSale)
          const Text('→', style: TextStyle(color: AgrisellColors.mutedText)),
        Text.rich(
          TextSpan(
            text: item.priceLabel,
            style: const TextStyle(
              color: AgrisellColors.authGreen,
              fontSize: 13,
              height: 1,
              fontWeight: FontWeight.w800,
            ),
            children: [
              TextSpan(
                text: ' ${item.unit}',
                style: const TextStyle(
                  color: AgrisellColors.brandBlack,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
