part of 'package:agresell_app/features/buyer/cart/presentation/screens/checkout_screen.dart';

class CheckoutItemTile extends StatelessWidget {
  const CheckoutItemTile({required this.item, super.key});

  final BasketCartItem item;

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: AgrisellColors.surface,
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 24,
                  height: 24,
                  decoration: SharedPresentationStyles.forestCircle,
                  child: const Icon(
                    Icons.storefront_outlined,
                    size: 14,
                    color: AgrisellColors.authGreen,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    item.sellerName,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: CheckoutItemTileStyles.textStyle,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ProductThumbnail.square(
                  asset: item.image,
                  imageUrl: item.imageUrl,
                  size: 82,
                  borderRadius: 10,
                  semanticLabel: '${item.productName} product photo',
                ),
                const SizedBox(width: 12),
                Expanded(child: _CheckoutItemDetails(item: item)),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _CheckoutItemDetails extends StatelessWidget {
  const _CheckoutItemDetails({required this.item});

  final BasketCartItem item;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          item.productName,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          style: CheckoutItemTileStyles.textStyle2,
        ),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
          decoration: CheckoutItemTileStyles.containerDecoration,
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.calendar_today_outlined,
                size: 13,
                color: AgrisellColors.authGreen,
              ),
              const SizedBox(width: 5),
              Flexible(
                child: Text(
                  'Harvested ${item.harvestDate}',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: CheckoutItemTileStyles.textStyle3,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 11),
        Row(
          children: [
            Expanded(child: _CheckoutPriceLine(item: item)),
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
              decoration: CheckoutItemTileStyles.containerDecoration2,
              child: Text(
                'Qty ${item.quantity}',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: CheckoutItemTileStyles.textStyle4,
              ),
            ),
          ],
        ),
      ],
    );
  }
}
