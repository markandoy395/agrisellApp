import 'package:agresell_app/core/theme/shared_presentation_styles.dart';
import 'package:flutter/material.dart';

import 'package:agresell_app/core/constants/agrisell_routes.dart';
import 'package:agresell_app/core/theme/agrisell_colors.dart';
import 'package:agresell_app/features/buyer/home/presentation/widgets/product_detail/basket_count_button.dart';

class ProductDetailActionBar extends StatelessWidget {
  const ProductDetailActionBar({
    required this.basketCount,
    required this.basketPulse,
    required this.productName,
    this.isSaved = false,
    this.onSavedToggle,
    super.key,
  });

  final int basketCount;
  final int basketPulse;
  final String productName;
  final bool isSaved;
  final VoidCallback? onSavedToggle;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 56,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        child: Row(
          children: [
            _RoundActionButton(
              semanticLabel: 'Go back',
              icon: Icons.arrow_back_rounded,
              onTap: () => Navigator.of(context).maybePop(),
            ),
            Expanded(
              child: const Text(
                'Product Details',
                textAlign: TextAlign.center,
                style: SharedPresentationStyles.headingTitleExtraBold,
              ),
            ),
            if (onSavedToggle != null) ...[
              _RoundActionButton(
                semanticLabel: isSaved
                    ? 'Remove $productName from saved products'
                    : 'Save $productName',
                icon: isSaved
                    ? Icons.favorite_rounded
                    : Icons.favorite_border_rounded,
                onTap: onSavedToggle!,
                foreground: isSaved
                    ? AgrisellColors.statusRedText
                    : AgrisellColors.authGreen,
              ),
              const SizedBox(width: 6),
            ],
            BasketCountButton(
              count: basketCount,
              pulse: basketPulse,
              onTap: () =>
                  Navigator.of(context).pushNamed(AgrisellRoutes.basket),
            ),
          ],
        ),
      ),
    );
  }
}

class _RoundActionButton extends StatelessWidget {
  const _RoundActionButton({
    required this.semanticLabel,
    required this.icon,
    required this.onTap,
    this.foreground = AgrisellColors.authGreen,
  });

  final String semanticLabel;
  final IconData icon;
  final VoidCallback onTap;
  final Color foreground;

  @override
  Widget build(BuildContext context) {
    return _RoundActionSurface(
      semanticLabel: semanticLabel,
      onTap: onTap,
      child: Icon(icon, color: foreground, size: 21),
    );
  }
}

class _RoundActionSurface extends StatelessWidget {
  const _RoundActionSurface({
    required this.semanticLabel,
    required this.onTap,
    required this.child,
  });

  final String semanticLabel;
  final VoidCallback onTap;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: semanticLabel,
      child: SizedBox.square(
        dimension: 40,
        child: Material(
          color: AgrisellColors.forestSoft,
          shape: const CircleBorder(),
          child: InkWell(
            customBorder: const CircleBorder(),
            onTap: onTap,
            child: Center(child: child),
          ),
        ),
      ),
    );
  }
}
