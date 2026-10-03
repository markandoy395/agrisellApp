part of 'package:agresell_app/features/buyer/orders/presentation/screens/order_tracking_screen.dart';

class _FeedbackProductHeader extends StatelessWidget {
  const _FeedbackProductHeader({required this.item});

  final PlacedOrderItem item;

  @override
  Widget build(BuildContext context) => Row(
    children: [
      ProductThumbnail.square(
        asset: item.image,
        imageUrl: item.imageUrl,
        size: 48,
        borderRadius: 9,
        semanticLabel: '${item.productName} product photo',
      ),
      const SizedBox(width: 10),
      Expanded(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              item.productName,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: SharedPresentationStyles.headingTitleExtraBold,
            ),
            const SizedBox(height: 2),
            Text(
              'Sold by ${item.sellerName}',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: SharedPresentationStyles.mutedCaption,
            ),
          ],
        ),
      ),
    ],
  );
}
