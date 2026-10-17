import 'package:flutter/material.dart';
import 'package:agresell_app/features/shared/products/domain/home_product.dart';
import '../../styles/buyer_catalog_styles.dart';

double catalogPrice(String price) =>
    double.tryParse(price.replaceAll(RegExp(r'[^0-9.]'), '')) ?? 0;

int? catalogDiscount(HomeProduct product) {
  final original = catalogPrice(product.price);
  final active = catalogPrice(product.activePrice);
  if (!product.hasSale || original <= 0 || active >= original) return null;
  return ((original - active) / original * 100).round().clamp(1, 100);
}

class BuyerCatalogPrice extends StatelessWidget {
  const BuyerCatalogPrice({
    required this.product,
    required this.sale,
    super.key,
  });
  final HomeProduct product;
  final bool sale;

  @override
  Widget build(BuildContext context) => Text.rich(
    TextSpan(
      children: [
        if (sale && product.hasSale) ...[
          TextSpan(
            text: product.price,
            style: BuyerCatalogStyles.originalPrice,
          ),
          TextSpan(text: ' → ', style: BuyerCatalogStyles.stock),
        ],
        TextSpan(text: product.activePrice, style: BuyerCatalogStyles.price),
        TextSpan(
          text: ' ${product.unit.replaceFirst(RegExp(r'^per\s+'), '/ ')}',
          style: BuyerCatalogStyles.stock,
        ),
      ],
    ),
    maxLines: 2,
    overflow: TextOverflow.ellipsis,
  );
}
