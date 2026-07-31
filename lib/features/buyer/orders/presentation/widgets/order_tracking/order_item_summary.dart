part of 'package:agresell_app/features/buyer/orders/presentation/screens/order_tracking_screen.dart';

class _OrderItemSummary extends StatelessWidget {
  const _OrderItemSummary({required this.item});

  final PlacedOrderItem item;

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
            fontSize: 14,
            height: 1.12,
            fontWeight: FontWeight.w800,
          ),
        ),
        const SizedBox(height: 7),
        Row(
          children: [
            const Icon(
              Icons.storefront_rounded,
              size: 15,
              color: AgrisellColors.authGreen,
            ),
            const SizedBox(width: 5),
            Expanded(
              child: Text(
                item.sellerName,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  color: AgrisellColors.mutedText,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        Wrap(
          spacing: 7,
          runSpacing: 7,
          children: [
            _OrderQuantityBadge(quantity: item.quantity),
            _MetricChip(
              icon: Icons.payments_outlined,
              label: formatBasketPeso(item.total),
              isPrimary: true,
            ),
          ],
        ),
      ],
    );
  }
}

class _OrderQuantityBadge extends StatelessWidget {
  const _OrderQuantityBadge({required this.quantity});

  final int quantity;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: 'Quantity $quantity',
      child: DecoratedBox(
        key: const ValueKey('to-ship-quantity-counter'),
        decoration: BoxDecoration(
          color: AgrisellColors.surface,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: AgrisellColors.borderLine),
        ),
        child: SizedBox(
          height: 28,
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(
                width: 28,
                child: Icon(
                  Icons.remove,
                  size: 15,
                  color: AgrisellColors.authGreen,
                ),
              ),
              SizedBox(
                width: 28,
                child: Text(
                  '$quantity',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: AgrisellColors.brandBlack,
                    fontSize: 12,
                    height: 1,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              const SizedBox(
                width: 28,
                child: Icon(
                  Icons.add,
                  size: 15,
                  color: AgrisellColors.authGreen,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _MetricChip extends StatelessWidget {
  const _MetricChip({
    required this.icon,
    required this.label,
    this.isPrimary = false,
  });

  final IconData icon;
  final String label;
  final bool isPrimary;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 6),
      decoration: BoxDecoration(
        color: isPrimary
            ? AgrisellColors.limeSoft
            : AgrisellColors.homeBackground,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: 14,
            color: isPrimary
                ? AgrisellColors.authGreen
                : AgrisellColors.mutedText,
          ),
          const SizedBox(width: 5),
          Text(
            label,
            style: TextStyle(
              color: isPrimary
                  ? AgrisellColors.authGreen
                  : AgrisellColors.brandBlack,
              fontSize: 12,
              height: 1,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}
