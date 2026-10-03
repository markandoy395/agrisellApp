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
            style: SharedPresentationStyles.originalPrice,
          ),
        if (item.hasSale)
          const Text('→', style: SharedPresentationStyles.mutedText),
        Text.rich(
          TextSpan(
            text: item.priceLabel,
            style: CheckoutItemHelpersStyles.textStyle,
            children: [
              TextSpan(
                text: ' ${item.unit}',
                style: CheckoutItemHelpersStyles.textStyle2,
              ),
            ],
          ),
        ),
      ],
    );
  }
}
