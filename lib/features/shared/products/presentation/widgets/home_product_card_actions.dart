import 'package:flutter/material.dart';

import 'package:agresell_app/core/theme/agrisell_colors.dart';

class HomeProductCardActions extends StatelessWidget {
  const HomeProductCardActions({
    required this.productName,
    required this.isAvailable,
    required this.isSaved,
    this.onSavedToggle,
    this.onAddToBasket,
    super.key,
  });

  final String productName;
  final bool isAvailable;
  final bool isSaved;
  final VoidCallback? onSavedToggle;
  final VoidCallback? onAddToBasket;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        if (onSavedToggle != null)
          Positioned(
            right: 8,
            top: 8,
            child: _RoundActionButton(
              semanticLabel: isSaved
                  ? 'Remove $productName from saved products'
                  : 'Save $productName',
              tooltip: isSaved ? 'Remove from saved' : 'Save product',
              onTap: onSavedToggle,
              background: AgrisellColors.surface,
              foreground: isSaved
                  ? const Color(0xFFD94841)
                  : AgrisellColors.brandBlack,
              icon: isSaved
                  ? Icons.favorite_rounded
                  : Icons.favorite_border_rounded,
            ),
          ),
        if (!isAvailable)
          Positioned(
            left: 8,
            bottom: 8,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
              decoration: BoxDecoration(
                color: AgrisellColors.brandBlack.withValues(alpha: 0.78),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Text(
                'Unavailable',
                style: TextStyle(
                  color: AgrisellColors.surface,
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ),
        if (onAddToBasket != null)
          Positioned(
            right: 8,
            bottom: 8,
            child: _RoundActionButton(
              semanticLabel: isAvailable
                  ? 'Add $productName to basket'
                  : '$productName is unavailable',
              tooltip: isAvailable ? 'Add to basket' : 'Unavailable',
              onTap: isAvailable ? onAddToBasket : null,
              background: isAvailable
                  ? AgrisellColors.authGreen
                  : AgrisellColors.mutedText,
              foreground: AgrisellColors.surface,
              icon: isAvailable
                  ? Icons.add_shopping_cart_rounded
                  : Icons.block_rounded,
            ),
          ),
      ],
    );
  }
}

class _RoundActionButton extends StatelessWidget {
  const _RoundActionButton({
    required this.semanticLabel,
    required this.tooltip,
    required this.onTap,
    required this.background,
    required this.foreground,
    required this.icon,
  });

  final String semanticLabel;
  final String tooltip;
  final VoidCallback? onTap;
  final Color background;
  final Color foreground;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      enabled: onTap != null,
      label: semanticLabel,
      excludeSemantics: true,
      child: Tooltip(
        message: tooltip,
        child: Material(
          color: background,
          shape: const CircleBorder(),
          elevation: 2,
          child: InkWell(
            onTap: onTap,
            customBorder: const CircleBorder(),
            child: SizedBox.square(
              dimension: 38,
              child: Icon(icon, color: foreground, size: 19),
            ),
          ),
        ),
      ),
    );
  }
}
