import 'package:flutter/material.dart';

import 'package:agresell_app/core/constants/agrisell_assets.dart';
import 'package:agresell_app/core/theme/agrisell_colors.dart';
import 'package:agresell_app/features/shared/widgets/navigation/home_asset_icon.dart';

class EmptyBasketState extends StatelessWidget {
  const EmptyBasketState({required this.onContinueShopping, super.key});

  final VoidCallback onContinueShopping;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(18, 24, 18, 24),
      decoration: BoxDecoration(
        color: AgrisellColors.surface,
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(
            color: AgrisellColors.brandBlack.withValues(alpha: 0.08),
            blurRadius: 14,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const HomeAssetIcon(
            asset: AgrisellAssets.iconBasket,
            size: 46,
            color: AgrisellColors.authGreen,
          ),
          const SizedBox(height: 14),
          const Text(
            'Your basket is ready for fresh picks',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: AgrisellColors.brandBlack,
              fontSize: 15,
              height: 1.15,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 7),
          const Text(
            'Browse locally grown produce and add what you need for your next delivery.',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: AgrisellColors.mutedText,
              fontSize: 12,
              height: 1.25,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 18),
          FilledButton.icon(
            onPressed: onContinueShopping,
            style: FilledButton.styleFrom(
              backgroundColor: AgrisellColors.authGreen,
              foregroundColor: AgrisellColors.surface,
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
            ),
            icon: const Icon(Icons.storefront_outlined, size: 18),
            label: const Text(
              'Browse products',
              style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700),
            ),
          ),
        ],
      ),
    );
  }
}
