import 'package:agresell_app/features/buyer/cart/presentation/styles/basket_header_styles.dart';
import 'package:flutter/material.dart';

import 'package:agresell_app/core/theme/agrisell_colors.dart';

class BasketHeader extends StatelessWidget {
  const BasketHeader({
    required this.itemCount,
    required this.onMessagesTap,
    super.key,
  });

  final int itemCount;
  final VoidCallback onMessagesTap;

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;
    final topInset = MediaQuery.paddingOf(context).top;
    final horizontalPadding = width < 380 ? 14.0 : 18.0;

    return Container(
      width: double.infinity,
      padding: EdgeInsets.fromLTRB(
        horizontalPadding,
        topInset + 10,
        horizontalPadding,
        22,
      ),
      decoration: BasketHeaderStyles.containerDecoration,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              _HeaderButton(
                tooltip: 'Back',
                icon: Icons.arrow_back_rounded,
                onTap: () => Navigator.of(context).maybePop(),
              ),
              const Spacer(),
              _HeaderButton(
                tooltip: 'Open messages',
                icon: Icons.forum_outlined,
                onTap: onMessagesTap,
              ),
            ],
          ),
          const SizedBox(height: 16),
          const Text('Basket', style: BasketHeaderStyles.basketText),
          const SizedBox(height: 6),
          Text(
            itemCount == 0
                ? 'Fresh finds from local farmers await.'
                : '$itemCount ${itemCount == 1 ? 'product' : 'products'} ready to review',
            style: BasketHeaderStyles.textStyle,
          ),
        ],
      ),
    );
  }
}

class _HeaderButton extends StatelessWidget {
  const _HeaderButton({
    required this.tooltip,
    required this.icon,
    required this.onTap,
  });

  final String tooltip;
  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: tooltip,
      child: Material(
        color: AgrisellColors.surface.withValues(alpha: 0.16),
        borderRadius: BorderRadius.circular(14),
        child: InkWell(
          borderRadius: BorderRadius.circular(14),
          onTap: onTap,
          child: SizedBox.square(
            dimension: 42,
            child: Icon(icon, color: AgrisellColors.surface, size: 22),
          ),
        ),
      ),
    );
  }
}
