import 'package:flutter/material.dart';

import 'package:agresell_app/features/buyer/home/presentation/styles/product_detail_info_card_styles.dart';
import 'package:agresell_app/features/buyer/home/presentation/widgets/product_detail/product_detail_facts.dart';
import 'package:agresell_app/features/buyer/home/presentation/widgets/product_detail/product_detail_price_line.dart';
import 'package:agresell_app/features/buyer/home/presentation/widgets/product_detail/product_detail_quantity_selector.dart';
import 'package:agresell_app/features/buyer/home/presentation/widgets/product_detail/product_detail_seller_card.dart';
import 'package:agresell_app/features/buyer/home/presentation/widgets/product_detail/product_detail_unavailable_notice.dart';
import 'package:agresell_app/features/shared/products/domain/home_product.dart';
import 'package:agresell_app/features/shared/products/presentation/widgets/product_sale_status_badge.dart';

class ProductInfoCard extends StatelessWidget {
  const ProductInfoCard({
    required this.product,
    required this.quantity,
    required this.onIncrement,
    required this.onDecrement,
    this.quantityEnabled = true,
    super.key,
  });

  final HomeProduct product;
  final int quantity;
  final VoidCallback onIncrement;
  final VoidCallback onDecrement;
  final bool quantityEnabled;

  @override
  Widget build(BuildContext context) {
    final description = product.description.trim();
    return Container(
      width: double.infinity,
      padding: ProductDetailInfoCardStyles.cardPadding,
      decoration: ProductDetailInfoCardStyles.cardDecoration,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            product.name,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: ProductDetailInfoCardStyles.nameStyle,
          ),
          const SizedBox(height: 8),
          ProductSaleStatusBadge(product: product, showCountdown: true),
          const SizedBox(height: 10),
          ProductDetailFacts(product: product),
          if (product.storageInstructions case final storage?) ...[
            const SizedBox(height: 8),
            ProductDetailStorageInstructions(text: storage),
          ],
          if (!product.canOrder) ...[
            const SizedBox(height: 12),
            const ProductDetailUnavailableNotice(),
          ],
          const SizedBox(height: 14),
          Row(
            children: [
              Expanded(child: ProductDetailPriceLine(product: product)),
              const SizedBox(width: 12),
              ProductDetailQuantitySelector(
                quantity: quantity,
                enabled: quantityEnabled,
                onIncrement: onIncrement,
                onDecrement: onDecrement,
              ),
            ],
          ),
          const SizedBox(height: 18),
          const ProductDetailSectionTitle(text: 'About Product'),
          const SizedBox(height: 6),
          Text(
            description.isEmpty
                ? 'The farmer has not provided a product description yet.'
                : description,
            style: ProductDetailInfoCardStyles.descriptionStyle,
          ),
          const SizedBox(height: 16),
          const ProductDetailSectionTitle(text: 'Farmer'),
          const SizedBox(height: 8),
          SellerCard(product: product),
        ],
      ),
    );
  }
}
