part of 'package:agresell_app/features/buyer/orders/presentation/screens/order_tracking_screen.dart';

class _FeedbackProductHeader extends StatelessWidget {
  const _FeedbackProductHeader({required this.item});

  final PlacedOrderItem item;

  @override
  Widget build(BuildContext context) => Row(
    children: [
      ClipRRect(
        borderRadius: BorderRadius.circular(9),
        child: ResponsiveAssetImage(
          asset: item.image,
          width: 48,
          height: 48,
          fit: BoxFit.cover,
          semanticLabel: '${item.productName} product photo',
        ),
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
              style: const TextStyle(
                color: AgrisellColors.headingGreen,
                fontSize: 15,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              'Sold by ${item.sellerName}',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                color: AgrisellColors.mutedText,
                fontSize: 12,
              ),
            ),
          ],
        ),
      ),
    ],
  );
}
