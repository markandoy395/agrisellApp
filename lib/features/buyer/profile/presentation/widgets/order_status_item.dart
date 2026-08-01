import 'package:flutter/material.dart';

import 'package:agresell_app/core/theme/agrisell_colors.dart';
import 'package:agresell_app/features/shared/widgets/badges/animated_count_badge.dart';
import 'package:agresell_app/features/shared/widgets/profile/profile_text_styles.dart';

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
    final compact = MediaQuery.sizeOf(context).width < 380;
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
          borderRadius: BorderRadius.circular(10),
          child: Padding(
            padding: EdgeInsets.symmetric(
              horizontal: compact ? 1 : 2,
              vertical: 6,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Stack(
                  clipBehavior: Clip.none,
                  children: [
                    Container(
                      width: compact ? 36 : 40,
                      height: compact ? 36 : 40,
                      decoration: BoxDecoration(
                        color: AgrisellColors.forestSoft,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: AgrisellColors.authGreen.withValues(
                            alpha: 0.12,
                          ),
                        ),
                      ),
                      child: Icon(
                        icon,
                        color: AgrisellColors.authGreen,
                        size: compact ? 21 : 23,
                      ),
                    ),
                    if (count > 0)
                      Positioned(
                        key: ValueKey('order-count-$label'),
                        right: -7,
                        top: -7,
                        child: AnimatedCountBadge(count: count),
                      ),
                  ],
                ),
                const SizedBox(height: 7),
                Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  textAlign: TextAlign.center,
                  style: ProfileTextStyles.orderLabel(context),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
