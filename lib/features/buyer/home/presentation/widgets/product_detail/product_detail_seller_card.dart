import 'package:flutter/material.dart';

import 'package:agresell_app/core/constants/agrisellRoutes.dart';
import 'package:agresell_app/core/theme/agrisellColors.dart';
import 'package:agresell_app/core/widgets/responsiveAssetImage.dart';
import 'package:agresell_app/features/buyer/home/data/farmer_shop_products.dart';
import 'package:agresell_app/features/buyer/home/presentation/widgets/farmer_avatar.dart';
import 'package:agresell_app/features/buyer/home/presentation/widgets/farmer/farmer_follow_button.dart';
import 'package:agresell_app/features/shared/products/domain/home_product.dart';

class SellerCard extends StatelessWidget {
  const SellerCard({required this.product, super.key});

  final HomeProduct product;

  @override
  Widget build(BuildContext context) {
    final farmer = farmerForProduct(product);
    final canOpenFarm = farmer != null;
    final borderRadius = BorderRadius.circular(17);

    return Semantics(
      button: canOpenFarm,
      label: canOpenFarm
          ? 'Open ${product.sellerName} farm shop'
          : '${product.sellerName} farm shop is unavailable',
      child: Material(
        color: AgrisellColors.fieldFill,
        borderRadius: borderRadius,
        child: InkWell(
          borderRadius: borderRadius,
          onTap: !canOpenFarm
              ? null
              : () {
                  Navigator.of(
                    context,
                  ).pushNamed(AgrisellRoutes.farmerShop, arguments: farmer);
                },
          child: Container(
            padding: const EdgeInsets.fromLTRB(10, 8, 10, 8),
            decoration: BoxDecoration(
              borderRadius: borderRadius,
              border: Border.all(color: AgrisellColors.borderLine),
            ),
            child: Row(
              children: [
                if (farmer != null)
                  FarmerAvatar(farmer: farmer, size: 52)
                else if (product.sellerImage.isEmpty)
                  const CircleAvatar(
                    radius: 26,
                    backgroundColor: AgrisellColors.forestSoft,
                    child: Icon(
                      Icons.person_outline_rounded,
                      color: AgrisellColors.authGreen,
                    ),
                  )
                else
                  ClipOval(
                    child: ResponsiveAssetImage(
                      asset: product.sellerImage,
                      width: 52,
                      height: 52,
                      fit: BoxFit.cover,
                      semanticLabel: product.sellerName,
                    ),
                  ),
                const SizedBox(width: 10),
                Expanded(child: _SellerText(product: product)),
                if (canOpenFarm) ...[
                  const SizedBox(width: 6),
                  SizedBox(
                    width: 88,
                    child: FarmerFollowButton(farmer: farmer, compact: true),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _SellerText extends StatelessWidget {
  const _SellerText({required this.product});

  final HomeProduct product;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          product.sellerName,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(
            color: AgrisellColors.brandBlack,
            fontSize: 13,
            height: 1.05,
            fontWeight: FontWeight.w800,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          product.sellerLocation,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(
            color: AgrisellColors.brandBlack,
            fontSize: 12,
            height: 1.05,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}
