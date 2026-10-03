import 'package:agresell_app/features/buyer/profile/presentation/styles/order_status_item_styles.dart';
import 'package:flutter/material.dart';

import 'package:agresell_app/features/buyer/profile/presentation/widgets/buyer_profile_style.dart';
import 'package:agresell_app/features/shared/widgets/badges/animated_count_badge.dart';

class OrderStatusItem extends StatelessWidget {
  const OrderStatusItem({
    required this.label,
    required this.icon,
    this.count = 0,
    this.onTap,
    super.key,
  });

  final String label;
  final IconData icon;
  final int count;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;
    final compact = width < 380;
    final semanticsLabel = count > 0
        ? '$label, $count ${count == 1 ? 'order' : 'orders'}'
        : '$label, no orders';

    return Semantics(
      button: true,
      label: semanticsLabel,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          key: ValueKey('my-order-$label'),
          onTap: onTap,
          borderRadius: BorderRadius.circular(12),
          child: Padding(
            padding: EdgeInsets.symmetric(
              horizontal: compact ? 1 : 2,
              vertical: 4,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Stack(
                  clipBehavior: Clip.none,
                  children: [
                    Container(
                      width: compact ? 44 : 50,
                      height: compact ? 42 : 48,
                      decoration: OrderStatusItemStyles.containerDecoration,
                      child: Icon(
                        icon,
                        color: BuyerProfileStyle.green,
                        size: compact ? 22 : 24,
                      ),
                    ),
                    if (count > 0)
                      Positioned(
                        key: ValueKey('order-count-$label'),
                        right: -6,
                        top: -6,
                        child: AnimatedCountBadge(count: count),
                      ),
                  ],
                ),
                const SizedBox(height: 6),
                Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  textAlign: TextAlign.center,
                  style: OrderStatusItemStyles.labelText,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
