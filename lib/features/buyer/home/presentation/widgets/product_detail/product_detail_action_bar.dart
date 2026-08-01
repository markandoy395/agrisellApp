import 'package:flutter/material.dart';

import 'package:agresell_app/core/constants/agrisell_routes.dart';
import 'package:agresell_app/core/theme/agrisell_colors.dart';
import 'package:agresell_app/features/buyer/home/presentation/widgets/product_detail/basket_count_button.dart';

class ProductDetailActionBar extends StatelessWidget {
  const ProductDetailActionBar({
    required this.basketCount,
    required this.basketPulse,
    super.key,
  });

  final int basketCount;
  final int basketPulse;

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
            const Expanded(
              child: Text(
                'Product Details',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: AgrisellColors.headingGreen,
                  fontSize: 15,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
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
  });

  final String semanticLabel;
  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return _RoundActionSurface(
      semanticLabel: semanticLabel,
      onTap: onTap,
      child: Icon(icon, color: AgrisellColors.authGreen, size: 21),
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
