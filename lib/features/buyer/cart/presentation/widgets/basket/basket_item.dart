import 'package:flutter/material.dart';

import 'package:agresell_app/core/constants/agrisellAssets.dart';
import 'package:agresell_app/core/constants/agrisellRoutes.dart';
import 'package:agresell_app/core/theme/agrisellColors.dart';
import 'package:agresell_app/core/widgets/responsiveAssetImage.dart';
import 'package:agresell_app/features/shared/orders/domain/basket_cart_item.dart';
import 'package:agresell_app/features/buyer/cart/presentation/widgets/basket/basket_item_content.dart';
import 'package:agresell_app/features/buyer/cart/presentation/widgets/basket/basket_selection_checkbox.dart';
import 'package:agresell_app/features/buyer/home/domain/farmer_profile.dart';

class BasketItem extends StatelessWidget {
  const BasketItem({
    required this.item,
    required this.onSelectedChanged,
    required this.onIncrement,
    required this.onDecrement,
    required this.onRemove,
    super.key,
  });

  final BasketCartItem item;
  final ValueChanged<bool> onSelectedChanged;
  final VoidCallback onIncrement;
  final VoidCallback onDecrement;
  final VoidCallback onRemove;

  void _openSellerShop(BuildContext context) {
    final farmId = item.farmId;
    if (farmId == null || farmId <= 0) return;

    final farmer = FarmerProfile(
      farmId: farmId,
      name: item.sellerName,
      location: item.sellerLocation,
      rating: 0,
      coverImage: AgrisellAssets.loginBackground,
      products: const [],
    );
    Navigator.of(
      context,
    ).pushNamed(AgrisellRoutes.farmerShop, arguments: farmer);
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 180),
      decoration: BoxDecoration(
        color: AgrisellColors.surface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: item.isSelected
              ? AgrisellColors.authGreen.withValues(alpha: 0.5)
              : AgrisellColors.borderLine,
          width: item.isSelected ? 1.4 : 1,
        ),
        boxShadow: [
          BoxShadow(
            color: AgrisellColors.brandBlack.withValues(alpha: 0.05),
            blurRadius: 14,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(12, 12, 10, 12),
        child: Column(
          children: [
            _SellerRow(
              item: item,
              onSelectedChanged: onSelectedChanged,
              onOpenSellerShop: () => _openSellerShop(context),
              onRemove: onRemove,
            ),
            const SizedBox(height: 12),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(13),
                  child: ResponsiveAssetImage(
                    asset: item.image,
                    width: 88,
                    height: 96,
                    fit: BoxFit.cover,
                    semanticLabel: '${item.productName} product photo',
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(child: BasketItemDetails(item: item)),
              ],
            ),
            const SizedBox(height: 12),
            const Divider(height: 1, color: AgrisellColors.borderLine),
            const SizedBox(height: 10),
            BasketItemSummary(
              item: item,
              onDecrement: onDecrement,
              onIncrement: onIncrement,
            ),
          ],
        ),
      ),
    );
  }
}

class _SellerRow extends StatelessWidget {
  const _SellerRow({
    required this.item,
    required this.onSelectedChanged,
    required this.onOpenSellerShop,
    required this.onRemove,
  });

  final BasketCartItem item;
  final ValueChanged<bool> onSelectedChanged;
  final VoidCallback onOpenSellerShop;
  final VoidCallback onRemove;

  @override
  Widget build(BuildContext context) {
    final canOpenSellerShop = item.farmId != null && item.farmId! > 0;

    return Row(
      children: [
        BasketSelectionCheckbox(
          value: item.isSelected,
          label: 'Select ${item.productName}',
          onChanged: onSelectedChanged,
        ),
        Expanded(
          child: Semantics(
            button: canOpenSellerShop,
            label: 'Open ${item.sellerName} shop',
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                borderRadius: BorderRadius.circular(8),
                onTap: canOpenSellerShop ? onOpenSellerShop : null,
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 7),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.storefront_outlined,
                        color: AgrisellColors.authGreen,
                        size: 18,
                      ),
                      const SizedBox(width: 6),
                      Expanded(
                        child: Text(
                          item.sellerName,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            color: AgrisellColors.headingGreen,
                            fontSize: 13,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ),
                      const Icon(
                        Icons.chevron_right_rounded,
                        color: AgrisellColors.mutedText,
                        size: 18,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
        IconButton(
          key: ValueKey('remove-${item.productId}'),
          tooltip: 'Remove ${item.productName}',
          visualDensity: VisualDensity.compact,
          constraints: const BoxConstraints.tightFor(width: 36, height: 36),
          onPressed: onRemove,
          icon: const Icon(
            Icons.delete_outline_rounded,
            color: AgrisellColors.statusRedText,
            size: 20,
          ),
        ),
      ],
    );
  }
}
