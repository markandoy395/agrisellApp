part of 'package:agresell_app/features/buyer/orders/presentation/screens/order_tracking_screen.dart';

abstract final class _TrackingOrderStatusResolver {
  static String resolve(PlacedOrder order) {
    if (order.hasDispute) {
      return switch (order.dispute!.status) {
        OrderDisputeStatus.pending => 'Dispute: Under review',
        OrderDisputeStatus.resolved => 'Dispute: Resolved',
        OrderDisputeStatus.rejected => 'Dispute: Rejected',
      };
    }
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
}
