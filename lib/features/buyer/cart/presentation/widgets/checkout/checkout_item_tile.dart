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
                  decoration: const BoxDecoration(
                    color: AgrisellColors.forestSoft,
                    shape: BoxShape.circle,
                  ),
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
                    style: const TextStyle(
                      color: AgrisellColors.brandBlack,
                      fontSize: 12,
                      height: 1,
                      fontWeight: FontWeight.w800,
                    ),
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
          style: const TextStyle(
            color: AgrisellColors.brandBlack,
            fontSize: 15,
            height: 1.1,
            fontWeight: FontWeight.w800,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
          decoration: BoxDecoration(
            color: AgrisellColors.forestSoft,
            borderRadius: BorderRadius.circular(7),
          ),
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
                  style: const TextStyle(
                    color: AgrisellColors.authGreen,
                    fontSize: 11.5,
                    height: 1,
                    fontWeight: FontWeight.w700,
                  ),
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
              decoration: BoxDecoration(
                color: AgrisellColors.limeSoft,
                borderRadius: BorderRadius.circular(6),
              ),
              child: Text(
                'Qty ${item.quantity}',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  color: AgrisellColors.forestDark,
                  fontSize: 11,
                  height: 1,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
