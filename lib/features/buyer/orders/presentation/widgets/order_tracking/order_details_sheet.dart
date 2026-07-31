part of 'package:agresell_app/features/buyer/orders/presentation/screens/order_tracking_screen.dart';

class _OrderDetailsSheet extends StatelessWidget {
  const _OrderDetailsSheet({required this.order});

  final PlacedOrder order;

  @override
  Widget build(BuildContext context) {
    final itemLabel = order.totalQuantity == 1 ? 'item' : 'items';

    return SafeArea(
      top: false,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 10, 16, 18),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 42,
                height: 4,
                decoration: BoxDecoration(
                  color: AgrisellColors.borderLine,
                  borderRadius: BorderRadius.circular(999),
                ),
              ),
            ),
            const SizedBox(height: 14),
            Row(
              children: [
                const Expanded(
                  child: Text(
                    'Order Details',
                    style: TextStyle(
                      color: AgrisellColors.brandBlack,
                      fontSize: 15,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
                IconButton(
                  visualDensity: VisualDensity.compact,
                  tooltip: 'Close',
                  onPressed: () => Navigator.of(context).pop(),
                  icon: const Icon(Icons.close_rounded),
                ),
              ],
            ),
            const SizedBox(height: 10),
            _DetailsLine(label: 'Order ID', value: order.id),
            _DetailsLine(
              label: 'Status',
              value: order.isExpired ? 'Expired' : order.status.label,
            ),
            if (order.acceptanceExpiresAt case final deadline?)
              _DetailsLine(
                label: 'Acceptance deadline',
                value:
                    '${MaterialLocalizations.of(context).formatFullDate(deadline)}, '
                    '${MaterialLocalizations.of(context).formatTimeOfDay(TimeOfDay.fromDateTime(deadline))}',
              ),
            _DetailsLine(
              label: 'Items',
              value: '${order.totalQuantity} $itemLabel',
            ),
            _DetailsLine(label: 'Total', value: formatBasketPeso(order.total)),
            _DetailsLine(label: 'Payment', value: order.payment.method.label),
            _DetailsLine(
              label: 'Payment status',
              value: order.payment.status.label,
            ),
            if (order.payment.transactionReference.isNotEmpty)
              _DetailsLine(
                label: 'GCash reference',
                value: order.payment.transactionReference,
              ),
            if (order.payment.refundReference.isNotEmpty)
              _DetailsLine(
                label: 'Refund reference',
                value: order.payment.refundReference,
              ),
            _DetailsLine(label: 'Phone', value: order.phoneNumber),
            _DetailsLine(
              label: 'Delivery Address',
              value: order.deliveryAddress.replaceAll('\n', ', '),
            ),
          ],
        ),
      ),
    );
  }
}

class _DetailsLine extends StatelessWidget {
  const _DetailsLine({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 9),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 116,
            child: Text(
              label,
              style: const TextStyle(
                color: AgrisellColors.mutedText,
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                color: AgrisellColors.brandBlack,
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
