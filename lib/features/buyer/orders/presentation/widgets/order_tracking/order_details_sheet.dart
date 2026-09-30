part of 'package:agresell_app/features/buyer/orders/presentation/screens/order_tracking_screen.dart';

class _OrderDetailsSheet extends StatelessWidget {
  const _OrderDetailsSheet({required this.order});

  final PlacedOrder order;

  @override
  Widget build(BuildContext context) {
    final itemLabel = order.totalQuantity == 1 ? 'item' : 'items';

    final maxHeight = MediaQuery.sizeOf(context).height * 0.85;

    return SafeArea(
      top: false,
      child: ConstrainedBox(
        constraints: BoxConstraints(maxHeight: maxHeight),
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(16, 4, 16, 18),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
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
              if (order.payment.hasReceiptImage)
                _DetailsLine(
                  label: 'Receipt image',
                  value: order.payment.receiptImageName.isEmpty
                      ? 'Uploaded'
                      : order.payment.receiptImageName,
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
              if (order.payment.hasRefund ||
                  (order.status == PlacedOrderStatus.cancelled &&
                      order.payment.method == OrderPaymentMethod.gcash)) ...[
                const SizedBox(height: 10),
                SizedBox(
                  width: double.infinity,
                  child: FilledButton.icon(
                    onPressed: () {
                      Navigator.pop(context);
                      showBuyerRefundDetailSheet(context, order: order);
                    },
                    style: FilledButton.styleFrom(
                      backgroundColor: AgrisellColors.statusPurpleText,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    icon: const Icon(Icons.receipt_long_outlined, size: 18),
                    label: const Text(
                      'Track Refund Status',
                      style: TextStyle(fontWeight: FontWeight.w700),
                    ),
                  ),
                ),
              ],
              if (order.status == PlacedOrderStatus.shipping ||
                  order.status == PlacedOrderStatus.readyForPickup ||
                  order.status == PlacedOrderStatus.delivered) ...[
                const SizedBox(height: 10),
                SizedBox(
                  width: double.infinity,
                  child: FilledButton.icon(
                    onPressed: () =>
                        showDeliveryTrackingSheet(context, order: order),
                    style: FilledButton.styleFrom(
                      backgroundColor: AgrisellColors.authGreen,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    icon: const Icon(Icons.map_rounded, size: 18),
                    label: const Text(
                      'Track Live Delivery on Map',
                      style: TextStyle(fontWeight: FontWeight.w700),
                    ),
                  ),
                ),
              ],
            ],
          ),
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
