import 'package:agresell_app/features/farmer/reservations/presentation/styles/farmer_order_payment_panel_styles.dart';
import 'package:agresell_app/core/theme/shared_presentation_styles.dart';
import 'package:flutter/material.dart';

import 'package:agresell_app/core/theme/agrisell_colors.dart';
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
      decoration: FarmerOrderPaymentPanelStyles.containerDecoration(colors),
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
                  style: FarmerOrderPaymentPanelStyles.textStyle(colors),
                ),
                const SizedBox(height: 2),
                Text(
                  payment.status.label,
                  style: FarmerOrderPaymentPanelStyles.textStyle2(colors),
                ),
              ],
            ),
          ),
          if (payment.needsFarmerReview)
            SizedBox(
              height: 36,
              child: FilledButton(
                onPressed: () => showFarmerGcashReviewSheet(context, order),
                style: FarmerOrderPaymentPanelStyles.filledButtonStyle,
                child: const Text(
                  'Review',
                  style: SharedPresentationStyles.captionExtraBold,
                ),
              ),
            ),
          if (payment.status == OrderPaymentStatus.refundRequired)
            SizedBox(
              height: 36,
              child: FilledButton(
                onPressed: () => showFarmerGcashRefundSheet(context, order),
                style: FarmerOrderPaymentPanelStyles.filledButtonStyle2,
                child: const Text(
                  'Refund',
                  style: SharedPresentationStyles.captionExtraBold,
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
