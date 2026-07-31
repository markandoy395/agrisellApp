import 'package:flutter/material.dart';

import 'package:agresell_app/core/theme/agrisellColors.dart';
import 'package:agresell_app/features/farmer/reservations/presentation/widgets/farmer_gcash_review_sheet.dart';
import 'package:agresell_app/features/farmer/reservations/presentation/widgets/farmer_gcash_refund_sheet.dart';
import 'package:agresell_app/features/shared/orders/domain/order_payment.dart';
import 'package:agresell_app/features/shared/orders/domain/placed_order.dart';

class FarmerOrderPaymentPanel extends StatelessWidget {
  const FarmerOrderPaymentPanel({required this.order, super.key});

  final PlacedOrder order;

  @override
  Widget build(BuildContext context) {
    final payment = order.payment;
    final isGcash = payment.method == OrderPaymentMethod.gcash;
    final colors = _colors(payment.status);
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: colors.background,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: colors.foreground.withValues(alpha: 0.3)),
      ),
      child: Row(
        children: [
          Icon(
            isGcash
                ? Icons.account_balance_wallet_outlined
                : Icons.payments_outlined,
            size: 19,
            color: colors.foreground,
          ),
          const SizedBox(width: 9),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  payment.method.label,
                  style: TextStyle(
                    color: colors.foreground,
                    fontSize: 13,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  payment.status.label,
                  style: TextStyle(
                    color: colors.foreground,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
          if (payment.needsFarmerReview)
            SizedBox(
              height: 36,
              child: FilledButton(
                onPressed: () => showFarmerGcashReviewSheet(context, order),
                style: FilledButton.styleFrom(
                  backgroundColor: AgrisellColors.authGreen,
                  padding: const EdgeInsets.symmetric(horizontal: 11),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: const Text(
                  'Review',
                  style: TextStyle(fontSize: 12, fontWeight: FontWeight.w800),
                ),
              ),
            ),
          if (payment.status == OrderPaymentStatus.refundRequired)
            SizedBox(
              height: 36,
              child: FilledButton(
                onPressed: () => showFarmerGcashRefundSheet(context, order),
                style: FilledButton.styleFrom(
                  backgroundColor: AgrisellColors.statusPurpleText,
                  padding: const EdgeInsets.symmetric(horizontal: 11),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: const Text(
                  'Refund',
                  style: TextStyle(fontSize: 12, fontWeight: FontWeight.w800),
                ),
              ),
            ),
        ],
      ),
    );
  }

  ({Color foreground, Color background}) _colors(OrderPaymentStatus status) =>
      switch (status) {
        OrderPaymentStatus.verified => (
          foreground: AgrisellColors.statusGreenText,
          background: AgrisellColors.statusGreenBackground,
        ),
        OrderPaymentStatus.rejected => (
          foreground: AgrisellColors.statusRedText,
          background: AgrisellColors.statusRedBackground,
        ),
        OrderPaymentStatus.submittedForVerification => (
          foreground: AgrisellColors.statusBlueText,
          background: AgrisellColors.statusBlueBackground,
        ),
        OrderPaymentStatus.paymentReviewRequired => (
          foreground: AgrisellColors.statusPurpleText,
          background: AgrisellColors.statusPurpleBackground,
        ),
        OrderPaymentStatus.pendingCollection => (
          foreground: AgrisellColors.statusOrangeText,
          background: AgrisellColors.statusOrangeBackground,
        ),
        OrderPaymentStatus.cancelled => (
          foreground: AgrisellColors.mutedText,
          background: AgrisellColors.searchBackground,
        ),
        OrderPaymentStatus.refundRequired => (
          foreground: AgrisellColors.statusPurpleText,
          background: AgrisellColors.statusPurpleBackground,
        ),
        OrderPaymentStatus.refunded => (
          foreground: AgrisellColors.statusGreenText,
          background: AgrisellColors.statusGreenBackground,
        ),
      };
}
