import 'package:flutter/material.dart';

import 'package:agresell_app/core/theme/agrisellColors.dart';
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
                        child: _OrderCountBadge(count: count),
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

class _OrderCountBadge extends StatelessWidget {
  const _OrderCountBadge({required this.count});

  final int count;

  @override
  Widget build(BuildContext context) {
    final label = count > 99 ? '99+' : '$count';

    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 220),
      switchInCurve: Curves.easeOutBack,
      switchOutCurve: Curves.easeIn,
      transitionBuilder: (child, animation) {
        return ScaleTransition(
          scale: animation,
          child: FadeTransition(opacity: animation, child: child),
        );
      },
      child: Container(
        key: ValueKey(label),
        constraints: const BoxConstraints(minWidth: 18, minHeight: 18),
        padding: const EdgeInsets.symmetric(horizontal: 4),
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: AgrisellColors.authGreen,
          borderRadius: BorderRadius.circular(9),
          border: Border.all(color: AgrisellColors.surface, width: 1.5),
          boxShadow: [
            BoxShadow(
              color: AgrisellColors.brandBlack.withValues(alpha: 0.16),
              blurRadius: 6,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Text(
          label,
          maxLines: 1,
          textAlign: TextAlign.center,
          style: const TextStyle(
            color: AgrisellColors.surface,
            fontSize: 12,
            height: 1,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
    );
  }
}
