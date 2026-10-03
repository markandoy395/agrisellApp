import 'package:agresell_app/features/buyer/profile/presentation/styles/orders_card_styles.dart';
import 'package:flutter/material.dart';

import 'package:agresell_app/core/utils/agrisell_page_route.dart';
import 'package:agresell_app/features/buyer/orders/presentation/screens/buyer_refund_tracker_screen.dart';
import 'package:agresell_app/features/buyer/orders/presentation/screens/order_tracking_screen.dart';
import 'package:agresell_app/features/buyer/profile/presentation/widgets/buyer_profile_style.dart';
import 'package:agresell_app/features/buyer/profile/presentation/widgets/order_status_item.dart';
import 'package:agresell_app/features/shared/orders/data/home_order_statuses.dart';
import 'package:agresell_app/features/shared/orders/domain/order_status.dart';
import 'package:agresell_app/features/shared/orders/presentation/controllers/order_controller.dart';

class OrdersCard extends StatelessWidget {
  const OrdersCard({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = OrderController.instance;

    return AnimatedBuilder(
      animation: controller,
      builder: (context, _) {
        final width = MediaQuery.sizeOf(context).width;
        final shortcutSidePadding = width < 380 ? 4.0 : 8.0;

        return BuyerProfileCard(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 14, 16, 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Expanded(
                      child: Text(
                        'My orders',
                        style: BuyerProfileStyle.heading,
                      ),
                    ),
                    InkWell(
                      onTap: () => _openOrderTracking(context),
                      borderRadius: BorderRadius.circular(8),
                      child: const Padding(
                        padding: EdgeInsets.symmetric(
                          horizontal: 6,
                          vertical: 4,
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              'View all',
                              style: OrdersCardStyles.viewAllText,
                            ),
                            SizedBox(width: 2),
                            Icon(
                              Icons.arrow_forward_ios_rounded,
                              color: BuyerProfileStyle.green,
                              size: 12,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 14),
                Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: shortcutSidePadding,
                  ),
                  child: Row(
                    children: [
                      for (final item in homeOrderStatuses)
                        Expanded(
                          child: OrderStatusItem(
                            label: item.label,
                            icon: item.icon,
                            count: controller.countForFilter(item.filter),
                            onTap: () => _openOrderTracking(
                              context,
                              filter: item.filter,
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
                const SizedBox(height: 14),
                Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: shortcutSidePadding,
                  ),
                  child: InkWell(
                    key: const ValueKey('buyer-refunds-shortcut'),
                    onTap: () => _openRefundTracker(context),
                    borderRadius: BorderRadius.circular(12),
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 10,
                      ),
                      decoration: OrdersCardStyles.containerDecoration,
                      child: const Row(
                        children: [
                          Icon(
                            Icons.receipt_long_outlined,
                            size: 18,
                            color: Color(0xFF7B1FA2),
                          ),
                          SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              'Refunds & Returns · Track status',
                              style: OrdersCardStyles
                                  .refundsReturnsTrackStatusText,
                            ),
                          ),
                          Icon(
                            Icons.chevron_right_rounded,
                            size: 20,
                            color: Color(0xFF7B1FA2),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _openOrderTracking(
    BuildContext context, {
    OrderTrackingFilter filter = OrderTrackingFilter.toShip,
  }) {
    Navigator.of(context).push(
      agrisellPageRoute<void>(
        builder: (_) => OrderTrackingScreen(initialFilter: filter),
      ),
    );
  }

  void _openRefundTracker(BuildContext context) {
    Navigator.of(context).push(
      agrisellPageRoute<void>(builder: (_) => const BuyerRefundTrackerScreen()),
    );
  }
}
