import 'package:flutter/material.dart';

import 'package:agresell_app/core/theme/agrisell_colors.dart';
import 'package:agresell_app/features/shared/products/presentation/widgets/product_thumbnail.dart';
import 'package:agresell_app/features/farmer/reservations/domain/farmer_reservation.dart';

class ReservedProductRow extends StatelessWidget {
  const ReservedProductRow({required this.product, super.key});

  final FarmerReservedProduct product;

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;
    final imageSize = width < 380 ? 88.0 : 96.0;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ProductThumbnail.square(
            asset: product.image,
            size: imageSize,
            borderRadius: 10,
            semanticLabel: '${product.name} product photo',
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _ProductDetailLine(label: 'Product', value: product.name),
                const SizedBox(height: 5),
                _ProductDetailLine(label: 'Price', value: product.price),
                const SizedBox(height: 5),
                _ProductDetailLine(label: 'Order Qty', value: product.quantity),
                const SizedBox(height: 5),
                _ProductDetailLine(
                  label: 'Date to harvest',
                  value: product.harvestDate,
                ),
                const SizedBox(height: 5),
                _ProductDetailLine(
                  label: 'Date deliver',
                  value: product.deliverDate,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ProductDetailLine extends StatelessWidget {
  const _ProductDetailLine({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Text.rich(
      TextSpan(
        children: [
          TextSpan(
            text: '$label: ',
            style: const TextStyle(fontWeight: FontWeight.w800),
          ),
          TextSpan(text: value),
        ],
      ),
      style: const TextStyle(
        color: AgrisellColors.brandBlack,
        fontSize: 12,
        height: 1.2,
        fontWeight: FontWeight.w500,
      ),
    );
  }
}
