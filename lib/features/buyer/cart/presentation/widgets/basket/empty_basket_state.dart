import 'package:agresell_app/features/buyer/cart/presentation/styles/empty_basket_state_styles.dart';
import 'package:agresell_app/core/theme/shared_presentation_styles.dart';
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
      decoration: EmptyBasketStateStyles.containerDecoration,
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
            style: EmptyBasketStateStyles.yourBasketIsReadyForText,
          ),
          const SizedBox(height: 7),
          const Text(
            'Browse locally grown produce and add what you need for your next delivery.',
            textAlign: TextAlign.center,
            style: EmptyBasketStateStyles.textStyle,
          ),
          const SizedBox(height: 18),
          FilledButton.icon(
            onPressed: onContinueShopping,
            style: EmptyBasketStateStyles.filledButtonStyle,
            icon: const Icon(Icons.storefront_outlined, size: 18),
            label: const Text(
              'Browse products',
              style: SharedPresentationStyles.captionBold,
            ),
          ),
        ],
      ),
    );
  }
}
