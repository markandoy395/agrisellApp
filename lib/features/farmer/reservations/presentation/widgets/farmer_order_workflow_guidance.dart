import 'package:flutter/material.dart';

import 'package:agresell_app/core/theme/agrisell_colors.dart';
import 'package:agresell_app/features/farmer/reservations/presentation/widgets/farmer_rider_waiting_panel.dart';
import 'package:agresell_app/features/shared/orders/domain/order_payment.dart';
import 'package:agresell_app/features/shared/orders/domain/placed_order.dart';

class FarmerOrderWorkflowGuidance extends StatelessWidget {
  const FarmerOrderWorkflowGuidance({required this.order, super.key});

  final PlacedOrder order;

  @override
  Widget build(BuildContext context) {
    if (order.status == PlacedOrderStatus.readyForPickup) {
      return const FarmerRiderWaitingPanel();
    }
    final (message, color) = switch ((order.status, order.payment.status)) {
      (PlacedOrderStatus.cancelled, OrderPaymentStatus.paymentReviewRequired) =>
        (
          'This order expired. Check whether the GCash payment was received.',
          AgrisellColors.statusPurpleText,
        ),
      (PlacedOrderStatus.toShip, OrderPaymentStatus.rejected) => (
        'Waiting for the buyer to submit a new GCash reference.',
        AgrisellColors.statusRedText,
      ),
      (PlacedOrderStatus.toShip, _) => (
        'Review and verify the GCash reference before accepting.',
        AgrisellColors.statusBlueText,
      ),
      (PlacedOrderStatus.cancelled, OrderPaymentStatus.refundRequired) => (
        'Return the buyer payment, then record the refund reference.',
        AgrisellColors.statusPurpleText,
      ),
      (PlacedOrderStatus.cancelled, OrderPaymentStatus.refunded) => (
        'The order expired and the buyer refund was recorded.',
        AgrisellColors.statusGreenText,
      ),
      (PlacedOrderStatus.cancelled, _) when order.isExpired => (
        'The deadline passed and reserved stock was released.',
        AgrisellColors.statusRedText,
      ),
      _ => (
        'The rider has the order. Keep delivery updates active.',
        AgrisellColors.mutedText,
      ),
    };
    return Text(
      message,
      style: TextStyle(color: color, fontSize: 12, fontWeight: FontWeight.w700),
    );
  }
}
