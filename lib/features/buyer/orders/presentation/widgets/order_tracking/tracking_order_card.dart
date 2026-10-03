part of 'package:agresell_app/features/buyer/orders/presentation/screens/order_tracking_screen.dart';

class _TrackingOrderCard extends StatelessWidget {
  const _TrackingOrderCard({
    required this.order,
    required this.item,
    required this.onCancelOrder,
    required this.onSubmitFeedback,
    this.onReportDispute,
    super.key,
  });

  final PlacedOrder order;
  final PlacedOrderItem item;
  final Future<void> Function(String orderId) onCancelOrder;
  final _SubmitOrderFeedback onSubmitFeedback;
  final _ReportOrderDispute? onReportDispute;

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;
    final imageSize = TrackingOrderCardStyles.imageSize(width);

    return DecoratedBox(
      decoration: TrackingOrderCardStyles.cardDecoration,
      child: Padding(
        padding: TrackingOrderCardStyles.cardPadding(width),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    order.id,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TrackingOrderCardStyles.orderIdStyle,
                  ),
                ),
                ConstrainedBox(
                  constraints: TrackingOrderCardStyles.statusChipConstraints(
                    width,
                  ),
                  child: _StatusChip(
                    status: order.status,
                    label: _TrackingOrderStatusResolver.resolve(order),
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
                  size: imageSize,
                  borderRadius: 12,
                  semanticLabel: '${item.productName} product photo',
                ),
                const SizedBox(width: 12),
                Expanded(child: _OrderItemSummary(item: item)),
              ],
            ),
            const SizedBox(height: 14),
            OrderAcceptanceDeadlineCard(
              order: order,
              audience: OrderDeadlineAudience.buyer,
            ),
            if (order.acceptanceExpiresAt != null &&
                (order.isExpired || order.status == PlacedOrderStatus.toShip))
              const SizedBox(height: 14),
            _DeliveryRouteTracker(status: order.status, order: order),
            const SizedBox(height: 14),
            _OrderCardActions(
              status: order.status,
              hasRefund:
                  order.payment.hasRefund ||
                  (order.status == PlacedOrderStatus.cancelled &&
                      order.payment.method == OrderPaymentMethod.gcash),
              canLeaveFeedback:
                  order.canReviewProduct(item.productId) ||
                  (order.status.canLeaveFeedback &&
                      order.deliveryId != null &&
                      !order.riderRated),
              canRetryPayment:
                  order.payment.method == OrderPaymentMethod.gcash &&
                  order.payment.status == OrderPaymentStatus.rejected,
              hasDispute: order.hasDispute,
              canDispute: order.canDispute,
              onDispute: onReportDispute != null
                  ? () => _showDisputeSheet(context)
                  : null,
              onViewDetails: () => _showOrderDetails(context),
              onTrackRefund: () =>
                  showBuyerRefundDetailSheet(context, order: order),
              onCancel: () => _cancelOrder(context),
              onContactSeller: () => _contactSeller(context),
              onLeaveFeedback: () => _leaveFeedback(context),
              onRetryPayment: () =>
                  showGcashReferenceRetrySheet(context, order),
            ),
          ],
        ),
      ),
    );
  }

  void _showOrderDetails(BuildContext context) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      shape: TrackingOrderCardStyles.sheetShape,
      builder: (context) => _OrderDetailsSheet(order: order),
    );
  }

  void _showDisputeSheet(BuildContext context) {
    if (onReportDispute == null) return;
    showOrderDisputeSheet(
      context,
      order: order,
      onSubmitDispute: onReportDispute!,
    );
  }

  Future<void> _cancelOrder(BuildContext context) async {
    try {
      await onCancelOrder(order.id);
      if (context.mounted) {
        _showMessage(context, 'Order cancelled successfully.');
      }
    } on Object catch (error) {
      if (!context.mounted) return;
      final detail = error.toString().replaceFirst('Exception: ', '').trim();
      _showMessage(
        context,
        detail.isEmpty ? 'The order could not be cancelled.' : detail,
      );
    }
  }

  void _leaveFeedback(BuildContext context) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      shape: TrackingOrderCardStyles.sheetShape,
      builder: (context) => _OrderFeedbackSheet(
        order: order,
        item: item,
        onSubmit: (rating, comment, riderRating, riderComment) =>
            onSubmitFeedback(
              orderId: order.id,
              productId: item.productId,
              rating: rating,
              comment: comment,
              riderRating: riderRating,
              riderComment: riderComment,
              reviewProduct: order.canReviewProduct(item.productId),
            ),
      ),
    );
  }

  void _contactSeller(BuildContext context) {
    unawaited(
      BuyerConversationLauncher.open(
        context,
        sellerName: item.sellerName,
        commodityId: item.productId,
        clientOrderId: order.id,
        productName: item.productName,
      ),
    );
  }

  void _showMessage(BuildContext context, String message) {
    final messenger = ScaffoldMessenger.of(context);
    messenger.clearSnackBars();
    messenger.showAppSnackBar(SnackBar(content: Text(message)));
  }
}
