import 'package:flutter/material.dart';

import 'package:agresell_app/core/utils/agrisellPageRoute.dart';
import 'package:agresell_app/features/shared/orders/data/home_order_statuses.dart';
import 'package:agresell_app/features/shared/orders/domain/order_status.dart';
import 'package:agresell_app/features/shared/orders/presentation/controllers/order_controller.dart';
import 'package:agresell_app/features/buyer/orders/presentation/screens/order_tracking_screen.dart';
import 'package:agresell_app/features/buyer/profile/presentation/widgets/order_status_item.dart';
import 'package:agresell_app/features/shared/widgets/profile/profile_card_shell.dart';
import 'package:agresell_app/features/shared/widgets/profile/profile_section_label.dart';
import 'package:agresell_app/features/shared/widgets/profile/profile_text_styles.dart';

class OrdersCard extends StatelessWidget {
  const OrdersCard({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = OrderController.instance;

    return AnimatedBuilder(
      animation: controller,
      builder: (context, _) {
        final width = MediaQuery.sizeOf(context).width;
        final shortcutSidePadding = width < 380 ? 8.0 : 10.0;

        return ProfileCardShell(
          child: Padding(
            padding: const EdgeInsets.only(bottom: 16),
            child: Column(
              children: [
                Row(
                  children: [
                    const ProfileSectionLabel(text: 'My Orders'),
                    Expanded(
                      child: Align(
                        alignment: Alignment.centerRight,
                        child: InkResponse(
                          onTap: () => _openOrderTracking(context),
                          radius: 28,
                          child: Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 4,
                              vertical: 6,
                            ),
                            child: Text(
                              'View All Orders  >',
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: ProfileTextStyles.cardAction(context),
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                  ],
                ),
                const SizedBox(height: 18),
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
}
