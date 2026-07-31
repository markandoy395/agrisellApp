import 'package:flutter/material.dart';

import 'package:agresell_app/core/theme/agrisellColors.dart';
import 'package:agresell_app/features/buyer/home/domain/farmer_profile.dart';
import 'package:agresell_app/features/buyer/home/presentation/controllers/farmer_follow_controller.dart';
import 'package:agresell_app/features/buyer/home/presentation/widgets/farmer_avatar.dart';
import 'package:agresell_app/features/buyer/home/presentation/widgets/farmer/farmer_action_buttons.dart';
import 'package:agresell_app/features/buyer/home/presentation/widgets/farmer/farmer_card_details.dart';

class FarmerCard extends StatelessWidget {
  const FarmerCard({
    required this.farmer,
    required this.onChat,
    required this.onTap,
    this.followController,
    super.key,
  });

  final FarmerProfile farmer;
  final VoidCallback onChat;
  final VoidCallback onTap;
  final FarmerFollowController? followController;

  @override
  Widget build(BuildContext context) {
    final borderRadius = BorderRadius.circular(18);

    return Semantics(
      button: true,
      label: 'Open ${farmer.name} shop',
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: AgrisellColors.surface,
          borderRadius: borderRadius,
          boxShadow: [
            BoxShadow(
              color: AgrisellColors.brandBlack.withValues(alpha: 0.08),
              blurRadius: 14,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: borderRadius,
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: onTap,
              child: _FarmerInfoSection(
                farmer: farmer,
                onChat: onChat,
                onShop: onTap,
                followController: followController,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _FarmerInfoSection extends StatelessWidget {
  const _FarmerInfoSection({
    required this.farmer,
    required this.onChat,
    required this.onShop,
    this.followController,
  });

  final FarmerProfile farmer;
  final VoidCallback onChat;
  final VoidCallback onShop;
  final FarmerFollowController? followController;

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;
    final avatarSize = width < 380 ? 58.0 : 64.0;
    final availableProducts = farmer.products
        .where((product) => product.isAvailable)
        .length;
    final previewProducts = farmer.products.take(3).toList(growable: false);

    return Padding(
      padding: EdgeInsets.fromLTRB(
        width < 380 ? 14 : 18,
        16,
        width < 380 ? 14 : 18,
        14,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              FarmerAvatar(farmer: farmer, size: avatarSize),
              const SizedBox(width: 12),
              Expanded(child: FarmerIdentity(farmer: farmer)),
              const SizedBox(width: 8),
              FarmerAvailabilityBadge(availableProducts: availableProducts),
            ],
          ),
          const SizedBox(height: 13),
          Wrap(
            spacing: 6,
            runSpacing: 6,
            children: [
              for (final product in previewProducts)
                FarmerProductChip(product: product),
              if (farmer.products.length > previewProducts.length)
                FarmerMoreProductsChip(
                  count: farmer.products.length - previewProducts.length,
                ),
            ],
          ),
          const SizedBox(height: 14),
          FarmerActions(
            farmer: farmer,
            onChat: onChat,
            onShop: onShop,
            followController: followController,
          ),
        ],
      ),
    );
  }
}
