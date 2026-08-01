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
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [AgrisellColors.forestDark, AgrisellColors.authGreen],
        ),
        borderRadius: const BorderRadius.vertical(bottom: Radius.circular(28)),
        boxShadow: [
          BoxShadow(
            color: AgrisellColors.forestDark.withValues(alpha: 0.2),
            blurRadius: 18,
            offset: const Offset(0, 7),
          ),
        ],
      ),
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
          const Text(
            'Basket',
            style: TextStyle(
              color: AgrisellColors.surface,
              fontSize: 24,
              height: 1.05,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            itemCount == 0
                ? 'Fresh finds from local farmers await.'
                : '$itemCount ${itemCount == 1 ? 'product' : 'products'} ready to review',
            style: TextStyle(
              color: AgrisellColors.surface.withValues(alpha: 0.78),
              fontSize: 12,
              height: 1.3,
              fontWeight: FontWeight.w500,
            ),
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
