import 'package:flutter/material.dart';

import 'package:agresell_app/core/theme/agrisell_colors.dart';
import 'package:agresell_app/features/shared/products/domain/home_product.dart';
import 'package:agresell_app/features/buyer/home/presentation/widgets/product_detail/product_detail_price_line.dart';
import 'package:agresell_app/features/buyer/home/presentation/widgets/product_detail/product_detail_seller_card.dart';
import 'package:agresell_app/features/buyer/home/presentation/widgets/product_detail/product_detail_quantity_selector.dart';
import 'package:agresell_app/features/buyer/home/presentation/widgets/product_detail/product_detail_unavailable_notice.dart';
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
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AgrisellColors.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AgrisellColors.borderLine),
        boxShadow: [
          BoxShadow(
            color: AgrisellColors.brandBlack.withValues(alpha: 0.06),
            blurRadius: 14,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            product.name,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              color: AgrisellColors.headingGreen,
              fontSize: 15,
              height: 1.15,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 8),
          ProductSaleStatusBadge(product: product, showCountdown: true),
          const SizedBox(height: 10),
          _ProductFacts(product: product),
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
          const _SectionTitle(text: 'About Product'),
          const SizedBox(height: 6),
          Text(
            description.isEmpty
                ? 'The farmer has not provided a product description yet.'
                : description,
            style: const TextStyle(
              color: AgrisellColors.mutedText,
              fontSize: 12,
              height: 1.45,
              fontWeight: FontWeight.w400,
            ),
          ),
          const SizedBox(height: 16),
          const _SectionTitle(text: 'Farmer'),
          const SizedBox(height: 8),
          SellerCard(product: product),
        ],
      ),
    );
  }
}

class _ProductFacts extends StatelessWidget {
  const _ProductFacts({required this.product});

  final HomeProduct product;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 14,
      runSpacing: 8,
      children: [
        _Fact(
          icon: Icons.inventory_2_outlined,
          text: product.availableQuantityLabel,
        ),
        _Fact(icon: Icons.calendar_today_outlined, text: product.harvestDate),
      ],
    );
  }
}

class _Fact extends StatelessWidget {
  const _Fact({required this.icon, required this.text});

  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, color: AgrisellColors.authGreen, size: 16),
        const SizedBox(width: 4),
        Text(
          text,
          style: const TextStyle(
            color: AgrisellColors.mutedText,
            fontSize: 12,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: const TextStyle(
        color: AgrisellColors.headingGreen,
        fontSize: 14,
        fontWeight: FontWeight.w800,
      ),
    );
  }
}
