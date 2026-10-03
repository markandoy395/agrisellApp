import 'package:agresell_app/features/buyer/home/presentation/styles/product_detail_bottom_bar_styles.dart';
import 'package:agresell_app/core/theme/shared_presentation_styles.dart';
import 'package:flutter/material.dart';

import 'package:agresell_app/core/theme/agrisell_colors.dart';

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
          decoration: ProductDetailBottomBarStyles.containerDecoration,
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
              style: ProductDetailBottomBarStyles.outlinedButtonStyle,
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
              style: ProductDetailBottomBarStyles.filledButtonStyle,
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
          style: ProductDetailBottomBarStyles.filledButtonStyle2,
          icon: const Icon(Icons.block_rounded, size: 18),
          label: const Text(
            'Currently Unavailable',
            style: SharedPresentationStyles.captionBold,
          ),
        ),
      ),
    );
  }
}
