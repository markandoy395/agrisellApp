import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:agresell_app/core/theme/agrisell_colors.dart';
import 'package:agresell_app/core/widgets/app_snack_bar.dart';
import 'package:agresell_app/features/buyer/orders/presentation/styles/buyer_refund_tracker_styles.dart';
import 'package:agresell_app/features/buyer/orders/presentation/widgets/buyer_refund_detail_sheet.dart';
import 'package:agresell_app/features/shared/orders/domain/order_payment.dart';
import 'package:agresell_app/features/shared/orders/domain/placed_order.dart';
import 'package:agresell_app/features/shared/payments/price_formatter.dart';
import 'package:agresell_app/features/shared/products/presentation/widgets/product_thumbnail.dart';

class BuyerRefundOrderCard extends StatelessWidget {
  const BuyerRefundOrderCard({required this.order, super.key});

  final PlacedOrder order;

  void _copyReference(BuildContext context, String reference) {
    if (reference.trim().isEmpty) return;
    Clipboard.setData(ClipboardData(text: reference.trim()));
    ScaffoldMessenger.of(context).showAppSnackBar(
      const SnackBar(
        behavior: SnackBarBehavior.floating,
        content: Text('Refund reference copied to clipboard.'),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final payment = order.payment;
    final isCompleted = payment.isRefundCompleted;
    final isApproved = payment.status == OrderPaymentStatus.refundRequired ||
        payment.refundStatus.toLowerCase() == 'approved';
    final refundAmount = payment.refundAmount ?? order.total;
    final refundRef = payment.refundReference.isNotEmpty
        ? payment.refundReference
        : (payment.transactionReference.isNotEmpty
            ? payment.transactionReference
            : '');
    final firstItem = order.items.isNotEmpty ? order.items.first : null;

    return Container(
      decoration: BuyerRefundTrackerStyles.cardDecoration,
      padding: BuyerRefundTrackerStyles.cardPadding,
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
                  style: BuyerRefundTrackerStyles.orderIdStyle,
                ),
              ),
              Container(
                padding: BuyerRefundTrackerStyles.badgePadding,
                decoration: BuyerRefundTrackerStyles.badgeDecoration(
                  isCompleted: isCompleted,
                  isApproved: isApproved,
                ),
                child: Text(
                  isCompleted
                      ? 'Refund Completed'
                      : (isApproved ? 'Refund Approved' : 'In Progress'),
                  style: BuyerRefundTrackerStyles.badgeTextStyle(
                    isCompleted: isCompleted,
                    isApproved: isApproved,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          if (firstItem != null) ...[
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                ProductThumbnail.square(
                  asset: firstItem.image,
                  imageUrl: firstItem.imageUrl,
                  size: 52,
                  borderRadius: 8,
                  semanticLabel: '${firstItem.productName} photo',
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        order.title,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: BuyerRefundTrackerStyles.orderTitleStyle,
                      ),
                      const SizedBox(height: 3),
                      Text(
                        '${order.totalQuantity} items · ${formatBasketPeso(order.total)}',
                        style: BuyerRefundTrackerStyles.orderSubtitleStyle,
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
          ],
          Container(
            width: double.infinity,
            padding: BuyerRefundTrackerStyles.amountContainerPadding,
            decoration: BuyerRefundTrackerStyles.amountContainerDecoration,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Refund Amount',
                      style: BuyerRefundTrackerStyles.amountLabelStyle,
                    ),
                    const SizedBox(height: 2),
                    Text(
                      formatBasketPeso(refundAmount),
                      style: BuyerRefundTrackerStyles.amountValueStyle,
                    ),
                  ],
                ),
                if (refundRef.isNotEmpty)
                  Row(
                    children: [
                      Text(
                        'Ref: $refundRef',
                        style: BuyerRefundTrackerStyles.refTextStyle,
                      ),
                      const SizedBox(width: 4),
                      InkWell(
                        onTap: () => _copyReference(context, refundRef),
                        child: const Padding(
                          padding: EdgeInsets.all(3),
                          child: Icon(
                            Icons.copy_rounded,
                            size: 14,
                            color: AgrisellColors.authGreen,
                          ),
                        ),
                      ),
                    ],
                  ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            height: 36,
            child: OutlinedButton.icon(
              onPressed: () =>
                  showBuyerRefundDetailSheet(context, order: order),
              style: BuyerRefundTrackerStyles.trackButtonStyle,
              icon: const Icon(
                Icons.timeline_rounded,
                size: 16,
                color: AgrisellColors.authGreen,
              ),
              label: const Text(
                'Track Refund Status',
                style: BuyerRefundTrackerStyles.trackButtonTextStyle,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
