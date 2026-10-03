import 'package:agresell_app/features/buyer/orders/presentation/styles/buyer_refund_order_list_view_styles.dart';
import 'package:flutter/material.dart';

import 'package:agresell_app/core/theme/agrisell_colors.dart';
import 'package:agresell_app/features/buyer/orders/presentation/styles/buyer_refund_tracker_styles.dart';
import 'package:agresell_app/features/buyer/orders/presentation/widgets/buyer_refund_order_card.dart';
import 'package:agresell_app/features/shared/orders/domain/placed_order.dart';

enum BuyerRefundFilter { all, completed, inProgress }

class BuyerRefundOrderListView extends StatelessWidget {
  const BuyerRefundOrderListView({
    required this.orders,
    required this.filter,
    super.key,
  });

  final List<PlacedOrder> orders;
  final BuyerRefundFilter filter;

  @override
  Widget build(BuildContext context) {
    if (orders.isEmpty) {
      return Center(
        child: Padding(
          padding: BuyerRefundTrackerStyles.emptyPadding,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: BuyerRefundTrackerStyles.emptyIconCircleSize,
                height: BuyerRefundTrackerStyles.emptyIconCircleSize,
                decoration: BuyerRefundOrderListViewStyles.containerDecoration,
                child: const Icon(
                  Icons.receipt_long_outlined,
                  size: BuyerRefundTrackerStyles.emptyIconSize,
                  color: AgrisellColors.mutedText,
                ),
              ),
              const SizedBox(height: 14),
              Text(
                filter == BuyerRefundFilter.completed
                    ? 'No completed refunds'
                    : (filter == BuyerRefundFilter.inProgress
                          ? 'No refunds in progress'
                          : 'No refund records found'),
                style: BuyerRefundTrackerStyles.emptyTitleStyle,
              ),
              const SizedBox(height: 6),
              const Text(
                'Cancelled orders eligible for GCash refunds will appear here with live tracking status.',
                textAlign: TextAlign.center,
                style: BuyerRefundTrackerStyles.emptySubtitleStyle,
              ),
            ],
          ),
        ),
      );
    }

    return ListView.separated(
      padding: BuyerRefundTrackerStyles.listPadding,
      itemCount: orders.length,
      separatorBuilder: (_, __) => BuyerRefundTrackerStyles.cardSeparator,
      itemBuilder: (context, index) {
        final order = orders[index];
        return BuyerRefundOrderCard(order: order);
      },
    );
  }
}
