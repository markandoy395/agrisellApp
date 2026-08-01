part of 'package:agresell_app/features/buyer/orders/presentation/screens/order_tracking_screen.dart';

class _TrackingOrderCard extends StatelessWidget {
  const _TrackingOrderCard({
    required this.order,
    required this.item,
    required this.onCancelOrder,
    required this.onSubmitFeedback,
    super.key,
  });

  final PlacedOrder order;
  final PlacedOrderItem item;
  final Future<void> Function(String orderId) onCancelOrder;
  final _SubmitOrderFeedback onSubmitFeedback;

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;
    final imageSize = width < 380 ? 72.0 : 82.0;

    return DecoratedBox(
      decoration: BoxDecoration(
        color: AgrisellColors.surface,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: AgrisellColors.brandBlack.withValues(alpha: 0.09),
            blurRadius: 18,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Padding(
        padding: EdgeInsets.all(width < 380 ? 11.0 : 13.0),
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
                    style: const TextStyle(
                      color: AgrisellColors.mutedText,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                _StatusChip(status: order.status, label: _statusLabel(order)),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ProductThumbnail.square(
                  asset: item.image,
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
            _DeliveryRouteTracker(status: order.status),
            const SizedBox(height: 14),
            _OrderCardActions(
              status: order.status,
              canLeaveFeedback: order.canLeaveFeedback,
              canRetryPayment:
                  order.payment.method == OrderPaymentMethod.gcash &&
                  order.payment.status == OrderPaymentStatus.rejected,
              onViewDetails: () => _showOrderDetails(context),
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
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(18)),
      ),
      builder: (context) => _OrderDetailsSheet(order: order),
    );
  }

  String _statusLabel(PlacedOrder order) {
    if (order.isExpired) return 'Expired';
    if (order.payment.status == OrderPaymentStatus.rejected) {
      return 'Fix payment';
    }
    if (order.payment.status == OrderPaymentStatus.submittedForVerification) {
      return 'Payment review';
    }
    if (order.payment.status == OrderPaymentStatus.paymentReviewRequired) {
      return 'Payment review required';
    }
    if (order.payment.status == OrderPaymentStatus.refundRequired) {
      return 'Refund required';
    }
    if (order.payment.status == OrderPaymentStatus.refunded) {
      return 'Refunded';
    }
    if (order.canLeaveFeedback) return OrderTrackingFilter.toRate.label;
    return switch (order.status) {
      PlacedOrderStatus.toShip => 'Awaiting acceptance',
      PlacedOrderStatus.preparing => 'Preparing',
      PlacedOrderStatus.readyForPickup => 'Ready for pickup',
      _ => order.status.label,
    };
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
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(18)),
      ),
      builder: (context) => _OrderFeedbackSheet(
        order: order,
        item: item,
        onSubmit: (rating, comment) => onSubmitFeedback(
          orderId: order.id,
          rating: rating,
          comment: comment,
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
