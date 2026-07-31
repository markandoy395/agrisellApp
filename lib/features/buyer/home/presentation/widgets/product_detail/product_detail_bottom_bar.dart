import 'package:flutter/material.dart';

import 'package:agresell_app/core/theme/agrisellColors.dart';

class BottomActionBar extends StatelessWidget {
  const BottomActionBar({
    required this.isAvailable,
    required this.isPreOrder,
    required this.onAddToBasket,
    required this.onBuyNow,
    required this.showAddedFeedback,
    super.key,
  });

  final bool isAvailable;
  final bool isPreOrder;
  final VoidCallback onAddToBasket;
  final VoidCallback onBuyNow;
  final bool showAddedFeedback;

  @override
  Widget build(BuildContext context) {
    final platformBrightness = MediaQuery.platformBrightnessOf(context);
    final systemNavigationBarColor = AgrisellColors.systemNavigationBar(
      platformBrightness,
    );

    return ColoredBox(
      color: systemNavigationBarColor,
      child: SafeArea(
        top: false,
        child: Container(
          padding: const EdgeInsets.fromLTRB(14, 10, 14, 10),
          decoration: BoxDecoration(
            color: AgrisellColors.surface,
            boxShadow: [
              BoxShadow(
                color: AgrisellColors.brandBlack.withValues(alpha: 0.09),
                blurRadius: 16,
                offset: const Offset(0, -4),
              ),
            ],
          ),
          child: isAvailable
              ? _AvailableActions(
                  onBuyNow: onBuyNow,
                  onAddToBasket: onAddToBasket,
                  showAddedFeedback: showAddedFeedback,
                  isPreOrder: isPreOrder,
                )
              : const _UnavailableAction(),
        ),
      ),
    );
  }
}

class _AvailableActions extends StatelessWidget {
  const _AvailableActions({
    required this.onBuyNow,
    required this.onAddToBasket,
    required this.showAddedFeedback,
    required this.isPreOrder,
  });

  final VoidCallback onBuyNow;
  final VoidCallback onAddToBasket;
  final bool showAddedFeedback;
  final bool isPreOrder;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          flex: 2,
          child: SizedBox(
            height: 40,
            child: OutlinedButton(
              onPressed: onBuyNow,
              style: OutlinedButton.styleFrom(
                foregroundColor: AgrisellColors.authGreen,
                padding: const EdgeInsets.symmetric(horizontal: 8),
                side: const BorderSide(color: AgrisellColors.authGreen),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
                textStyle: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                ),
              ),
              child: Text(isPreOrder ? 'Pre-order now' : 'Buy Now'),
            ),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          flex: 3,
          child: SizedBox(
            height: 40,
            child: FilledButton(
              onPressed: onAddToBasket,
              style: FilledButton.styleFrom(
                backgroundColor: AgrisellColors.authGreen,
                foregroundColor: AgrisellColors.surface,
                padding: const EdgeInsets.symmetric(horizontal: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
                textStyle: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                ),
              ),
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 180),
                child: Text(
                  showAddedFeedback
                      ? (isPreOrder ? 'Added to Pre-order' : 'Added to Basket')
                      : (isPreOrder ? 'Add to Pre-order' : 'Add to Basket'),
                  key: ValueKey(showAddedFeedback),
                  maxLines: 1,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _UnavailableAction extends StatelessWidget {
  const _UnavailableAction();

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      enabled: false,
      label: 'Product is currently unavailable',
      child: SizedBox(
        width: double.infinity,
        height: 40,
        child: FilledButton.icon(
          onPressed: null,
          style: FilledButton.styleFrom(
            disabledBackgroundColor: AgrisellColors.deliveryGray,
            disabledForegroundColor: AgrisellColors.mutedText,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
          ),
          icon: const Icon(Icons.block_rounded, size: 18),
          label: const Text(
            'Currently Unavailable',
            style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700),
          ),
        ),
      ),
    );
  }
}
