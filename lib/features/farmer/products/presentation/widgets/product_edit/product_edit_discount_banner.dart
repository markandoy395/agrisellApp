import 'package:flutter/material.dart';

import 'package:agresell_app/core/theme/agrisell_colors.dart';
import 'package:agresell_app/features/farmer/products/presentation/styles/farmer_product_edit_form_panel_styles.dart';

class ProductEditDiscountBanner extends StatelessWidget {
  const ProductEditDiscountBanner({
    this.activeSaleNotice,
    this.isFarmerDiscount = false,
    this.onManageDiscount,
    this.onRemoveDiscount,
    super.key,
  });

  final String? activeSaleNotice;
  final bool isFarmerDiscount;
  final VoidCallback? onManageDiscount;
  final VoidCallback? onRemoveDiscount;

  @override
  Widget build(BuildContext context) {
    if (activeSaleNotice != null) {
      return Padding(
        padding: const EdgeInsets.only(bottom: 20),
        child: Container(
          width: double.infinity,
          padding: FarmerProductEditFormPanelStyles.bannerPadding,
          decoration: FarmerProductEditFormPanelStyles.activeBannerDecoration,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Icon(
                    Icons.local_offer_rounded,
                    color: AgrisellColors.authGreen,
                    size: 20,
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          isFarmerDiscount
                              ? 'Active Product Promotion'
                              : 'Featured in Active Admin Sale',
                          style: FarmerProductEditFormPanelStyles
                              .activeBannerTitleStyle,
                        ),
                        const SizedBox(height: 2),
                        Text(
                          activeSaleNotice!,
                          style: FarmerProductEditFormPanelStyles
                              .activeBannerNoticeStyle,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              if (isFarmerDiscount && onManageDiscount != null) ...[
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton.icon(
                      onPressed: onManageDiscount,
                      icon: const Icon(Icons.edit_outlined, size: 14),
                      label: const Text('Edit Discount'),
                      style: FarmerProductEditFormPanelStyles
                          .editDiscountButtonStyle,
                    ),
                    if (onRemoveDiscount != null) ...[
                      const SizedBox(width: 4),
                      TextButton.icon(
                        onPressed: onRemoveDiscount,
                        icon: const Icon(Icons.delete_outline_rounded, size: 14),
                        label: const Text('Remove'),
                        style: FarmerProductEditFormPanelStyles
                            .removeDiscountButtonStyle,
                      ),
                    ],
                  ],
                ),
              ],
            ],
          ),
        ),
      );
    }

    if (onManageDiscount != null) {
      return Padding(
        padding: const EdgeInsets.only(bottom: 20),
        child: Container(
          width: double.infinity,
          padding: FarmerProductEditFormPanelStyles.bannerPadding,
          decoration:
              FarmerProductEditFormPanelStyles.inactiveBannerDecoration,
          child: Row(
            children: [
              const Icon(
                Icons.local_offer_outlined,
                color: AgrisellColors.mutedText,
                size: 20,
              ),
              const SizedBox(width: 10),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Product Discount',
                      style: FarmerProductEditFormPanelStyles
                          .inactiveBannerTitleStyle,
                    ),
                    SizedBox(height: 2),
                    Text(
                      'No active promotion on this product.',
                      style: FarmerProductEditFormPanelStyles
                          .inactiveBannerNoticeStyle,
                    ),
                  ],
                ),
              ),
              OutlinedButton(
                onPressed: onManageDiscount,
                style: FarmerProductEditFormPanelStyles.putOnSaleButtonStyle,
                child: const Text(
                  'Put on Sale',
                  style: FarmerProductEditFormPanelStyles
                      .putOnSaleButtonTextStyle,
                ),
              ),
            ],
          ),
        ),
      );
    }

    return const SizedBox.shrink();
  }
}
