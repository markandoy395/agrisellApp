part of 'basket_screen.dart';

class _DeliveryNote extends StatelessWidget {
  const _DeliveryNote();
  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 11),
    decoration: BasketScreenStatesStyles.containerDecoration,
    child: const Row(
      children: [
        Icon(
          Icons.local_shipping_outlined,
          size: 18,
          color: AgrisellColors.authGreen,
        ),
        SizedBox(width: 9),
        Expanded(
          child: Text(
            'Confirm delivery and payment at checkout.',
            style: BasketScreenStatesStyles.confirmDeliveryAndPaymentAtText,
          ),
        ),
      ],
    ),
  );
}

class _EmptyBasketContent extends StatelessWidget {
  const _EmptyBasketContent({
    required this.excludedProductIds,
    required this.onContinueShopping,
  });
  final Set<String> excludedProductIds;
  final VoidCallback onContinueShopping;
  @override
  Widget build(BuildContext context) {
    final padding = MediaQuery.sizeOf(context).width < 380 ? 12.0 : 16.0;
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: EdgeInsets.fromLTRB(padding, 18, padding, 26),
      child: Column(
        children: [
          EmptyBasketState(onContinueShopping: onContinueShopping),
          const SizedBox(height: 24),
          BasketSuggestions(excludedProductIds: excludedProductIds),
        ],
      ),
    );
  }
}
